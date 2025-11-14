import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/list_type_utils.dart';

class ListDao {
  final databaseHelper = DatabaseHelper.instance;

  // CREATE
  Future<int> insert(ListModel list) async {
    final db = await databaseHelper.database;
    return await db.insert(
      'lists',
      {
        'id': list.id,
        'user_id': list.userId,
        'list_type': normalizeListType(list.listType),   // ✔ sempre normalizado
        'description': list.description,
        'is_deleted': list.isDeleted ? 1 : 0,
        'is_synced': list.isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // READ ALL
  Future<List<ListModel>> getAllByUser(int userId) async {
    final db = await databaseHelper.database;
    final data = await db.query(
      'lists',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
    );

    return data.map((e) {
      return ListModel(
        id: e['id'] as String,
        userId: e['user_id'] as int,
        listType: normalizeListType(e['list_type'] as String),  // ✔ normalizado
        description: e['description'] as String,
        isDeleted: (e['is_deleted'] ?? 0) == 1,
        isSynced: (e['is_synced'] ?? 0) == 1,
      );
    }).toList();
  }

  // RESTORE
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

  // NORMALIZE DATABASE (executado no main)
  Future<void> normalizeAllListTypes() async {
    final db = await databaseHelper.database;
    final rows = await db.query('lists');

    for (final row in rows) {
      final id = row['id'];
      final rawType = row['list_type'];
      final oldType = (rawType ?? '').toString().trim();

      // sem tipo → fallback seguro
      final normalized =
      oldType.isEmpty ? 'entry' : normalizeListType(oldType);

      if (normalized != oldType) {
        await db.update(
          'lists',
          {'list_type': normalized},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  // READ DESCRIPTIONS
  Future<List<ListModel>> getDescriptionsByUser(int userId) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'lists',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return maps.map((map) {
      return ListModel(
        id: map['id'] as String,
        userId: map['user_id'] as int,
        listType: normalizeListType(map['list_type'] as String), // ✔ aqui também
        description: map['description'] as String,
        isDeleted: (map['is_deleted'] ?? 0) == 1,
        isSynced: (map['is_synced'] ?? 0) == 1,
      );
    }).toList();
  }

  // UPDATE
  Future<int> update(ListModel list) async {
    final db = await databaseHelper.database;
    return db.update(
      'lists',
      {
        'list_type': normalizeListType(list.listType),  // ✔ normalizado na escrita
        'description': list.description,
        'is_synced': 0,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [list.id, list.userId],
    );
  }

  // DELETE (soft delete)
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

  Future<int> deleteAllByUser(int userId) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'lists',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // GET PENDING SYNC
  Future<List<ListModel>> getPendingSync() async {
    final db = await databaseHelper.database;
    final data = await db.query(
      'lists',
      where: 'is_synced = 0',
    );

    return data.map((e) {
      return ListModel(
        id: e['id'] as String,
        userId: e['user_id'] as int,
        listType: normalizeListType(e['list_type'] as String), // ✔ normalizado
        description: e['description'] as String,
        isDeleted: (e['is_deleted'] ?? 0) == 1,
        isSynced: (e['is_synced'] ?? 0) == 1,
      );
    }).toList();
  }

  Future<void> markAsSynced(String id) async {
    final db = await databaseHelper.database;
    await db.update(
      'lists',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
