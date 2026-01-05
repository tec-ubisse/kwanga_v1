import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/services/api_service.dart';

import '../../models/user.dart';

// Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthRepository(api);
});

class AuthRepository {
  final ApiService _api;
  AuthRepository(this._api);

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  UserModel _mapUserFromApi(Map<String, dynamic> map) {
    final id = map['id'];
    final phone = map['phone'];

    if (id == null || phone == null) {
      throw Exception('User inválido vindo da API');
    }

    return UserModel(
      id: id,
      phone: phone,
      nome: map['first_name'],
      apelido: map['last_name'],
      email: map['email'],
      genero: map['gender'],
      dataNascimento: _parseDate(map['date_of_birth']),
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
      isSynced: true,
      isDeleted: false,
    );
  }

  // ============================================================
  // 🔐 OTP
  // ============================================================

  Future<Map<String, dynamic>> requestLoginOTP(String phone) async {
    final res = await _api.post('auth/login', {'phone': phone});
    if (res.statusCode != 200) {
      throw Exception('Erro ao solicitar OTP');
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> requestRegisterOTP(String phone) async {
    final res = await _api.post('auth/register', {'phone': phone});
    if (res.statusCode != 200) {
      throw Exception('Erro ao solicitar OTP');
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> loginVerifyOTP(
      String phone,
      String code,
      ) async {
    print('📤 POST auth/login/verify_otp');
    print('📤 BODY: {"phone": "$phone", "code": "$code"}');

    final res = await _api.post(
      'auth/login/verify_otp',
      {'phone': phone, 'code': code},
    );

    print('📥 STATUS: ${res.statusCode}');
    print('📥 BODY: ${res.body}');

    final body = jsonDecode(res.body);

    if (res.statusCode == 200 && body['status'] == true) {
      // ⚠️ VERIFIQUE A ESTRUTURA CORRETA
      final token = body['token'] ?? body['data']?['token'];

      if (token == null) {
        print('❌ TOKEN NÃO ENCONTRADO NA RESPOSTA!');
        throw Exception('Token não retornado pela API');
      }

      print('✅ TOKEN RECEBIDO: $token');

      return {
        'user': _mapUserFromApi(body['data']['user']),
        'token': token,
      };
    }

    throw Exception(body['message'] ?? 'Código inválido');
  }

  // ============================================================
  // 👤 PERFIL
  // ============================================================

  String _mapGenderToApi(String gender) {
    switch (gender) {
      case 'Masculino':
        return 'M';
      case 'Feminino':
        return 'F';
      case 'Outro':
        return 'O';
      default:
        throw Exception('Gênero inválido');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String nome,
    required String apelido,
    required String email,
    required String genero,
    required DateTime dataNascimento,
  }) async {
    final payload = {
      'first_name': nome,
      'last_name': apelido,
      'email': email,
      'gender': _mapGenderToApi(genero),
      'date_of_birth': dataNascimento.toIso8601String(),
    };

    if (kDebugMode) {
      debugPrint('📤 UPDATE PROFILE PAYLOAD: $payload');
    }

    final res = await _api.put(
      'users/profile',
      payload,
      auth: true,
    );

    final decoded = jsonDecode(res.body);

    if (res.statusCode != 200) {
      final message =
          decoded['message'] ??
              decoded['error'] ??
              'Erro ao atualizar perfil';
      throw Exception(message);
    }

    return decoded['data'];
  }

  Future<void> logout() async {
    await _api.post('auth/logout', {}, auth: true);
  }
}

