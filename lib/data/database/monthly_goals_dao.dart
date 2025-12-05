import 'package:sqflite/sqflite.dart';
import '../../models/monthly_goal_model.dart'; // Certifique-se de que o caminho está correto
import '../database/database_helper.dart';

class MonthlyGoalsDao {
  // Singleton do DatabaseHelper para acessar o banco
  final dbHelper = DatabaseHelper.instance;

  /// Tabela alvo
  static const String _tableName = 'monthly_goals';

  // --- CREATE ---
  /// Inserir uma nova Meta Mensal
  Future<void> createMonthlyGoal(MonthlyGoalModel goal) async {
    final db = await dbHelper.database;

    await db.insert(
      _tableName,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- READ ---

  /// Obter todas as Metas Mensais de um Usuário (filtrando por is_deleted)
  Future<List<MonthlyGoalModel>> getMonthlyGoalsByUserId(int userId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'month ASC', // Ordenar por mês
    );

    return List.generate(maps.length, (i) {
      return MonthlyGoalModel.fromMap(maps[i]);
    });
  }

  /// Essencial para carregar metas dentro da tela de uma Meta Anual específica
  Future<List<MonthlyGoalModel>> getMonthlyGoalsByAnnualGoalId(String annualGoalId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'annual_goals_id = ? AND is_deleted = 0',
      whereArgs: [annualGoalId],
      orderBy: 'month ASC',
    );

    return List.generate(maps.length, (i) {
      return MonthlyGoalModel.fromMap(maps[i]);
    });
  }

  /// Obter uma Meta Mensal pelo ID
  Future<MonthlyGoalModel?> getMonthlyGoalById(String id) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MonthlyGoalModel.fromMap(maps.first);
    }
    return null;
  }

  // --- UPDATE ---

  /// Atualizar uma Meta Mensal
  Future<int> updateMonthlyGoal(MonthlyGoalModel goal) async {
    final db = await dbHelper.database;

    return await db.update(
      _tableName,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  // --- DELETE (Soft Delete) ---

  /// Marcar uma Meta Mensal como deletada (Soft Delete)
  Future<int> deleteMonthlyGoal(String id) async {
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

  Future<List<MonthlyGoalModel>> getUnsyncedMonthlyGoals() async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'is_synced = 0',
    );

    return List.generate(maps.length, (i) => MonthlyGoalModel.fromMap(maps[i]));
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