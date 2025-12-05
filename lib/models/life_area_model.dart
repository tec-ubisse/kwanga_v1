import 'package:uuid/uuid.dart';

class LifeAreaModel {
  final String id;
  final int userId;
  final String designation;
  final String iconPath;
  final bool isSystem;
  final bool isDeleted;
  final bool isSynced;

  LifeAreaModel({
    String? id,
    required this.userId,
    required this.designation,
    required this.iconPath,
    this.isSystem = false,
    this.isDeleted = false,
    this.isSynced = false,
  }) : id = id ?? const Uuid().v4();

  LifeAreaModel copyWith({
    String? id,
    int? userId,
    String? designation,
    String? iconPath,
    bool? isSystem,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return LifeAreaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      designation: designation ?? this.designation,
      iconPath: iconPath ?? this.iconPath,
      isSystem: isSystem ?? this.isSystem,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'designation': designation,
      'icon_path': iconPath,
      'is_system': isSystem ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory LifeAreaModel.fromMap(Map<String, dynamic> map) {
    return LifeAreaModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      designation: map['designation'] as String,
      iconPath: map['icon_path'] as String,
      isSystem: (map['is_system'] ?? 0) == 1,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }
}
