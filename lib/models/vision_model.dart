import 'package:uuid/uuid.dart';

class VisionModel {
  final String id;
  final int userId;
  final String lifeAreaId;
  final int conclusion;
  final String description;
  final bool isDeleted;
  final bool isSynced;

  VisionModel({
    String? id,
    required this.userId,
    required this.lifeAreaId,
    required this.conclusion,
    required this.description,
    required this.isDeleted,
    required this.isSynced,
  }) : this.id = id ?? const Uuid().v4();

  // Utility copyWith
  VisionModel copyWith({
    String? id,
    int? userId,
    String? lifeAreaId,
    int? conclusion,
    String? description,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return VisionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lifeAreaId: lifeAreaId ?? this.lifeAreaId,
      conclusion: conclusion ?? this.conclusion,
      description: description ?? this.description,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'life_area_id': lifeAreaId,
      'conclusion': conclusion,
      'description': description,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // Utility fromMap
  factory VisionModel.fromMap(Map<String, dynamic> map) {
    return VisionModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      lifeAreaId: map['life_area_id'] as String,
      conclusion: map['conclusion'] as int,
      description: map['description'] as String,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }
}