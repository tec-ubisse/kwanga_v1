import 'package:sqflite/sqflite.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'package:kwanga/models/life_area_model.dart';

class LifeAreaDao {
  final databaseHelper = DatabaseHelper.instance;

  /// INSERT (user-created or system if caller sets isSystem true)
  Future<void> insertLifeArea(LifeAreaModel area) async {
    final db = await databaseHelper.database;

    await db.insert(
      'life_areas',
      area.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// GET all (system + user) not deleted for a user
  Future<List<LifeAreaModel>> getLifeAreasForUser(int userId) async {
    final db = await databaseHelper.database;

    final data = await db.query(
      'life_areas',
      where: '(user_id = ? OR is_system = 1) AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'is_system DESC, designation ASC',
    );

    return data.map((e) => LifeAreaModel.fromMap(e)).toList();
  }

  /// GET only system areas
  Future<List<LifeAreaModel>> getSystemLifeAreas() async {
    final db = await databaseHelper.database;

    final data = await db.query(
      'life_areas',
      where: 'is_system = 1 AND is_deleted = 0',
      orderBy: 'designation ASC',
    );

    return data.map((e) => LifeAreaModel.fromMap(e)).toList();
  }

  /// GET only user's own (not system)
  Future<List<LifeAreaModel>> getUserLifeAreas(int userId) async {
    final db = await databaseHelper.database;

    final data = await db.query(
      'life_areas',
      where: 'user_id = ? AND is_deleted = 0 AND is_system = 0',
      whereArgs: [userId],
      orderBy: 'designation ASC',
    );

    return data.map((e) => LifeAreaModel.fromMap(e)).toList();
  }

  /// GET by id
  Future<LifeAreaModel?> getById(String id) async {
    final db = await databaseHelper.database;
    final rows = await db.query('life_areas', where: 'id = ?', whereArgs: [id]);

    if (rows.isEmpty) return null;
    return LifeAreaModel.fromMap(rows.first);
  }

  /// UPDATE (only editable fields)
  Future<void> updateLifeArea(LifeAreaModel area) async {
    final db = await databaseHelper.database;

    await db.update(
      'life_areas',
      {
        'designation': area.designation,
        'icon_path': area.iconPath,
        'is_deleted': area.isDeleted ? 1 : 0,
        'is_synced': area.isSynced ? 1 : 0,
        // is_system and user_id normally not updated here,
        // but if you want to change them you can include them.
      },
      where: 'id = ?',
      whereArgs: [area.id],
    );
  }

  /// Soft delete (mark as deleted)
  Future<void> softDeleteLifeArea(String id) async {
    final db = await databaseHelper.database;

    await db.update(
      'life_areas',
      {'is_deleted': 1},
      where: 'id = ? AND is_system = 0', // evita apagar áreas de sistema
      whereArgs: [id],
    );
  }

  /// Restore a soft-deleted area
  Future<void> restoreLifeArea(String id) async {
    final db = await databaseHelper.database;

    await db.update(
      'life_areas',
      {'is_deleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark synced
  Future<void> markAsSynced(String id) async {
    final db = await databaseHelper.database;

    await db.update(
      'life_areas',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard delete (use with cuidado)
  Future<void> deleteLifeArea(String id) async {
    final db = await databaseHelper.database;

    await db.delete(
      'life_areas',
      where: 'id = ? AND is_system = 0',
      whereArgs: [id],
    );
  }
}
