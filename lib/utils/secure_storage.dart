import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Salvar token de fotma sehura

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';

  static Future<void> saveAuthData(String token, int userId, String userEmail) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _userEmailKey, value: userEmail);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<int?> getUserId() async {
    final idStr = await _storage.read(key: _userIdKey);
    return idStr != null ? int.tryParse(idStr) : null;
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }


  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }


}
