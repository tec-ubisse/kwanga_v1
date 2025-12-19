import 'package:sqflite/sqflite.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'package:kwanga/models/purpose_model.dart';

class PurposeDao {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  // ----------------------------------------------------------
  // GET – todos os propósitos do utilizador
  // ----------------------------------------------------------
  Future<List<PurposeModel>> getByUser(int userId) async {
    final db = await _db;

    final result = await db.query(
      'purposes',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return result.map(PurposeModel.fromMap).toList();
  }

  // ----------------------------------------------------------
  // GET – por área da vida
  // ----------------------------------------------------------
  Future<List<PurposeModel>> getByLifeArea(
      int userId,
      String lifeAreaId,
      ) async {
    final db = await _db;

    final result = await db.query(
      'purposes',
      where: 'user_id = ? AND life_area_id = ? AND is_deleted = 0',
      whereArgs: [userId, lifeAreaId],
      orderBy: 'created_at DESC',
    );

    return result.map(PurposeModel.fromMap).toList();
  }

  // ----------------------------------------------------------
  // GET – por id
  // ----------------------------------------------------------
  Future<PurposeModel?> getById(String id) async {
    final db = await _db;

    final result = await db.query(
      'purposes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return PurposeModel.fromMap(result.first);
  }

  // ----------------------------------------------------------
  // INSERT
  // ----------------------------------------------------------
  Future<void> insert(PurposeModel model) async {
    assert(
    model.lifeAreaId.isNotEmpty,
    'lifeAreaId não pode ser vazio',
    );

    final db = await _db;

    await db.insert(
      'purposes',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // UPDATE
  // ----------------------------------------------------------
  Future<void> update(PurposeModel model) async {
    final db = await _db;

    await db.update(
      'purposes',
      model.copyWith(
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isSynced: false,
      ).toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  // ----------------------------------------------------------
  // SOFT DELETE
  // ----------------------------------------------------------
  Future<void> softDelete(String id) async {
    final db = await _db;

    await db.update(
      'purposes',
      {
        'is_deleted': 1,
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
    final db = await _db;

    await db.update(
      'purposes',
      {
        'is_synced': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------------------------------------------
  // GET – não sincronizados (sync service)
  // ----------------------------------------------------------
  Future<List<PurposeModel>> getUnsynced() async {
    final db = await _db;

    final result = await db.query(
      'purposes',
      where: 'is_synced = 0',
    );

    return result.map(PurposeModel.fromMap).toList();
  }
}
