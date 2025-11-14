import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/services/api_service.dart';
import 'package:kwanga/utils/secure_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthRepository(apiService);
});

class AuthRepository {
  final ApiService _api;
  AuthRepository(this._api);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _api.post('auth/login', {'email': email, 'password': password});

      debugPrint('🔹 STATUS CODE: ${res.statusCode}');
      debugPrint('🔹 BODY: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == true && data['data'] != null && data['token'] != null) {
          return {
            'user': data['data']['user'],
            'token': data['token'],
          };
        } else {
          debugPrint('⚠️ Estrutura inesperada: $data');
        }
      } else {
        debugPrint('⚠️ Erro HTTP: ${res.statusCode} → ${res.body}');
      }

      throw Exception('Credenciais inválidas ou erro na resposta da API');
    } catch (e, stack) {
      debugPrint('❌ Erro no login: $e');
      debugPrint('$stack');
      rethrow;
    }
  }


  Future<void> resendVerificationCode(String email) async {
    // Aqui fazes a chamada real à tua API ou Firebase
    // Exemplo:
    await Future.delayed(const Duration(seconds: 1));
    print('Código de verificação reenviado para $email');
  }

  // Refatorado para lançar uma exceção em caso de falha
  Future<void> register(String email, String password) async {
    final res = await _api.post('auth/register', {'email': email, 'password': password});
    if (res.statusCode != 201) {
      // Opcional: decodificar a resposta para uma mensagem de erro mais específica
      throw Exception('Não foi possível criar a conta.');
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    final res = await _api.post('auth/verify_email', {
      'email': email,
      'code': code,
    });

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['status'] == true && body['data']?['user'] != null && body['token'] != null) {
        return {
          'user': body['data']['user'],
          'token': body['token'],
        };
      }
    }
    throw Exception('Código de verificação inválido.');
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

  Future<void> logout() async {
    try {
      final res = await _api.post('auth/logout', {}, auth: true);
      if (res.statusCode != 200) {
        print('Erro ao fazer logout (API): ${res.body}');
      }
    } catch (e) {
      print('Erro na chamada de logout: $e');
    }
  }
}
