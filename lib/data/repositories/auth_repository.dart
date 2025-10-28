import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:kwanga/data/services/api_service.dart';
import 'package:kwanga/utils/secure_storage.dart';

class AuthRepository {
  final ApiService _api = ApiService();

  Future<bool> login(String email, String password) async {
    final res = await _api.post('auth/login', {'email': email, 'password': password});
    print(res.body);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        final user = data['data']['user'];
        final token = data['token'];
        final userId = user['id'];
        final userEmail = user['email'];

        // Salva tudo localmente
        await SecureStorage.saveAuthData(token, userId, userEmail);
        return true;
      }
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    final res = await _api.post('auth/register', {'email': email, 'password': password});
    return res.statusCode == 201;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final res = await _api.get('users/user', auth: true);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        return decoded['data'];
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    }
    return null;
  }

  Future<bool> logout() async {

    try{
      final res = await _api.post('auth/logout', {}, auth: true);

      if(res.statusCode == 200){

        await SecureStorage.clearAll();
        return true;
      }else{
        print('erro ao fazer logOut: ${res.body}');
        return false;
      }
    } catch(e){
      print('erro $e');
      return false;
    }

  }

  Future<bool> verifyEmail(String email, String code) async {
    final res = await _api.post('auth/verify_email', {
      'email': email,
      'code': code,
    });

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);


      if (body['status'] == true && body['data']?['user'] != null && body['token'] != null) {
        final user = body['data']['user'];
        final token = body['token'];
        final userId = user['id'];
        final userEmail = user['email'];

        // Salva tudo localmente
        await SecureStorage.saveAuthData(token, userId, userEmail);

        return true;
      }
    }

    return false;
  }

}
