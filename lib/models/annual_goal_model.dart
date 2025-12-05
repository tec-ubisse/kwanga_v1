import 'package:uuid/uuid.dart';

class AnnualGoalModel {
  final String id;
  final int userId;
  final String visionId;
  final String description;
  final int year;
  final bool isDeleted;
  final bool isSynced;

  AnnualGoalModel({
    String? id,
    required this.userId,
    required this.visionId,
    required this.description,
    required this.year,
    required this.isDeleted,
    required this.isSynced,
  }) : id = id ?? const Uuid().v4();

  static AnnualGoalModel empty(int year) {
    return AnnualGoalModel(
      id: "empty-$year",
      userId: -1,
      visionId: "",
      description: "",
      year: year,
      isDeleted: false,
      isSynced: false,
    );
  }

  bool get isEmpty => id.startsWith("empty-");

  bool get isNotEmpty => !isEmpty;

  AnnualGoalModel copyWith({
    String? id,
    int? userId,
    String? visionId,
    String? description,
    int? year,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return AnnualGoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      visionId: visionId ?? this.visionId,
      description: description ?? this.description,
      year: year ?? this.year,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'vision_id': visionId,
      'description': description,
      'year': year,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory AnnualGoalModel.fromMap(Map<String, dynamic> map) {
    return AnnualGoalModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      visionId: map['vision_id'] as String,
      description: map['description'] as String,
      year: map['year'] as int,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }
}
