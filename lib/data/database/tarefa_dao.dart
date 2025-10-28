import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'package:kwanga/models/tarefa_model.dart';

class TarefaDao {
  final databaseHelper = DatabaseHelper.instance;
  static const _uuid = Uuid();

  // CREATE
  Future<void> addTask(String content) async {
    final db = await databaseHelper.database;
    await db.insert('tarefas', {
      'id': _uuid.v4(),
      'content': content,
      'status': 0,
    });
  }

  // READ
  Future<List<Tarefa>> getTarefas() async {
    final db = await databaseHelper.database;
    final data = await db.query('tarefas');
    return data
        .map(
          (e) => Tarefa(
            id: e['id'] as String,
            content: e['content'] as String,
            status: e['status'] as int,
          ),
        )
        .toList();
  }

  // UPDATE
  Future<void> actualizarTarefa(String id, int status) async {
    final db = await databaseHelper.database;
    await db.update(
      'tarefas',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<void> apagarTarefa(String id) async {
    final db = await databaseHelper.database;
    await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}
