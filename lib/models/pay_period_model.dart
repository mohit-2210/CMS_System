import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class PayPeriodModel {
  const PayPeriodModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalDayShiftFull,
    required this.totalDayShiftHalf,
    required this.totalNightShiftFull,
    required this.totalNightShiftHalf,
    required this.totalWithdrawals,
    required this.totalEarned,
    required this.netPay,
    required this.createdAt,
  });

  factory PayPeriodModel.fromJson(Map<String, dynamic> json) {
    return PayPeriodModel(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalDayShiftFull: json['totalDayShiftFull'] as int? ?? 0,
      totalDayShiftHalf: json['totalDayShiftHalf'] as int? ?? 0,
      totalNightShiftFull: json['totalNightShiftFull'] as int? ?? 0,
      totalNightShiftHalf: json['totalNightShiftHalf'] as int? ?? 0,
      totalWithdrawals: (json['totalWithdrawals'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
      netPay: (json['netPay'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  final String id; // format: YYYY-MM-DD__YYYY-MM-DD
  final DateTime startDate;
  final DateTime endDate;
  final int totalDayShiftFull;
  final int totalDayShiftHalf;
  final int totalNightShiftFull;
  final int totalNightShiftHalf;
  final double totalWithdrawals;
  final double totalEarned;
  final double netPay;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDayShiftFull': totalDayShiftFull,
      'totalDayShiftHalf': totalDayShiftHalf,
      'totalNightShiftFull': totalNightShiftFull,
      'totalNightShiftHalf': totalNightShiftHalf,
      'totalWithdrawals': totalWithdrawals,
      'totalEarned': totalEarned,
      'netPay': netPay,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PayPeriodModel copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDayShiftFull,
    int? totalDayShiftHalf,
    int? totalNightShiftFull,
    int? totalNightShiftHalf,
    double? totalWithdrawals,
    double? totalEarned,
    double? netPay,
    DateTime? createdAt,
  }) {
    return PayPeriodModel(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDayShiftFull: totalDayShiftFull ?? this.totalDayShiftFull,
      totalDayShiftHalf: totalDayShiftHalf ?? this.totalDayShiftHalf,
      totalNightShiftFull: totalNightShiftFull ?? this.totalNightShiftFull,
      totalNightShiftHalf: totalNightShiftHalf ?? this.totalNightShiftHalf,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      totalEarned: totalEarned ?? this.totalEarned,
      netPay: netPay ?? this.netPay,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
