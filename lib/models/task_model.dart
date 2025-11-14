import 'package:uuid/uuid.dart';
import 'dart:convert';

class TaskModel {
  final String id;
  final int userId;
  final String listId;
  final String description;
  final String listType;
  final DateTime? deadline;
  final DateTime? time;
  final List<String>? frequency;
  final int completed; // 0 for false, 1 for true

  TaskModel({
    String? id,
    required this.userId,
    required this.listId,
    required this.description,
    required this.listType,
    this.deadline,
    this.time,
    this.frequency,
    this.completed = 0,
  }) : id = id ?? const Uuid().v4();

  TaskModel copyWith({
    String? id,
    int? userId,
    String? listId,
    String? description,
    String? listType,
    DateTime? deadline,
    DateTime? time,
    List<String>? frequency,
    int? completed,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listId: listId ?? this.listId,
      description: description ?? this.description,
      listType: listType ?? this.listType,
      deadline: deadline ?? this.deadline,
      time: time ?? this.time,
      frequency: frequency ?? this.frequency,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'list_id': listId,
      'description': description,
      'listType': listType,
      'deadline': deadline?.millisecondsSinceEpoch,
      'time': time != null ? time!.hour * 60 * 60 * 1000 + time!.minute * 60 * 1000 : null,
      'frequency': frequency != null ? jsonEncode(frequency) : null,
      'completed': completed,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      listId: map['list_id'] as String,
      description: map['description'] as String,
      listType: map['listType'] as String,
      deadline: map['deadline'] != null ? DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int) : null,
      time: map['time'] != null ? DateTime(0, 1, 1).add(Duration(milliseconds: map['time'] as int)) : null,
      frequency: map['frequency'] != null ? List<String>.from(jsonDecode(map['frequency'] as String)) : null,
      completed: map['completed'] as int,
    );
  }
}
