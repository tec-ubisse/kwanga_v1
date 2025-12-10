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
      version: 14, // ⭐ versão atual
      onCreate: (db, version) async {
        // USERS
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
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
          )
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

        // PURPOSES
        await db.execute('''
          CREATE TABLE purposes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            life_area_id TEXT NOT NULL,
            FOREIGN KEY (life_area_id) REFERENCES life_areas(id) ON DELETE CASCADE
          )
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
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (life_area_id) REFERENCES life_areas(id) ON DELETE CASCADE
          )
        ''');

        // LISTS
        await db.execute('''
          CREATE TABLE lists (
            id TEXT PRIMARY KEY,
            user_id INTEGER NOT NULL,
            list_type TEXT NOT NULL,
            description TEXT NOT NULL,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            is_synced INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');

        // TASKS (com linked_action_id incluído)
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            user_id INTEGER NOT NULL,
            list_id TEXT NOT NULL,
            description TEXT NOT NULL,
            listType TEXT NOT NULL,
            deadline INTEGER,
            time INTEGER,
            frequency TEXT,
            completed INTEGER NOT NULL DEFAULT 0,
            linked_action_id TEXT,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (list_id) REFERENCES lists(id) ON DELETE CASCADE
          )
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
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (vision_id) REFERENCES visions(id) ON DELETE CASCADE
          )
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
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (annual_goals_id) REFERENCES annual_goals(id) ON DELETE CASCADE
          )
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
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (monthly_goal_id) REFERENCES monthly_goals(id) ON DELETE CASCADE
          )
        ''');

        // PROJECT ACTIONS
        await db.execute('''
          CREATE TABLE project_actions (
            id TEXT PRIMARY KEY,
            project_id TEXT NOT NULL,
            description TEXT NOT NULL,
            is_done INTEGER NOT NULL DEFAULT 0,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            is_synced INTEGER NOT NULL DEFAULT 0,
            order_index INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
          )
        ''');
      },

      // database upgrade to include linked_action_id in task_model
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 14) {
          final columns =
          await db.rawQuery("PRAGMA table_info(tasks);");
          final hasLinked =
          columns.any((c) => c['name'] == 'linked_action_id');

          if (!hasLinked) {
            await db.execute(
              "ALTER TABLE tasks ADD COLUMN linked_action_id TEXT;",
            );
          }
        }
      },
    );
  }
}
