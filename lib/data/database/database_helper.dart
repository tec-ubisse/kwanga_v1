import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Create all the Database tables here
  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final path = join(dbDir, 'kwanga_db.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create Life Areas table
        await db.execute('''
          CREATE TABLE life_areas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            designation TEXT NOT NULL,
            icon_path TEXT NOT NULL,
            is_system INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Default Life Areas
        final predefinedAreas = [
          {'designation': 'Acadêmica', 'icon_path': 'university'},
          {'designation': 'Profissional', 'icon_path': 'professional'},
          {'designation': 'Networking', 'icon_path': 'networking'},
          {'designation': 'Carreira', 'icon_path': 'career'},
          {'designation': 'Emocional', 'icon_path': 'emotion'},
          {'designation': 'Saúde', 'icon_path': 'health'},
          {'designation': 'Família', 'icon_path': 'family'},
          {'designation': 'Financeira', 'icon_path': 'finances'},
        ];

        for (final area in predefinedAreas) {
          await db.insert('life_areas', {
            'designation': area['designation'],
            'icon_path': area['icon_path'],
            'is_system': 1, // immutable system areas
          });
        }

        // Create Purposes table
        await db.execute('''
          CREATE TABLE purposes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            life_area_id INTEGER NOT NULL,
            FOREIGN KEY (life_area_id) REFERENCES life_areas(id) ON DELETE CASCADE
          )
        ''');

        // Create LongTermVisions table
        await db.execute('''
        CREATE TABLE long_term_visions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          life_area_id INTEGER NOT NULL,
          designation TEXT NOT NULL,
          deadline TEXT NOT NULL,
          status TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (life_area_id) REFERENCES life_areas(id) ON DELETE CASCADE
        )
      ''');
      },
    );
  }
}
