import 'package:uuid/uuid.dart';

class LifeAreaModel {
  final String id;
  final int? userId; // 🔥 AGORA PODE SER NULL
  final String designation;
  final String iconPath;

  final bool isSystem;
  final bool isDeleted;
  final bool isSynced;

  final int order;

  final DateTime createdAt;
  final DateTime updatedAt;

  LifeAreaModel({
    String? id,
    this.userId, // 🔥 não é mais required
    required this.designation,
    required this.iconPath,
    this.isSystem = false,
    this.isDeleted = false,
    this.isSynced = false,
    this.order = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  LifeAreaModel copyWith({
    String? id,
    int? userId,
    bool clearUserId = false, // útil para sistema
    String? designation,
    String? iconPath,
    bool? isSystem,
    bool? isDeleted,
    bool? isSynced,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LifeAreaModel(
      id: id ?? this.id,
      userId: clearUserId ? null : userId ?? this.userId,
      designation: designation ?? this.designation,
      iconPath: iconPath ?? this.iconPath,
      isSystem: isSystem ?? this.isSystem,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId, // 🔥 pode ser NULL
      'designation': designation,
      'icon_path': iconPath,
      'is_system': isSystem ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'order_index': order,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory LifeAreaModel.fromMap(Map<String, dynamic> map) {
    return LifeAreaModel(
      id: map['id'] as String,
      userId: map['user_id'] as int?, // 🔥 CAST SEGURO
      designation: map['designation'] as String,
      iconPath: map['icon_path'] as String,
      isSystem: (map['is_system'] ?? 0) == 1,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
      order: map['order_index'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : DateTime.now(),
    );
  }
}
