import 'dart:convert';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TaskDao {
  final databaseHelper = DatabaseHelper.instance;

  // -------------------------------------------------------------
  // INSERT
  // -------------------------------------------------------------
  Future<void> insert(TaskModel task) async {
    final db = await databaseHelper.database;

    // ✅ SIMPLIFICADO: Não usar copyWith para evitar perder dados
    final map = task.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'tasks',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // -------------------------------------------------------------
  // GET BY ID
  // -------------------------------------------------------------
  Future<TaskModel?> getTaskById(String id) async {
    final db = await databaseHelper.database;

    final res = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) return null;
    return TaskModel.fromMap(res.first);
  }

  // -------------------------------------------------------------
  // GET BY USER
  // -------------------------------------------------------------
  Future<List<TaskModel>> getTaskByUserId(int userId) async {
    final db = await databaseHelper.database;

    final res = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return res.map(TaskModel.fromMap).toList();
  }

  // -------------------------------------------------------------
  // UPDATE FULL TASK
  // -------------------------------------------------------------
  Future<int> updateTask(TaskModel task) async {
    final db = await databaseHelper.database;

    final updated = task.copyWith(updatedAt: DateTime.now());

    return db.update(
      'tasks',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // -------------------------------------------------------------
  // UPDATE ONLY STATUS
  // -------------------------------------------------------------
  Future<int> updateTaskStatus(String taskId, int status) async {
    final db = await databaseHelper.database;

    return db.update(
      'tasks',
      {
        'completed': status,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // -------------------------------------------------------------
  // DELETE
  // -------------------------------------------------------------
  Future<int> deleteTask(String id) async {
    final db = await databaseHelper.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------------------------------------------------
  // GET BY LIST (NORMAL LISTS)
  // -------------------------------------------------------------
  Future<List<TaskModel>> getTasksByListId(String listId) async {
    final db = await databaseHelper.database;

    final res = await db.query(
      'tasks',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'created_at ASC',
    );

    return res.map(TaskModel.fromMap).toList();
  }

  // -------------------------------------------------------------
  // GET BY PROJECT (ORDER BY order_index!)
  // -------------------------------------------------------------
  Future<List<TaskModel>> getTasksByProjectId(String projectId) async {
    final db = await databaseHelper.database;

    final res = await db.query(
      'tasks',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'order_index ASC, created_at ASC',
    );

    return res.map(TaskModel.fromMap).toList();
  }

  // -------------------------------------------------------------
  // GET BY LINKED ACTION
  // -------------------------------------------------------------
  Future<List<TaskModel>> getTasksByLinkedActionId(String actionId) async {
    final db = await databaseHelper.database;

    final res = await db.query(
      'tasks',
      where: 'linked_action_id = ?',
      whereArgs: [actionId],
      orderBy: 'created_at ASC',
    );

    return res.map(TaskModel.fromMap).toList();
  }

  // -------------------------------------------------------------
  // TASK PROGRESS
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

  // -------------------------------------------------------------
  // UPDATE ORDER INDEX (para drag & drop)
  // -------------------------------------------------------------
  Future<int> updateOrderIndex({
    required String taskId,
    required int newIndex,
  }) async {
    final db = await databaseHelper.database;

    return await db.update(
      'tasks',
      {
        'order_index': newIndex,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }
}