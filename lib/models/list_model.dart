import 'package:uuid/uuid.dart';

class ListModel {
  final String id;
  final int userId;
  final String listType;
  final String description;
  final bool isDeleted;
  final bool isSynced;

  ListModel({
    String? id,
    required this.userId,
    required this.listType,
    required this.description,
    this.isDeleted = false,
    this.isSynced = false,
  }) : id = id ?? const Uuid().v4();

  // 1. Adicionado o método copyWith
  ListModel copyWith({
    String? id,
    int? userId,
    String? listType,
    String? description,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return ListModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listType: listType ?? this.listType,
      description: description ?? this.description,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // 2. Adicionado o método toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'list_type': listType,
      'description': description,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory ListModel.fromMap(Map<String, dynamic> map) {
    return ListModel(
      id: map['id'] as String,
      userId: map['user_id'] as int, 
      listType: map['list_type'] as String,
      description: map['description'] as String,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }
}
