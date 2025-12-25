import 'package:sqflite/sqflite.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/data/database/database_helper.dart';


class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ----------------------------------------------------------
  // CREATE / UPSERT
  // ----------------------------------------------------------
  Future<int> insertOrReplace(UserModel user) async {
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
        'data_nascimento':
        user.dataNascimento?.millisecondsSinceEpoch,
        'created_at':
        user.createdAt?.millisecondsSinceEpoch ?? now,
        'updated_at': now,
        'is_deleted': user.isDeleted ? 1 : 0,
        'is_synced': user.isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  // ----------------------------------------------------------
  // UPDATE
  // ----------------------------------------------------------
  Future<int> update(UserModel user) async {
    final db = await _dbHelper.database;

    return await db.update(
      'users',
      {
        'nome': user.nome,
        'apelido': user.apelido,
        'email': user.email,
        'genero': user.genero,
        'data_nascimento':
        user.dataNascimento?.millisecondsSinceEpoch,
        'updated_at':
        DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0, // 🔴 precisa sync
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ----------------------------------------------------------
  // SOFT DELETE
  // ----------------------------------------------------------
  Future<int> softDelete(int id) async {
    final db = await _dbHelper.database;

    return await db.update(
      'users',
      {
        'is_deleted': 1,
        'updated_at':
        DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
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
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] as int,
      ),
      isDeleted: (map['is_deleted'] as int) == 1,
      isSynced: (map['is_synced'] as int) == 1,
    );
  }
}
