import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class AttendanceModel {
  const AttendanceModel({
    required this.date,
    required this.dayShift,
    required this.nightShift,
    required this.withdrawAmount,
    required this.siteName,
    required this.adminName,
    required this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      date: json['date'] as String,
      dayShift: json['dayShift'] as String,
      nightShift: json['nightShift'] as String,
      withdrawAmount: (json['withdrawAmount'] as num?)?.toDouble() ?? 0.0,
      siteName: json['siteName'] as String? ?? '',
      adminName: json['adminName'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  final String date; // YYYY-MM-DD format
  final String dayShift; // "Full" | "Half" | "None"
  final String nightShift; // "Full" | "Half" | "None"
  final double withdrawAmount;
  final String siteName;
  final String adminName;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayShift': dayShift,
      'nightShift': nightShift,
      'withdrawAmount': withdrawAmount,
      'siteName': siteName,
      'adminName': adminName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AttendanceModel copyWith({
    String? date,
    String? dayShift,
    String? nightShift,
    double? withdrawAmount,
    String? siteName,
    String? adminName,
    DateTime? createdAt,
  }) {
    return AttendanceModel(
      date: date ?? this.date,
      dayShift: dayShift ?? this.dayShift,
      nightShift: nightShift ?? this.nightShift,
      withdrawAmount: withdrawAmount ?? this.withdrawAmount,
      siteName: siteName ?? this.siteName,
      adminName: adminName ?? this.adminName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
