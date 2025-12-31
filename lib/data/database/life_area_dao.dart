import 'package:sqflite/sqflite.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'package:kwanga/models/life_area_model.dart';

class LifeAreaDao {
  final databaseHelper = DatabaseHelper.instance;

  // ----------------------------------------------------------
  // INSERT / UPSERT
  // ----------------------------------------------------------
  Future<void> insertLifeArea(LifeAreaModel area) async {
    final db = await databaseHelper.database;

    // 🔒 Blindagem lógica (extra)
    if (area.isSystem && area.userId != null) {
      throw Exception('Área do sistema não pode ter userId');
    }
    if (!area.isSystem && area.userId == null) {
      throw Exception('Área do utilizador precisa de userId');
    }

    await db.insert(
      'life_areas',
      area.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // GET — system + user (ORDERED)
  // ----------------------------------------------------------
  Future<List<LifeAreaModel>> getLifeAreasForUser(int userId) async {
    final db = await databaseHelper.database;

    final data = await db.rawQuery(
      '''
      SELECT * FROM life_areas
      WHERE is_deleted = 0
        AND (user_id IS NULL OR user_id = ?)
      ORDER BY order_index ASC
      ''',
      [userId],
    );

    return data.map(LifeAreaModel.fromMap).toList();
  }

  // ----------------------------------------------------------
  // GET — system only (ORDERED)
  // ----------------------------------------------------------
  Future<List<LifeAreaModel>> getSystemLifeAreas() async {
    final db = await databaseHelper.database;

    final data = await db.query(
      'life_areas',
      where: 'user_id IS NULL AND is_deleted = 0',
      orderBy: 'order_index ASC',
    );

    return data.map(LifeAreaModel.fromMap).toList();
  }

  // ----------------------------------------------------------
  // GET — user only (ORDERED)
  // ----------------------------------------------------------
  Future<List<LifeAreaModel>> getUserLifeAreas(int userId) async {
    final db = await databaseHelper.database;

    final data = await db.query(
      'life_areas',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'order_index ASC',
    );

    return data.map(LifeAreaModel.fromMap).toList();
  }

  // ----------------------------------------------------------
  // GET by id
  // ----------------------------------------------------------
  Future<LifeAreaModel?> getById(String id) async {
    final db = await databaseHelper.database;

    final rows = await db.query(
      'life_areas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) return null;
    return LifeAreaModel.fromMap(rows.first);
  }

  // ----------------------------------------------------------
  // UPDATE (fields + timestamp + sync)
  // ----------------------------------------------------------
  Future<void> updateLifeArea(LifeAreaModel area) async {
    final db = await databaseHelper.database;

    await db.update(
      'life_areas',
      {
        'designation': area.designation,
        'icon_path': area.iconPath,
        'is_deleted': area.isDeleted ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [area.id],
    );
  }

  // ----------------------------------------------------------
  // REORDER — update order_index in batch
  // ----------------------------------------------------------
  Future<void> updateOrder(List<LifeAreaModel> areas) async {
    final db = await databaseHelper.database;
    final batch = db.batch();

    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < areas.length; i++) {
      batch.update(
        'life_areas',
        {
          'order_index': i,
          'updated_at': now,
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [areas[i].id],
      );
    }

    await batch.commit(noResult: true);
  }

  // ----------------------------------------------------------
  // SOFT DELETE (user only)
  // ----------------------------------------------------------
  Future<void> softDeleteLifeArea(String id) async {
    final db = await databaseHelper.database;

    await db.update(
      'life_areas',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ? AND user_id IS NOT NULL',
      whereArgs: [id],
    );
  }

  // ----------------------------------------------------------
  // RESTORE
  // ----------------------------------------------------------
  Future<void> restoreLifeArea(String id) async {
    final db = await databaseHelper.database;

    await db.update(
      'life_areas',
      {
        'is_deleted': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------------------------------------------
  // MARK AS SYNCED
  // ----------------------------------------------------------
  Future<void> markAsSynced(String id) async {
    final db = await databaseHelper.database;

    await db.update(
      'life_areas',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------------------------------------------
  // HARD DELETE (user only — use with care)
  // ----------------------------------------------------------
  Future<void> deleteLifeArea(String id) async {
    final db = await databaseHelper.database;

    await db.delete(
      'life_areas',
      where: 'id = ? AND user_id IS NOT NULL',
      whereArgs: [id],
    );
  }
}
