import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class TaskDao {
  final databaseHelper = DatabaseHelper.instance;

  // -------------------------------------------------------------
  // INSERT
  // -------------------------------------------------------------
  Future<void> insert(TaskModel task) async {
    final db = await databaseHelper.database;

    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // -------------------------------------------------------------
  // SELECT BY USER
  // -------------------------------------------------------------
  Future<List<TaskModel>> getTaskByUserId(int userId) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((e) => _taskFromRow(e)).toList();
  }

  // -------------------------------------------------------------
  // UPDATE FULL TASK
  // -------------------------------------------------------------
  Future<int> updateTask(TaskModel task) async {
    final db = await databaseHelper.database;

    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // -------------------------------------------------------------
  // UPDATE STATUS ONLY
  // -------------------------------------------------------------
  Future<int> updateTaskStatus(String taskId, int status) async {
    final db = await databaseHelper.database;

    return await db.update(
      'tasks',
      {'completed': status},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // -------------------------------------------------------------
  // DELETE
  // -------------------------------------------------------------
  Future<int> deleteTask(String id) async {
    final db = await databaseHelper.database;

    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------------------------------------------------
  // GET BY ID
  // -------------------------------------------------------------
  Future<TaskModel?> getTaskById(String id) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return _taskFromRow(result.first);
  }

  // -------------------------------------------------------------
  // PARSE DB ROW INTO MODEL
  // -------------------------------------------------------------
  TaskModel _taskFromRow(Map<String, dynamic> row) {
    return TaskModel(
      id: row['id'],
      userId: row['user_id'],
      listId: row['list_id'],
      description: row['description'],
      listType: row['listType'], // atenção ao nome no DB
      deadline: row['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['deadline'])
          : null,
      time: row['time'] != null
          ? DateTime(0, 1, 1).add(Duration(milliseconds: row['time']))
          : null,
      frequency: row['frequency'] != null
          ? List<String>.from(jsonDecode(row['frequency']))
          : null,
      completed: row['completed'],
      linkedActionId: row['linked_action_id'],
    );
  }

  // -------------------------------------------------------------
  // GET TASKS BY LIST
  // -------------------------------------------------------------
  Future<List<TaskModel>> getTasksByListId(String listId) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'tasks',
      where: 'list_id = ?',
      whereArgs: [listId],
    );

    return result.map((e) => _taskFromRow(e)).toList();
  }

  // -------------------------------------------------------------
  // GET TASKS BY LINKED ACTION
  // -------------------------------------------------------------
  Future<List<TaskModel>> getTasksByLinkedActionId(String actionId) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'tasks',
      where: 'linked_action_id = ?',
      whereArgs: [actionId],
    );

    return result.map((e) => _taskFromRow(e)).toList();
  }

  // -------------------------------------------------------------
  // GET PROGRESS BY LIST (raw query)
  // -------------------------------------------------------------
  Future<Map<String, int>> getTaskProgress(String listId) async {
    final db = await databaseHelper.database;

    final total = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM tasks WHERE list_id = ?',
        [listId],
      ),
    );

    final completed = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM tasks WHERE list_id = ? AND completed = 1',
        [listId],
      ),
    );

    return {
      'total': total ?? 0,
      'completed': completed ?? 0,
    };
  }
}
