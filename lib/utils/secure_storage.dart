import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userPhoneKey = 'user_phone';

  /// ------------------ SAVE ------------------

  static Future<void> saveAuthData(
      String token,
      int userId,
      String phone,
      ) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _userPhoneKey, value: phone);
  }

  /// ------------------ READ ------------------

  static Future<String?> getToken() {
    return _storage.read(key: _tokenKey);
  }

  static Future<int?> getUserId() async {
    final idStr = await _storage.read(key: _userIdKey);
    return idStr != null ? int.tryParse(idStr) : null;
  }

  static Future<String?> getUserPhone() {
    return _storage.read(key: _userPhoneKey);
  }

  /// ------------------ DELETE ------------------

  static Future<void> deleteToken() {
    return _storage.delete(key: _tokenKey);
  }

  static Future<void> clearAll() {
    return _storage.deleteAll();
  }
}
