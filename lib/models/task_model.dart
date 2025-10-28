import 'package:uuid/uuid.dart';

class TaskModel {
  String id; // primary key
  int userId; // foreign key
  String listId; // foreign key
  String description;
  String listType;
  DateTime? deadline;
  DateTime? time;
  List<String>? frequency;
  int completed;

  static const _uuid = Uuid();

  TaskModel({
    String? id,
    required this.userId,
    required this.listId,
    required this.description,
    required this.listType,
    this.deadline,
    this.time,
    this.frequency,
    required this.completed,
  }) : id = id ?? _uuid.v4();
}
