import 'package:sqflite/sqflite.dart';
import '../../models/vision_model.dart';
import '../database/database_helper.dart';

class VisionsDao {
  // Singleton do DatabaseHelper para acessar o banco
  final dbHelper = DatabaseHelper.instance;

  /// Tabela alvo
  static const String _tableName = 'visions';

  /// Inserir uma nova Visão
  Future<void> createVision(VisionModel vision) async {
    final db = await dbHelper.database;

    await db.insert(
      _tableName,
      vision.toMap(), // O toMap já inclui 'life_area_id', então isso salvará corretamente
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VisionModel>> getVisionsByUserId(int userId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'conclusion ASC',
    );

    return List.generate(maps.length, (i) {
      return VisionModel.fromMap(maps[i]);
    });
  }

  // --- NOVO MÉTODO ADICIONADO ---
  // Essencial para carregar visões dentro da tela de uma Área da Vida específica
  Future<List<VisionModel>> getVisionsByLifeAreaId(String lifeAreaId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      // Note que usamos 'life_area_id' (nome da coluna no banco) e não lifeAreaId
      where: 'life_area_id = ? AND is_deleted = 0',
      whereArgs: [lifeAreaId],
      orderBy: 'conclusion ASC',
    );

    return List.generate(maps.length, (i) {
      return VisionModel.fromMap(maps[i]);
    });
  }
  // ------------------------------

  Future<VisionModel?> getVisionById(String id) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return VisionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateVision(VisionModel vision) async {
    final db = await dbHelper.database;

    return await db.update(
      _tableName,
      vision.toMap(),
      where: 'id = ?',
      whereArgs: [vision.id],
    );
  }

  Future<int> deleteVision(String id) async {
    final db = await dbHelper.database;

    return await db.update(
      _tableName,
      {
        'is_deleted': 1,
        'is_synced': 0
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hardDeleteVision(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- utility methods
  Future<List<VisionModel>> getUnsyncedVisions() async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'is_synced = 0',
    );

    return List.generate(maps.length, (i) => VisionModel.fromMap(maps[i]));
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
}