import 'package:sqflite/sqflite.dart';
import '../../models/project_model.dart';
import '../database/database_helper.dart';

class ProjectsDao {
  final dbHelper = DatabaseHelper.instance;

  static const String _tableName = 'projects';

  // --- CREATE ---
  Future<void> createProject(ProjectModel project) async {
    final db = await dbHelper.database;

    await db.insert(
      _tableName,
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- READ ---

  /// Obter todos os projetos de um usuário (apenas não deletados)
  Future<List<ProjectModel>> getProjectsByUserId(int userId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'title ASC',
    );

    return List.generate(maps.length, (i) => ProjectModel.fromMap(maps[i]));
  }

  /// Obter todos os projetos de um monthly goal específico
  Future<List<ProjectModel>> getProjectsByMonthlyGoalId(String monthlyGoalId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'monthly_goal_id = ? AND is_deleted = 0',
      whereArgs: [monthlyGoalId],
      orderBy: 'title ASC',
    );

    return List.generate(maps.length, (i) => ProjectModel.fromMap(maps[i]));
  }

  /// Obter um projeto pelo ID
  Future<ProjectModel?> getProjectById(String id) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ProjectModel.fromMap(maps.first);
    }
    return null;
  }

  // --- UPDATE ---
  Future<int> updateProject(ProjectModel project) async {
    final db = await dbHelper.database;

    return await db.update(
      _tableName,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  // --- DELETE (Soft Delete) ---
  Future<int> deleteProject(String id) async {
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

  // --- SYNC HELPERS ---

  /// Projetos que ainda não foram sincronizados com o backend
  Future<List<ProjectModel>> getUnsyncedProjects() async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'is_synced = 0',
    );

    return List.generate(maps.length, (i) => ProjectModel.fromMap(maps[i]));
  }

  /// Marcar projeto como sincronizado
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
