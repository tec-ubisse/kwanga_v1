import 'package:kwanga/models/user.dart';
import 'package:kwanga/data/database/database_helper.dart';

class UserDao {
  final databaseHelper = DatabaseHelper.instance;

// CREATE
  Future<int> insert(UserModel user) async {
    final db = await databaseHelper.database;
    return await db.insert(
      'users',
      {
        'email': user.email,
        'password': user.password,
      },
    );
  }

  // READ
  Future<List<UserModel>> getAllUsers() async {
    final db = await databaseHelper.database;
    final result = await db.query('users');

    return result.map((e) {
      return UserModel(
        id: e['id'] as int?,
        email: e['email'] as String,
        password: e['password'] as String,
      );
    }).toList();
  }

  // UPDATE
  Future<int> updateUser(UserModel user) async {
    final db = await databaseHelper.database;
    return await db.update(
      'users',
      {
        'email': user.email,
        'password': user.password,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // DELETE
  Future<int> deleteUser(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}