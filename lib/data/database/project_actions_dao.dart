import 'package:sqflite/sqflite.dart';
import '../../models/project_action_model.dart';
import '../database/database_helper.dart';

class ProjectActionsDao {
  final dbHelper = DatabaseHelper.instance;
  static const String _tableName = 'project_actions';

  // CREATE
  Future<void> createAction(ProjectActionModel action) async {
    final db = await dbHelper.database;
    await db.insert(
      _tableName,
      action.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ - all actions for a project
  Future<List<ProjectActionModel>> getActionsByProjectId(String projectId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'project_id = ? AND is_deleted = 0',
      whereArgs: [projectId],
      orderBy: 'order_index ASC',  // ✔ CORRIGIDO
    );

    return List.generate(
      maps.length,
          (i) => ProjectActionModel.fromMap(maps[i]),
    );
  }

  // READ single
  Future<ProjectActionModel?> getActionById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) return ProjectActionModel.fromMap(maps.first);
    return null;
  }

  // UPDATE
  Future<int> updateAction(ProjectActionModel action) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      action.toMap(),
      where: 'id = ?',
      whereArgs: [action.id],
    );
  }

  // SOFT DELETE
  Future<int> deleteAction(String id) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      {
        'is_deleted': 1,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sync helpers
  Future<List<ProjectActionModel>> getUnsyncedActions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'is_synced = 0',
    );
    return List.generate(
      maps.length,
          (i) => ProjectActionModel.fromMap(maps[i]),
    );
  }

  Future<void> markAsSynced(String id) async {
    final db = await dbHelper.database;
    await db.update(
      _tableName,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UPDATE ORDER
  Future<void> updateActionOrder(String id, int newIndex) async {
    final db = await dbHelper.database;
    await db.update(
      _tableName,
      {'order_index': newIndex},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setActionCompletion(String actionId, bool isDone) async {
    final db = await dbHelper.database;

    await db.update(
      'project_actions',
      {'is_done': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [actionId],
    );
  }

}
