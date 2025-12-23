import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class LaborModel {
  const LaborModel({
    required this.id,
    required this.laborName,
    required this.work,
    required this.siteName,
    required this.salary,
    required this.createdAt,
    this.isActive = true,
  });

  factory LaborModel.fromJson(Map<String, dynamic> json) {
    return LaborModel(
      id: json['id'] as String,
      laborName: json['laborName'] as String,
      work: json['work'] as String,
      siteName: json['siteName'] as String,
      salary: (json['salary'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final String laborName;
  final String work;
  final String siteName;
  final double salary;
  final DateTime createdAt;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'laborName': laborName,
      'work': work,
      'siteName': siteName,
      'salary': salary,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  LaborModel copyWith({
    String? id,
    String? laborName,
    String? work,
    String? siteName,
    double? salary,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return LaborModel(
      id: id ?? this.id,
      laborName: laborName ?? this.laborName,
      work: work ?? this.work,
      siteName: siteName ?? this.siteName,
      salary: salary ?? this.salary,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}