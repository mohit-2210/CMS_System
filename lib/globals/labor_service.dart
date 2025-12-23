import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/labor_model.dart';
import 'package:cms/models/attendance_model.dart';
import 'package:cms/models/pay_period_model.dart';
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
    required String siteName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('labors').doc(laborId).update({
        'siteName': siteName,
      });

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

  /// Calculate and store pay period
  Future<bool> calculatePayPeriod({
    required String laborId,
    required DateTime startDate,
    required DateTime endDate,
    required double dailySalary,
  }) async {
    try {
      // Get all attendance records for the period
      final attendanceList = await getAttendanceForPeriod(
        laborId: laborId,
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate totals
      int totalDayShiftFull = 0;
      int totalDayShiftHalf = 0;
      int totalNightShiftFull = 0;
      int totalNightShiftHalf = 0;
      double totalWithdrawals = 0.0;

      for (final attendance in attendanceList) {
        if (attendance.dayShift == 'Full') totalDayShiftFull++;
        if (attendance.dayShift == 'Half') totalDayShiftHalf++;
        if (attendance.nightShift == 'Full') totalNightShiftFull++;
        if (attendance.nightShift == 'Half') totalNightShiftHalf++;
        totalWithdrawals += attendance.withdrawAmount;
      }

      // Calculate earnings (you can adjust the formula as needed)
      final totalEarned = (totalDayShiftFull * dailySalary) +
          (totalDayShiftHalf * dailySalary * 0.5) +
          (totalNightShiftFull * dailySalary) +
          (totalNightShiftHalf * dailySalary * 0.5);

      final netPay = totalEarned - totalWithdrawals;

      // Create pay period ID
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);
      final periodId = '${startStr}__$endStr';

      final payPeriod = PayPeriodModel(
        id: periodId,
        startDate: startDate,
        endDate: endDate,
        totalDayShiftFull: totalDayShiftFull,
        totalDayShiftHalf: totalDayShiftHalf,
        totalNightShiftFull: totalNightShiftFull,
        totalNightShiftHalf: totalNightShiftHalf,
        totalWithdrawals: totalWithdrawals,
        totalEarned: totalEarned,
        netPay: netPay,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('labors')
          .doc(laborId)
          .collection('payPeriods')
          .doc(periodId)
          .set(payPeriod.toJson());

      return true;
    } catch (e) {
      debugPrint('Error calculating pay period: $e');
      return false;
    }
  }

  /// Get pay periods for a labor
  Future<List<PayPeriodModel>> getPayPeriods({
    required String laborId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('labors')
          .doc(laborId)
          .collection('payPeriods')
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PayPeriodModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting pay periods: $e');
      return [];
    }
  }
}
