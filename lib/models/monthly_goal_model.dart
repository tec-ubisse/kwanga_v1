import 'package:uuid/uuid.dart';

class MonthlyGoalModel {
  final String id;
  final int userId;
  final String annualGoalsId;
  final String description;
  final int month;
  final bool isDeleted;
  final bool isSynced;

  MonthlyGoalModel({
    String? id,
    required this.userId,
    required this.annualGoalsId,
    required this.description,
    required this.month,
    required this.isDeleted,
    required this.isSynced,
  }) : id = id ?? const Uuid().v4();

  MonthlyGoalModel copyWith({
    String? id,
    int? userId,
    String? annualGoalsId,
    String? description,
    int? month,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return MonthlyGoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      annualGoalsId: annualGoalsId ?? this.annualGoalsId,
      description: description ?? this.description,
      month: month ?? this.month,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'annual_goals_id': annualGoalsId,
      'description': description,
      'month': month,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory MonthlyGoalModel.fromMap(Map<String, dynamic> map) {
    return MonthlyGoalModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      annualGoalsId: map['annual_goals_id'] as String,
      description: map['description'] as String,
      month: map['month'] as int,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }
}
