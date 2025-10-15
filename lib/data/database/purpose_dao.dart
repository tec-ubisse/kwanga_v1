import '../../models/life_area_model.dart';
import '../../models/purpose_model.dart';
import 'database_helper.dart';

class PurposeDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Purpose purpose) async {
    final db = await dbHelper.database;

    // Obter o ID da área associada
    final result = await db.query(
      'life_areas',
      where: 'designation = ?',
      whereArgs: [purpose.lifeArea.designation],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('Área da vida não encontrada');
    }

    final lifeAreaId = result.first['id'] as int;

    return await db.insert('purposes', {
      'description': purpose.description,
      'life_area_id': lifeAreaId,
    });
  }

  Future<void> update(Purpose purpose) async {
    final db = await dbHelper.database;
    await db.update(
      'purposes',
      {
        'description': purpose.description,
        'life_area_id': purpose.lifeArea.id, // se a tabela tem FK
      },
      where: 'id = ?',
      whereArgs: [purpose.id],
    );
  }


  Future<List<Purpose>> getAll() async {
    final db = await dbHelper.database;

    final data = await db.rawQuery('''
      SELECT p.id, p.description,
             l.designation, l.icon_path
      FROM purposes p
      INNER JOIN life_areas l
      ON p.life_area_id = l.id
      ORDER BY l.designation
    ''');

    return data
        .map(
          (e) => Purpose(
        e['description'] as String,
        LifeArea(
          e['designation'] as String,
          e['icon_path'] as String,
          e['id'] as int,
        ),e['id'] as int
      ),
    )
        .toList();
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete('purposes', where: 'id = ?', whereArgs: [id]);
  }
}
