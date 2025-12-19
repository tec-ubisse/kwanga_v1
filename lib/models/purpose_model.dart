import 'package:uuid/uuid.dart';

class PurposeModel {
  final String id;
  final int userId;
  final String lifeAreaId; // ← NOVO CAMPO
  final String description;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  final bool isSynced;

  PurposeModel({
    String? id,
    required this.userId,
    required this.lifeAreaId, // ← NOVO CAMPO OBRIGATÓRIO
    required this.description,
    int? createdAt,
    int? updatedAt,
    required this.isDeleted,
    required this.isSynced,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  static PurposeModel empty() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return PurposeModel(
      id: 'empty-purpose',
      userId: -1,
      lifeAreaId: '', // ← CAMPO VAZIO PARA PROPÓSITO VAZIO
      description: '',
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      isSynced: false,
    );
  }

  bool get isEmpty => id.startsWith('empty-');
  bool get isNotEmpty => !isEmpty;

  PurposeModel copyWith({
    String? id,
    int? userId,
    String? lifeAreaId, // ← ADICIONAR NO COPYWITH
    String? description,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return PurposeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lifeAreaId: lifeAreaId ?? this.lifeAreaId, // ← ADICIONAR AQUI
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'life_area_id': lifeAreaId, // ← ADICIONAR NO MAPA
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory PurposeModel.fromMap(Map<String, dynamic> map) {
    return PurposeModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      lifeAreaId: map['life_area_id'] as String, // ← ADICIONAR AQUI
      description: map['description'] as String,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }
}