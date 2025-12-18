import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/user_role.dart';
import 'package:cms/admin_status.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch existing attendance record for a specific labor on a specific date
  Future<Map<String, dynamic>?> getAttendanceRecord({
    required String siteName,
    required String laborId,
    required DateTime date,
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final query = await _firestore
          .collection('attendances')
          .where('siteName', isEqualTo: siteName)
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
    required String siteName,
    required String laborId,
    required String laborName,
    required DateTime date,
    required String dayShift,
    required String nightShift,
    required int? newWithdrawAmount,
    required String paymentMode,
    required String? adminName,
  }) async {
    try {
      // Check if record exists
      final existingRecord = await getAttendanceRecord(
        siteName: siteName,
        laborId: laborId,
        date: date,
      );

      // Calculate cumulative withdrawal amount
      int totalWithdrawAmount = 0;
      if (newWithdrawAmount != null && newWithdrawAmount > 0) {
        if (existingRecord != null) {
          // Update: add to existing amount
          totalWithdrawAmount = (existingRecord['withdrawAmount'] ?? 0) + newWithdrawAmount;
        } else {
          // New record
          totalWithdrawAmount = newWithdrawAmount;
        }
      }

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final attendanceData = {
        'siteName': siteName,
        'laborId': laborId,
        'laborName': laborName,
        'date': Timestamp.fromDate(date),
        'dateStr': dateStr, // For easier querying
        'dayShift': dayShift,
        'nightShift': nightShift,
        'withdrawAmount': totalWithdrawAmount,
        'paymentMode': paymentMode,
        'adminName': adminName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (existingRecord != null) {
        // Update existing record
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final query = await _firestore
            .collection('attendances')
            .where('siteName', isEqualTo: siteName)
            .where('laborId', isEqualTo: laborId)
            .where('dateStr', isEqualTo: dateStr)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update(attendanceData);
        }
      } else {
        // Create new record
        attendanceData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('attendances').add(attendanceData);
      }

      return true;
    } catch (e) {
      print('Error creating/updating attendance: $e');
      return false;
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