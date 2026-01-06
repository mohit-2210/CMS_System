import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/labor_model.dart';
import 'package:cms/models/attendance_model.dart';
import 'package:provider/provider.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:intl/intl.dart';

@NowaGenerated()
class LaborService extends ChangeNotifier {
  LaborService() {
    _initializeService();
  }

  factory LaborService.of(BuildContext context, {bool listen = false}) {
    return Provider.of<LaborService>(context, listen: listen);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<LaborModel> _labors = [];
  bool _isLoading = false;

  List<LaborModel> get labors => _labors;
  bool get isLoading => _isLoading;

  void _initializeService() {
    _firestore
        .collection('labors')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _labors = snapshot.docs
          .map((doc) => LaborModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      notifyListeners();
    });
  }

  Future<bool> createLabor({
    required String laborName,
    required String work,
    required String siteName,
    required double salary,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final docRef = _firestore.collection('labors').doc();
      final newLabor = LaborModel(
        id: docRef.id,
        laborName: laborName,
        work: work,
        siteName: siteName,
        salary: salary,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await docRef.set(newLabor.toJson());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error creating labor: $e');
      return false;
    }
  }

  /// Assign a labor to a site
  Future<bool> assignLaborToSite({
    required String laborId,
    required String siteId,
    required String siteName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Deactivate current active assignment if any
      final activeQuery = await _firestore
          .collection('assignments')
          .where('laborId', isEqualTo: laborId)
          .where('status', isEqualTo: 'active')
          .get();

      final batch = _firestore.batch();

      for (var doc in activeQuery.docs) {
        batch.update(doc.reference, {
          'status': 'inactive',
          'endDate': FieldValue.serverTimestamp(),
        });
      }

      // 2. Create new assignment
      final newAssignmentRef = _firestore.collection('assignments').doc();
      batch.set(newAssignmentRef, {
        'laborId': laborId,
        'siteId': siteId,
        'siteName': siteName,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'startDate': FieldValue.serverTimestamp(),
      });

      // 3. Update labor document (Legacy support + UI display)
      batch.update(_firestore.collection('labors').doc(laborId), {
        'siteName': siteName,
      });

      await batch.commit();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error assigning labor to site: $e');
      return false;
    }
  }

  Future<bool> deleteLabors(List<String> laborIds) async {
    try {
      _isLoading = true;
      notifyListeners();

      final batch = _firestore.batch();
      for (final id in laborIds) {
        batch.delete(_firestore.collection('labors').doc(id));
        // Also deactivate assignments? Or delete them? 
        // User didn't specify, but keeping them for history is safer.
        // We might want to set them to inactive.
        // For now, leaving assignments as is, or we could fetch and deactivate.
      }
      await batch.commit();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error deleting labors: $e');
      return false;
    }
  }

  /// Unassign multiple labors from their sites
  Future<bool> unassignLabors(List<String> laborIds) async {
    try {
      _isLoading = true;
      notifyListeners();

      final batch = _firestore.batch();
      
      for (final id in laborIds) {
        // Update labor doc
        batch.update(_firestore.collection('labors').doc(id), {
          'siteName': 'Unassigned',
        });

        // Deactivate active assignments
        final activeQuery = await _firestore
            .collection('assignments')
            .where('laborId', isEqualTo: id)
            .where('status', isEqualTo: 'active')
            .get();
        
        for (var doc in activeQuery.docs) {
          batch.update(doc.reference, {
            'status': 'inactive',
            'endDate': FieldValue.serverTimestamp(),
          });
        }
      }
      
      await batch.commit();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error unassigning labors: $e');
      return false;
    }
  }

  /// Update labor active status
  Future<bool> updateLaborActiveStatus({
    required String laborId,
    required bool isActive,
  }) async {
    try {
      await _firestore.collection('labors').doc(laborId).update({
        'isActive': isActive,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating labor active status: $e');
      return false;
    }
  }

  /// Mark attendance for a labor on a specific date
  Future<bool> markAttendance({
    required String laborId,
    required DateTime date,
    required String dayShift,
    required String nightShift,
    double withdrawAmount = 0.0,
    String? siteName,
    String? adminName,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final attendance = AttendanceModel(
        date: dateStr,
        dayShift: dayShift,
        nightShift: nightShift,
        withdrawAmount: withdrawAmount,
        siteName: siteName ?? '',
        adminName: adminName ?? '',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('labors')
          .doc(laborId)
          .collection('attendance')
          .doc(dateStr)
          .set(attendance.toJson());

      return true;
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      return false;
    }
  }

  /// Get attendance for a specific date
  Future<AttendanceModel?> getAttendanceForDate({
    required String laborId,
    required DateTime date,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final doc = await _firestore
          .collection('labors')
          .doc(laborId)
          .collection('attendance')
          .doc(dateStr)
          .get();

      if (doc.exists) {
        return AttendanceModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting attendance: $e');
      return null;
    }
  }

  /// Get attendance for a date range
  Future<List<AttendanceModel>> getAttendanceForPeriod({
    required String laborId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);

      final snapshot = await _firestore
          .collection('labors')
          .doc(laborId)
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr)
          .orderBy('date')
          .get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting attendance for period: $e');
      return [];
    }
  }

  /// Record withdrawal amount for a specific date
  Future<bool> recordWithdrawal({
    required String laborId,
    required DateTime date,
    required double amount,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      await _firestore
          .collection('labors')
          .doc(laborId)
          .collection('attendance')
          .doc(dateStr)
          .update({
        'withdrawAmount': FieldValue.increment(amount),
      });

      return true;
    } catch (e) {
      debugPrint('Error recording withdrawal: $e');
      return false;
    }
  }
}
