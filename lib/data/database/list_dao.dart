import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ListDao {
  final databaseHelper = DatabaseHelper.instance;

  // CREATE
  Future<int> insert(ListModel listType) async {
    final db = await databaseHelper.database;
    return await db.insert('lists', {
      'id': listType.id,
      'user_id': listType.userId,
      'list_type': listType.listType,
      'description': listType.description,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // READ
  Future<List<ListModel>> getAll() async {
    final db = await databaseHelper.database;
    final data = await db.query('lists');
    return data
        .map(
          (e) => ListModel(
            id: e['id'] as String,
            userId: e['user_id'] as int,
            listType: e['list_type'] as String,
            description: e['description'] as String,
          ),
        )
        .toList();
  }

  Future<List<ListModel>> getDescriptions() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('lists');
    return List.generate(maps.length, (i) {
      return ListModel.fromMap(maps[i]);
    });
  }

  // UPDATE
  Future<int> update(ListModel list, int id) async {
    final db = await databaseHelper.database;
    return await db.update(
      'lists',
      {'list_type': list.listType, 'description': list.description},
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await databaseHelper.database;
    return await db.delete('lists', where: 'id = ?', whereArgs: [id]);
  }
}
