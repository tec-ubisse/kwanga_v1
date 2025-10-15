import '../../models/life_area_model.dart';
import 'database_helper.dart';

class LifeAreaDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(LifeArea area) async {
    final db = await dbHelper.database;
    return await db.insert('life_areas', {
      'designation': area.designation,
      'icon_path': area.iconPath,
    });
  }

  Future<List<LifeArea>> getAll() async {
    final db = await dbHelper.database;
    final data = await db.query('life_areas');
    return data
        .map((e) => LifeArea(
      e['designation'] as String,
      e['icon_path'] as String,
      e['id'] as int
    ))
        .toList();
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;

    // Check first if life area is from the system
    final result = await db.query('life_areas',
        where: 'id = ? AND is_system = 1', whereArgs: [id]);

    if (result.isNotEmpty) {
      throw Exception('Não é permitido apagar áreas do sistema');
    }

    await db.delete('life_areas', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(LifeArea area, int id) async {
    final db = await dbHelper.database;

    final result = await db.query('life_areas',
        where: 'id = ? AND is_system = 1', whereArgs: [id]);

    if (result.isNotEmpty) {
      throw Exception('Não é permitido editar áreas do sistema');
    }

    await db.update(
      'life_areas',
      {'designation': area.designation, 'icon_path': area.iconPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }



}
