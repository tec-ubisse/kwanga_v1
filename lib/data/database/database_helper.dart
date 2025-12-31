import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static Database? _db;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // ----------------------------------------------------------
  // INIT DATABASE
  // ----------------------------------------------------------
  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final path = join(dbDir, 'kwanga_db.db');

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        // 🔒 Obrigatório para FKs no SQLite
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _runMigrations(db, oldVersion, newVersion);
      },
    );
  }

  // ----------------------------------------------------------
  // MIGRATIONS
  // ----------------------------------------------------------
  Future<void> _runMigrations(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await _migrationV2_AddSocialLifeArea(db);
    }
  }

  // ----------------------------------------------------------
  // MIGRATION v2 — Add "Social" system life area
  // ----------------------------------------------------------
  Future<void> _migrationV2_AddSocialLifeArea(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'life_areas',
      {
        'id': const Uuid().v4(),
        'user_id': null,
        'designation': 'Social',
        'icon_path': 'social',
        'is_system': 1,
        'is_deleted': 0,
        'is_synced': 1,
        'order_index': 8,
        'created_at': now,
        'updated_at': now,
      },
      // 🔁 se já existir, ignora (idempotente)
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // ----------------------------------------------------------
  // SCHEMA — fresh install
  // ----------------------------------------------------------
  Future<void> _createSchema(Database db) async {
    // ==========================================================
    // USERS
    // ==========================================================
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        phone TEXT NOT NULL UNIQUE,
        nome TEXT,
        apelido TEXT,
        email TEXT,
        genero TEXT,
        data_nascimento INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 1
      );
    ''');

    // ==========================================================
    // LIFE AREAS
    // ==========================================================
    await db.execute('''
      CREATE TABLE life_areas (
        id TEXT PRIMARY KEY,
        user_id INTEGER,
        designation TEXT NOT NULL,
        icon_path TEXT NOT NULL,
        is_system INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        order_index INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        CHECK (
          (is_system = 1 AND user_id IS NULL)
          OR
          (is_system = 0 AND user_id IS NOT NULL)
        )
      );
    ''');

    await db.execute('''
      CREATE INDEX idx_life_areas_order
      ON life_areas (order_index, user_id);
    ''');

    // ----------------------------------------------------------
    // Seed das áreas do sistema (fresh install)
    // ----------------------------------------------------------
    final predefinedLifeAreas = [
      {'designation': 'Acadêmica', 'icon_path': 'university'},
      {'designation': 'Profissional', 'icon_path': 'professional'},
      {'designation': 'Networking', 'icon_path': 'networking'},
      {'designation': 'Carreira', 'icon_path': 'career'},
      {'designation': 'Emocional', 'icon_path': 'emotion'},
      {'designation': 'Saúde', 'icon_path': 'health'},
      {'designation': 'Família', 'icon_path': 'family'},
      {'designation': 'Financeira', 'icon_path': 'finances'},
      {'designation': 'Social', 'icon_path': 'social'},
    ];

    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < predefinedLifeAreas.length; i++) {
      final area = predefinedLifeAreas[i];

      await db.insert(
        'life_areas',
        {
          'id': const Uuid().v4(),
          'user_id': null,
          'designation': area['designation'],
          'icon_path': area['icon_path'],
          'is_system': 1,
          'is_deleted': 0,
          'is_synced': 1,
          'order_index': i,
          'created_at': now,
          'updated_at': now,
        },
      );
    }

    // ==========================================================
    // PURPOSES
    // ==========================================================
    await db.execute('''
      CREATE TABLE purposes (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        life_area_id TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(life_area_id) REFERENCES life_areas(id) ON DELETE CASCADE
      );
    ''');

    // ==========================================================
    // VISIONS
    // ==========================================================
    await db.execute('''
      CREATE TABLE visions (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        life_area_id TEXT NOT NULL,
        conclusion INTEGER NOT NULL,
        description TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(life_area_id) REFERENCES life_areas(id) ON DELETE CASCADE
      );
    ''');

    // ==========================================================
    // LISTS
    // ==========================================================
    await db.execute('''
      CREATE TABLE lists (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        list_type TEXT NOT NULL,
        description TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_project INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // ==========================================================
    // TASKS
    // ==========================================================
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        list_id TEXT NOT NULL,
        project_id TEXT,
        linked_action_id TEXT,
        description TEXT NOT NULL,
        listType TEXT NOT NULL,
        deadline INTEGER,
        time INTEGER,
        frequency TEXT,
        completed INTEGER NOT NULL DEFAULT 0,
        order_index INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(list_id) REFERENCES lists(id) ON DELETE CASCADE
      );
    ''');

    // ==========================================================
    // ANNUAL GOALS
    // ==========================================================
    await db.execute('''
      CREATE TABLE annual_goals (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        vision_id TEXT NOT NULL,
        description TEXT NOT NULL,
        year INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(vision_id) REFERENCES visions(id) ON DELETE CASCADE
      );
    ''');

    // ==========================================================
    // MONTHLY GOALS
    // ==========================================================
    await db.execute('''
      CREATE TABLE monthly_goals (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        annual_goals_id TEXT NOT NULL,
        description TEXT NOT NULL,
        month INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(annual_goals_id) REFERENCES annual_goals(id) ON DELETE CASCADE
      );
    ''');

    // ==========================================================
    // PROJECTS
    // ==========================================================
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        monthly_goal_id TEXT NOT NULL,
        title TEXT NOT NULL,
        purpose TEXT NOT NULL,
        expected_result TEXT NOT NULL,
        brainstorm_ideas TEXT,
        first_action TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(monthly_goal_id) REFERENCES monthly_goals(id) ON DELETE CASCADE
      );
    ''');
  }
}
