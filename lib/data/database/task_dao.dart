import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class TaskDao {
  final databaseHelper = DatabaseHelper.instance;
  static const _uuid = Uuid();

  // CREATE
  Future<void> insert(TaskModel task) async {
    final db = await databaseHelper.database;
    await db.insert('tasks', {
      'id':  _uuid.v4(),
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
      'completed': 0,
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
        'deadline': task.deadline?.millisecondsSinceEpoch,
        'time': task.time?.millisecondsSinceEpoch,
        'frequency': task.frequency != null ? jsonEncode(task.frequency) : null,
        'completed': task.completed,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> updateTaskStatus(String taskId, int status) async {
    final db = await databaseHelper.database;
    return await db.update(
      'tasks',
      {'completed':  status},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // DELETE
  Future<int> deleteTask(String id) async {
    final db = await databaseHelper.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
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
      completed: row['completed'] as int,
    );
  }
}
