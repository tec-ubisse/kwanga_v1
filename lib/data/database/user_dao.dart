import 'package:sqflite/sqflite.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/data/database/database_helper.dart';

class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(UserModel user) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    return await db.insert(
      'users',
      {
        'id': user.id,
        'phone': user.phone,
        'nome': user.nome,
        'apelido': user.apelido,
        'email': user.email,
        'genero': user.genero,
        'data_nascimento': user.dataNascimento?.millisecondsSinceEpoch,
        'created_at': user.createdAt?.millisecondsSinceEpoch ?? now,
        'updated_at': user.updatedAt?.millisecondsSinceEpoch ?? now,
        'is_deleted': user.isDeleted ? 1 : 0,
        'is_synced': user.isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<bool> _exists(int userId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT 1 FROM users WHERE id = ? AND is_deleted = 0 LIMIT 1',
      [userId],
    );

    return result.isNotEmpty;
  }

  Future<void> ensureUser(UserModel user) async {
    if (user.id == null) return;

    final exists = await _exists(user.id!);
    if (!exists) {
      await insert(user);
    }
  }

  // ----------------------------------------------------------
  // READ
  // ----------------------------------------------------------

  Future<UserModel?> getById(int id) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'users',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return _mapToUser(result.first);
  }

  Future<UserModel?> getByPhone(String phone) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'users',
      where: 'phone = ? AND is_deleted = 0',
      whereArgs: [phone],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return _mapToUser(result.first);
  }

  Future<List<UserModel>> getAll() async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'users',
      where: 'is_deleted = 0',
      orderBy: 'updated_at DESC',
    );

    return result.map(_mapToUser).toList();
  }

  Future<List<UserModel>> getUnsyncedUsers() async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'users',
      where: 'is_synced = 0 AND is_deleted = 0',
    );

    return result.map(_mapToUser).toList();
  }

  // ----------------------------------------------------------
  // API SYNC
  // ----------------------------------------------------------

  Future<int> insertOrReplaceFromApi(UserModel user) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    return await db.insert(
      'users',
      {
        'id': user.id,
        'phone': user.phone,
        'nome': user.nome,
        'apelido': user.apelido,
        'email': user.email,
        'genero': user.genero,
        'data_nascimento': user.dataNascimento?.millisecondsSinceEpoch,
        'created_at': user.createdAt?.millisecondsSinceEpoch ?? now,
        'updated_at': user.updatedAt?.millisecondsSinceEpoch ?? now,
        'is_deleted': user.isDeleted ? 1 : 0,
        'is_synced': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // UPDATE / DELETE
  // ----------------------------------------------------------

  Future<int> update(UserModel user) async {
    if (user.id == null) {
      throw ArgumentError('❌ User ID cannot be null for update');
    }

    final db = await _dbHelper.database;

    // ⚠️ UPDATE PARCIAL: só escreve o que NÃO é null
    final Map<String, dynamic> values = {
      'updated_at': DateTime.now().millisecondsSinceEpoch,
      'is_synced': user.isSynced ? 1 : 0,
    };

    if (user.nome != null) {
      values['nome'] = user.nome;
    }
    if (user.apelido != null) {
      values['apelido'] = user.apelido;
    }
    if (user.email != null) {
      values['email'] = user.email;
    }
    if (user.genero != null) {
      values['genero'] = user.genero;
    }
    if (user.dataNascimento != null) {
      values['data_nascimento'] =
          user.dataNascimento!.millisecondsSinceEpoch;
    }

    final result = await db.update(
      'users',
      values,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [user.id],
    );

    if (result == 0) {
      throw Exception('❌ Nenhum usuário encontrado com ID ${user.id}');
    }

    return result;
  }


  Future<bool> softDelete(int id) async {
    final db = await _dbHelper.database;

    final result = await db.update(
      'users',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    return result > 0;
  }

  // ----------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------

  UserModel _mapToUser(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      phone: map['phone'] as String,
      nome: map['nome'] as String?,
      apelido: map['apelido'] as String?,
      email: map['email'] as String?,
      genero: map['genero'] as String?,
      dataNascimento: map['data_nascimento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
        map['data_nascimento'] as int,
      )
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
      )
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] as int,
      )
          : null,
      isDeleted: (map['is_deleted'] as int) == 1,
      isSynced: (map['is_synced'] as int) == 1,
    );
  }
}
