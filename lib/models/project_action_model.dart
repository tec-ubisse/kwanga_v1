import 'package:uuid/uuid.dart';

class ProjectActionModel {
  final String id;
  final String projectId;
  final String description;
  final bool isDone;
  final bool isDeleted;
  final bool isSynced;

  /// NOVO: índice para ordenação persistente
  final int orderIndex;

  ProjectActionModel({
    String? id,
    required this.projectId,
    required this.description,
    this.isDone = false,
    this.isDeleted = false,
    this.isSynced = false,
    this.orderIndex = 0,
  }) : id = id ?? const Uuid().v4();

  static ProjectActionModel empty(String projectId) {
    return ProjectActionModel(
      id: 'empty-$projectId',
      projectId: projectId,
      description: '',
      isDone: false,
      isDeleted: false,
      isSynced: false,
      orderIndex: 0,
    );
  }

  bool get isEmpty => id.startsWith('empty-');
  bool get isNotEmpty => !isEmpty;

  ProjectActionModel copyWith({
    String? id,
    String? projectId,
    String? description,
    bool? isDone,
    bool? isDeleted,
    bool? isSynced,
    int? orderIndex,
  }) {
    return ProjectActionModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'description': description,
      'is_done': isDone ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'order_index': orderIndex, // NOVO
    };
  }

  factory ProjectActionModel.fromMap(Map<String, dynamic> map) {
    return ProjectActionModel(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      description: map['description'] as String? ?? '',
      isDone: (map['is_done'] ??   0) == 1,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
      orderIndex: map['order_index'] as int? ?? 0, // NOVO
    );
  }

  @override
  String toString() {
    return 'ProjectActionModel(id: $id, projectId: $projectId, description: $description, isDone: $isDone, orderIndex: $orderIndex)';
  }
}
