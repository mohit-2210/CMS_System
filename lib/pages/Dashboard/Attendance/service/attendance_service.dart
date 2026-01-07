import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/user_role.dart';
import 'package:cms/admin_status.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch existing attendance record for a specific labor on a specific date
  Future<Map<String, dynamic>?> getAttendanceRecord({
    required String laborId,
    required DateTime date,
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Try fetching by strict ID first (New Flow)
      final docId = '${dateStr}_$laborId';
      final docSnapshot = await _firestore.collection('attendance').doc(docId).get();
      
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }

      // Fallback: Query by fields (Old Flow or if ID format was different)
      final query = await _firestore
          .collection('attendance')
          .where('laborId', isEqualTo: laborId)
          .where('dateStr', isEqualTo: dateStr)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error fetching attendance record: $e');
      return null;
    }
  }

  /// Fetch all attendance records for a specific date (for filtering)
  Future<List<Map<String, dynamic>>> getAllAttendanceForDate(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final query = await _firestore
          .collection('attendance')
          .where('dateStr', isEqualTo: dateStr)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching daily attendance: $e');
      return [];
    }
  }

  /// Fetch all approved admin users
  Future<List<String>> getApprovedAdminsAndSuperAdmins() async {
    try {
      final query = await _firestore
    .collection('users')
    .where(
      'role',
      whereIn: [
        UserRole.admin.toString(),
        UserRole.superAdmin.toString(),
      ],
    )
    .where(
      'status',
      isEqualTo: AdminStatus.approved.toString(),
    )
    .get();


      return query.docs
          .map((doc) => doc['name'] as String)
          .toList();
    } catch (e) {
      print('Error fetching approved admins: $e');
      return [];
    }
  }

  /// Create or update attendance with cumulative withdrawal logic
  Future<bool> createOrUpdateAttendance({
    required String laborId,
    required String laborName,
    required DateTime date,
    required String dayShift,
    required String nightShift,
    required int? newWithdrawAmount,
    required String paymentMode,
    required String? adminName,
    String? siteName, // Optional: provided manually for previous dates
    String? siteId,   // Optional: provided manually for previous dates
  }) async {
    try {
      String? actualSiteId;
      String? actualSiteName;
      DocumentReference? activeAssignmentRef;

      // Logic Branching: Manual Override vs Strict Assignment
      if (siteId != null && siteId.isNotEmpty) {
        // --- CASE 2: Previous Date / Manual Override ---
        
        // 1. Check for active assignment to toggle it
        final assignmentQuery = await _firestore
            .collection('assignments')
            .where('laborId', isEqualTo: laborId)
            .where('status', isEqualTo: 'active')
            .get();

        if (assignmentQuery.docs.isNotEmpty) {
           final activeDoc = assignmentQuery.docs.first;
           activeAssignmentRef = activeDoc.reference;
           
           // Deactivate (Temporarily)
           await activeAssignmentRef.update({
             'status': 'inactive',
             'temp_deactivated_for_attendance': true, // Audit trail
           });
        }

        actualSiteId = siteId;
        actualSiteName = siteName ?? 'Unknown Site';

      } else {
        // --- CASE 1: Strict / Current Date ---
        
        // 1. Check Assignments
        final assignmentQuery = await _firestore
            .collection('assignments')
            .where('laborId', isEqualTo: laborId)
            .where('status', isEqualTo: 'active')
            .get();

        if (assignmentQuery.docs.isEmpty) {
          throw Exception("Labour is not assigned to any site");
        }

        final assignment = assignmentQuery.docs.first.data();
        actualSiteId = assignment['siteId'] as String?;
        actualSiteName = assignment['siteName'] as String?;

        if (actualSiteName == null || actualSiteName.isEmpty) {
           throw Exception("Invalid assignment: missing site information");
        }
      }

      // 2. Prepare Doc ID and Data (Common Logic)
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final docId = '${dateStr}_$laborId';
      
      final attendanceRef = _firestore.collection('attendance').doc(docId);
      final existingDoc = await attendanceRef.get();

      // Calculate cumulative withdrawal
      int totalWithdrawAmount = 0;
      if (newWithdrawAmount != null && newWithdrawAmount > 0) {
        if (existingDoc.exists) {
          final data = existingDoc.data();
          totalWithdrawAmount = (data?['withdrawAmount'] ?? 0) + newWithdrawAmount;
        } else {
          totalWithdrawAmount = newWithdrawAmount;
        }
      } else if (existingDoc.exists) {
         // Keep existing amount if no new withdrawal
         totalWithdrawAmount = existingDoc.data()?['withdrawAmount'] ?? 0;
      }

      final Map<String, dynamic> attendanceData = {
        'laborId': laborId,
        'laborName': laborName.isEmpty ? actualSiteName : laborName,
        'date': Timestamp.fromDate(date),
        'dateStr': dateStr,
        'dayShift': dayShift,
        'nightShift': nightShift,
        'withdrawAmount': totalWithdrawAmount,
        'paymentMode': paymentMode,
        'adminName': adminName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        if (!existingDoc.exists) {
          // New Record - Set site info
          attendanceData['siteId'] = actualSiteId;
          attendanceData['siteName'] = actualSiteName;
          attendanceData['createdAt'] = FieldValue.serverTimestamp();
          
          await attendanceRef.set(attendanceData);
        } else {
          // Update - Do NOT change site info
          await attendanceRef.update(attendanceData);
        }
      } finally {
        // 3. Reactivate Assignment (Case 2 cleanup)
        // Ensure we restore active status even if attendance save fails? 
        // Or only if it succeeds? 
        // User said: "After successful attendance saving... assignment status is set back to active"
        // But if attendance fails, we probably SHOULD restore it anyway to not leave system in broken state.
        
        if (activeAssignmentRef != null) {
          await activeAssignmentRef.update({
             'status': 'active',
             'temp_deactivated_for_attendance': FieldValue.delete(),
          });
        }
      }

      return true;
    } catch (e) {
      print('Error creating/updating attendance: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  /// Save attendance (legacy method - kept for compatibility)
  Future<void> saveAttendance({
    required String siteName,
    required String laborId,
    required String laborName,
    required DateTime date,
    required String dayShift,
    required String nightShift,
    required int? withdrawAmount,
    required String paymentMode,
    required String? adminName,
  }) async {
    await createOrUpdateAttendance(
      siteName: siteName,
      laborId: laborId,
      laborName: laborName,
      date: date,
      dayShift: dayShift,
      nightShift: nightShift,
      newWithdrawAmount: withdrawAmount,
      paymentMode: paymentMode,
      adminName: adminName,
    );
  }
}