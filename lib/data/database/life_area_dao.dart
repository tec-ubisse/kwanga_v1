import '../../models/life_area_model.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';

class LifeAreaDao {
  final dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<String> insert(LifeArea area, int userId) async {
    final db = await dbHelper.database;

    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();


    await db.insert('life_areas', {
      'id' : id,
      'user_id' : userId,
      'designation': area.designation,
      'icon_path': area.iconPath,
      'is_deleted': 0,
      'is_synced' : 0,
      'is_default': 0,
      'created_at': now,
      'updated_at': now,
    });

    return id;
  }

  Future<List<LifeArea>> getAll(int userId) async {
    final db = await dbHelper.database;
    final data = await db.query(
      'life_areas',
      where: '(user_id = ? OR is_default = 1) AND is_deleted = 0',
      whereArgs: [userId],
    );
    return data
        .map((e) => LifeArea(
      e['designation'] as String,
      e['icon_path'] as String,
      e['id'] as String,
      userId: (e['user_id'] as int?) ?? 0,
      isDeleted: (e['is_deleted'] ?? 0) == 1,
      isSynced: (e['is_synced'] ?? 0) == 1,
      isDefault: (e['is_default'] ?? 0) == 1,
      createdAt: e['created_at'] as String ?? '',
      updatedAt: e['updated_at'] as String ?? '',
    ))
        .toList();
  }

  Future<void> delete(String  id) async {
    final db = await dbHelper.database;

    // Check first if life area is from the system
    final result = await db.query('life_areas',
        where: 'id = ? AND is_default = 1', whereArgs: [id]);

    if (result.isNotEmpty) {
      throw Exception('Não é permitido apagar áreas do sistema');
    }

    await db.update(
      'life_areas',
      {
        'is_deleted': 1,
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> update(LifeArea area, String  id) async {
    final db = await dbHelper.database;

    final result = await db.query('life_areas',
        where: 'id = ? AND is_default = 1', whereArgs: [id]);

    if (result.isNotEmpty) {
      throw Exception('Não é permitido editar áreas do sistema');
    }

    final now = DateTime.now().toIso8601String();

    await db.update(
      'life_areas',
      {'designation': area.designation, 'icon_path': area.iconPath,'is_synced': 0,'updated_at': now,},
      where: 'id = ?',
      whereArgs: [area.id],
    );
  }

  Future<List<LifeArea>> getPendingSync() async {
    final db = await dbHelper.database;
    final data = await db.query('life_areas', where: 'is_synced = 0');
    return data
        .map(
          (e) => LifeArea(
        e['designation'] as String,
        e['icon_path'] as String,
        e['id'] as String,
        userId: (e['user_id'] as int?) ?? 0,
        isDeleted: (e['is_deleted'] ?? 0) == 1,
        isSynced: (e['is_synced'] ?? 0) == 1,
        isDefault: (e['is_default'] ?? 0) == 1,
        createdAt: e['created_at'] as String ?? '',
        updatedAt: e['updated_at'] as String ?? '',
      ),
    )
        .toList();
  }

  Future<void> markAsSynced(String id) async {
    final db = await dbHelper.database;
    await db.update(
      'life_areas',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }



}
