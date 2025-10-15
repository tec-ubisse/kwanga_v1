import 'dart:convert';
import 'package:kwanga/data/services/api_service.dart';
import 'package:kwanga/utils/secure_storage.dart';

class AuthRepository {
  final ApiService _api = ApiService();

  Future<bool> login(String email, String password) async {
    final res = await _api.post('auth/login', {'email': email, 'password': password});
    print(res.body);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await SecureStorage.saveToken(data['token']);
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    final res = await _api.post('auth/register', {'email': email, 'password': password});
    return res.statusCode == 201;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final res = await _api.get('user', auth: true);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
  }

  Future<bool>verifyEmail(String email, String code) async {
    final res = await _api.post('auth/verify-email', {'email': email, 'code': code});
    return res.statusCode == 200;
  }
}
