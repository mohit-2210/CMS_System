// lib/services/attendance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    await _firestore.collection('attendances').add({
      'siteName': siteName,
      'laborId': laborId,
      'laborName': laborName,
      'date': Timestamp.fromDate(date),
      'dayShift': dayShift,
      'nightShift': nightShift,
      'withdrawAmount': withdrawAmount,
      'paymentMode': paymentMode,
      'adminName': adminName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}