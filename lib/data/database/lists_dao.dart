import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ListDao {
  final databaseHelper = DatabaseHelper.instance;

  // -------------------------------------------------------------
  // CREATE
  // -------------------------------------------------------------
  Future<int> insert(ListModel list) async {
    final db = await databaseHelper.database;

    return await db.insert(
      'lists',
      {
        'id': list.id,
        'user_id': list.userId,
        'list_type': list.listType,
        'description': list.description,
        'is_deleted': list.isDeleted ? 1 : 0,
        'is_synced': list.isSynced ? 1 : 0,
        'is_project': list.isProject ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // -------------------------------------------------------------
  // READ ALL BY USER
  // -------------------------------------------------------------
  Future<List<ListModel>> getAllByUser(
      int userId, {
        bool excludeProject = true,
      }) async {
    final db = await databaseHelper.database;

    final where = excludeProject
        ? 'user_id = ? AND is_project = 0 AND is_deleted = 0'
        : 'user_id = ? AND is_deleted = 0';

    final res = await db.query(
      'lists',
      where: where,
      whereArgs: [userId],
      orderBy: excludeProject ? 'description ASC' : 'is_project DESC, description ASC',
    );

    return res.map((e) => ListModel.fromMap(e)).toList();
  }

  // -------------------------------------------------------------
  // RESTORE
  // -------------------------------------------------------------
  Future<int> restore(String id, int userId) async {
    final db = await databaseHelper.database;

    return await db.update(
      'lists',
      {
        'is_deleted': 0,
        'is_synced': 0,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // -------------------------------------------------------------
  // READ DESCRIPTIONS ONLY
  // -------------------------------------------------------------
  Future<List<ListModel>> getDescriptionsByUser(int userId) async {
    final db = await databaseHelper.database;

    final maps = await db.query(
      'lists',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'description ASC',
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  // -------------------------------------------------------------
  // UPDATE
  // -------------------------------------------------------------
  Future<int> update(ListModel list) async {
    final db = await databaseHelper.database;

    return db.update(
      'lists',
      {
        'list_type': list.listType,
        'description': list.description,
        'is_deleted': list.isDeleted ? 1 : 0,
        'is_synced': 0,
        'is_project': list.isProject ? 1 : 0,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [list.id, list.userId],
    );
  }

  // -------------------------------------------------------------
  // SOFT DELETE
  // -------------------------------------------------------------
  Future<int> delete(String id, int userId) async {
    final db = await databaseHelper.database;

    return await db.update(
      'lists',
      {
        'is_deleted': 1,
        'is_synced': 0,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // -------------------------------------------------------------
  // DELETE ALL BY USER
  // -------------------------------------------------------------
  Future<int> deleteAllByUser(int userId) async {
    final db = await databaseHelper.database;

    return await db.delete(
      'lists',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // -------------------------------------------------------------
  // GET PENDING SYNC
  // -------------------------------------------------------------
  Future<List<ListModel>> getPendingSync() async {
    final db = await databaseHelper.database;

    final data = await db.query(
      'lists',
      where: 'is_synced = 0',
    );

    return data.map((e) => ListModel.fromMap(e)).toList();
  }

  // -------------------------------------------------------------
  // MARK AS SYNCED
  // -------------------------------------------------------------
  Future<void> markAsSynced(String id) async {
    final db = await databaseHelper.database;

    await db.update(
      'lists',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------------------------------------------------
// READ ONE BY ID
// -------------------------------------------------------------
  Future<ListModel?> getListById(String id) async {
    final db = await databaseHelper.database;

    final res = await db.query(
      'lists',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (res.isEmpty) return null;
    return ListModel.fromMap(res.first);
  }

}
