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

  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final path = join(dbDir, 'kwanga_db.db');

    return await openDatabase(
      path,
      version: 18,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 18) {
          await _migrateToV18(db);
        }
      },
    );
  }

  // ----------------------------------------------------------
  // MIGRATION v18 – purposes com life_area_id
  // ----------------------------------------------------------
  Future<void> _migrateToV18(Database db) async {
    // verifica se tabela antiga existe
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='purposes';",
    );

    if (tables.isEmpty) return;

    // 1️⃣ renomeia tabela antiga
    await db.execute('ALTER TABLE purposes RENAME TO purposes_old;');

    // 2️⃣ cria nova tabela correta
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

    // 3️⃣ obtém uma life_area default (sistema)
    final defaultLifeArea = await db.query(
      'life_areas',
      where: 'is_system = 1',
      limit: 1,
    );

    final defaultLifeAreaId =
    defaultLifeArea.isNotEmpty ? defaultLifeArea.first['id'] as String : '';

    // 4️⃣ migra dados preservando informação
    final oldPurposes = await db.query('purposes_old');

    for (final row in oldPurposes) {
      await db.insert('purposes', {
        'id': row['id'] ?? const Uuid().v4(),
        'user_id': row['user_id'],
        'life_area_id': defaultLifeAreaId,
        'description': row['description'],
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
        'is_deleted': row['is_deleted'] ?? 0,
        'is_synced': row['is_synced'] ?? 0,
      });
    }

    // 5️⃣ remove tabela antiga
    await db.execute('DROP TABLE purposes_old;');
  }

  // ----------------------------------------------------------
  // SCHEMA – fresh install
  // ----------------------------------------------------------
  Future<void> _createSchema(Database db) async {
    // USERS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      );
    ''');

    // LIFE AREAS
    await db.execute('''
      CREATE TABLE life_areas (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        designation TEXT NOT NULL,
        icon_path TEXT NOT NULL,
        is_system INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // predefined life areas
    final predefinedLifeAreas = [
      {'designation': 'Acadêmica', 'icon_path': 'university'},
      {'designation': 'Profissional', 'icon_path': 'professional'},
      {'designation': 'Networking', 'icon_path': 'networking'},
      {'designation': 'Carreira', 'icon_path': 'career'},
      {'designation': 'Emocional', 'icon_path': 'emotion'},
      {'designation': 'Saúde', 'icon_path': 'health'},
      {'designation': 'Família', 'icon_path': 'family'},
      {'designation': 'Financeira', 'icon_path': 'finances'},
    ];

    for (final area in predefinedLifeAreas) {
      await db.insert('life_areas', {
        'id': const Uuid().v4(),
        'user_id': 0,
        'designation': area['designation'],
        'icon_path': area['icon_path'],
        'is_system': 1,
        'is_deleted': 0,
        'is_synced': 1,
      });
    }

    // PURPOSES (NOVO MODELO)
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

    // VISIONS
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

    // LISTS
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

    // TASKS
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

    // ANNUAL GOALS
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

    // MONTHLY GOALS
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

    // PROJECTS
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
