import 'package:sqflite/sqflite.dart';
import '../../models/annual_goal_model.dart'; // Certifique-se de que o caminho está correto
import '../database/database_helper.dart';

class AnnualGoalsDao {
  // Singleton do DatabaseHelper para acessar o banco
  final dbHelper = DatabaseHelper.instance;

  /// Tabela alvo
  static const String _tableName = 'annual_goals';

  // --- CREATE ---
  /// Inserir uma nova Meta Anual
  Future<void> createAnnualGoal(AnnualGoalModel goal) async {
    final db = await dbHelper.database;

    await db.insert(
      _tableName,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- READ ---

  /// Obter todas as Metas Anuais de um Usuário (filtrando por is_deleted)
  Future<List<AnnualGoalModel>> getAnnualGoalsByUserId(int userId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'year DESC', // Ordenar por ano
    );

    return List.generate(maps.length, (i) {
      return AnnualGoalModel.fromMap(maps[i]);
    });
  }

  /// Essencial para carregar metas dentro da tela de uma Visão específica
  Future<List<AnnualGoalModel>> getAnnualGoalsByVisionId(String visionId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'vision_id = ? AND is_deleted = 0',
      whereArgs: [visionId],
      orderBy: 'year ASC',
    );

    return List.generate(maps.length, (i) {
      return AnnualGoalModel.fromMap(maps[i]);
    });
  }

  /// Obter uma Meta Anual pelo ID
  Future<AnnualGoalModel?> getAnnualGoalById(String id) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AnnualGoalModel.fromMap(maps.first);
    }
    return null;
  }

  // --- UPDATE ---

  /// Atualizar uma Meta Anual
  Future<int> updateAnnualGoal(AnnualGoalModel goal) async {
    final db = await dbHelper.database;

    return await db.update(
      _tableName,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  // --- DELETE (Soft Delete) ---

  /// Marcar uma Meta Anual como deletada (Soft Delete)
  Future<int> deleteAnnualGoal(String id) async {
    final db = await dbHelper.database;

    return await db.update(
      _tableName,
      {
        'is_deleted': 1,
        'is_synced': 0
      }, // Marca como deletado e não sincronizado
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Métodos de Sincronização ---

  Future<List<AnnualGoalModel>> getUnsyncedAnnualGoals() async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'is_synced = 0',
    );

    return List.generate(maps.length, (i) => AnnualGoalModel.fromMap(maps[i]));
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