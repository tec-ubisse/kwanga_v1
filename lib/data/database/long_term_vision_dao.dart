import 'package:kwanga/models/long_term_vision_model.dart';
import '../../models/life_area_model.dart';
import '../../models/user.dart';
import 'database_helper.dart';

class LongTermVisionDao {
  final dbHelper = DatabaseHelper.instance;

  // Add to database
  Future<int> insert(LongTermVision vision) async {
    final db = await dbHelper.database;
    return await db.insert('long_term_vision', {
      'user': vision.user,
      'life_area': vision.lifeArea,
      'designation': vision.designation,
      'deadline': vision.deadline,
      'status': vision.status,
    });
  }

  // List
  Future<List<LongTermVision>> getAll() async {
    final db = await dbHelper.database;
    final data = await db.query('long_term_visions');

    return data.map((e) {
      // Cria instâncias básicas de User e LifeArea só com o id
      final user = User(
        e['user_id'].toString(),
        '',
        '',
      );
      final lifeArea = LifeArea('', '', e['life_area_id'] as int);

      return LongTermVision(
        user,
        lifeArea,
        e['designation'] as String,
        e['deadline'] as String,
        e['status'] as String,
      );
    }).toList();
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;

    // Verifica se a visão existe antes de tentar apagar (opcional, mas seguro)
    final result = await db.query(
      'long_term_visions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      throw Exception('Visão de longo prazo não encontrada');
    }

    await db.delete(
      'long_term_visions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> update(LongTermVision vision, int id) async {
    final db = await dbHelper.database;

    // Verifica se o registo existe antes de atualizar
    final result = await db.query(
      'long_term_visions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      throw Exception('Visão de longo prazo não encontrada');
    }

    await db.update(
      'long_term_visions',
      {
        'user_id': vision.user.id,
        'life_area_id': vision.lifeArea.id,
        'designation': vision.designation,
        'deadline': vision.deadline,
        'status': vision.status,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}