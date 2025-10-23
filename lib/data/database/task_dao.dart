import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'dart:convert';

class TaskDao {
  final databaseHelper = DatabaseHelper.instance;

  // CREATE
  Future<void> insert(TaskModel task) async {
    final db = await databaseHelper.database;
    await db.insert('tasks', {
      'id': task.id,
      'user_id': task.userId,
      'list_id': task.listId,
      'description': task.description,
      'listType': task.listType,
      'deadline': task.deadline != null
          ? DateTime(
              task.deadline!.year,
              task.deadline!.month,
              task.deadline!.day,
            ).millisecondsSinceEpoch
          : null,
      'time': task.time != null
          ? task.time!.hour * 60 * 60 * 1000 + task.time!.minute * 60 * 1000
          : null,
      'frequency': task.frequency != null ? jsonEncode(task.frequency) : null,
    });
  }

  // READ ALL BY USER
  Future<List<TaskModel>> getTaskByUserId(int userId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((row) => _taskFromRow(row)).toList();
  }

  // UPDATE
  Future<int> updateTask(TaskModel task) async {
    final db = await databaseHelper.database;
    return await db.update(
      'tasks',
      {
        'description': task.description,
        'listType': task.listType,
        'deadline': task.deadline != null
            ? DateTime(
                task.deadline!.year,
                task.deadline!.month,
                task.deadline!.day,
              ).millisecondsSinceEpoch
            : null,
        'time': task.time != null
            ? task.time!.hour * 60 * 60 * 1000 + task.time!.minute * 60 * 1000
            : null,
        'frequency': task.frequency != null ? jsonEncode(task.frequency) : null,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [task.id, task.userId],
    );
  }

  // DELETE
  Future<int> deleteTask(String id, int userId) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // ---------------------------
  // HELPER: converter row do SQLite para TaskModel
  // ---------------------------
  TaskModel _taskFromRow(Map<String, dynamic> row) {
    return TaskModel(
      id: row['id'] as String,
      userId: row['user_id'] as int,
      listId: row['list_id'] as String,
      description: row['description'] as String,
      listType: row['listType'] as String,
      deadline: row['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['deadline'] as int)
          : null,
      time: row['time'] != null
          ? DateTime(0, 1, 1).add(Duration(milliseconds: row['time'] as int))
          : null,
      frequency: row['frequency'] != null
          ? List<String>.from(jsonDecode(row['frequency'] as String))
          : null,
    );
  }
}
