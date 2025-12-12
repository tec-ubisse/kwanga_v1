import 'dart:convert';

import 'package:uuid/uuid.dart';

class TaskModel {
  final String id;

  final int userId;
  final String listId;
  final String? projectId;

  final String description;
  final String listType;

  final DateTime? deadline;
  final DateTime? time;
  final List<String>? frequency;

  final int completed;
  final int? orderIndex;

  final String? linkedActionId;

  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    String? id,
    required this.userId,
    required this.listId,
    this.projectId,  // ✅ REMOVIDO 'required'
    required this.description,
    required this.listType,
    this.deadline,
    this.time,
    this.frequency,
    this.completed = 0,
    this.linkedActionId,
    this.orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    int? userId,
    String? listId,
    String? projectId,
    String? description,
    String? listType,
    DateTime? deadline,
    DateTime? time,
    List<String>? frequency,
    int? completed,
    String? linkedActionId,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listId: listId ?? this.listId,
      projectId: projectId ?? this.projectId,  // ✅ CORRIGIDO
      description: description ?? this.description,
      listType: listType ?? this.listType,
      deadline: deadline ?? this.deadline,
      time: time ?? this.time,
      frequency: frequency ?? this.frequency,
      completed: completed ?? this.completed,
      linkedActionId: linkedActionId ?? this.linkedActionId,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'list_id': listId,
      'project_id': projectId,
      'description': description,
      'listType': listType,
      'deadline': deadline?.millisecondsSinceEpoch,
      'time': time != null ? time!.hour * 3600000 + time!.minute * 60000 : null,
      'frequency': frequency != null ? jsonEncode(frequency) : null,
      'completed': completed,
      'linked_action_id': linkedActionId,
      'order_index': orderIndex,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      userId: map['user_id'],
      listId: map['list_id'],
      projectId: map['project_id'],
      description: map['description'],
      listType: map['listType'],
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'])
          : null,
      time: map['time'] != null
          ? DateTime(0, 1, 1).add(Duration(milliseconds: map['time']))
          : null,
      frequency: map['frequency'] != null
          ? List<String>.from(jsonDecode(map['frequency']))
          : null,
      completed: map['completed'] ?? 0,
      linkedActionId: map['linked_action_id'],
      orderIndex: map['order_index'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}