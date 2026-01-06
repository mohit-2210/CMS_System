import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String laborId;
  final String siteId;
  final String siteName;
  final String status; // 'active', 'inactive'
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;

  AssignmentModel({
    required this.id,
    required this.laborId,
    required this.siteId,
    required this.siteName,
    required this.status,
    required this.createdAt,
    this.startDate,
    this.endDate,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] ?? '',
      laborId: json['laborId'] ?? '',
      siteId: json['siteId'] ?? '',
      siteName: json['siteName'] ?? '',
      status: json['status'] ?? 'inactive',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      startDate: json['startDate'] != null ? (json['startDate'] as Timestamp).toDate() : null,
      endDate: json['endDate'] != null ? (json['endDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'laborId': laborId,
      'siteId': siteId,
      'siteName': siteName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    };
  }
}
