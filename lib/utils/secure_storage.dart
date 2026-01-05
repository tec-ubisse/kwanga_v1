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
    print('💾 [SecureStorage] Iniciando gravação de dados de autenticação...');
    print('💾 Token: ${token.length > 20 ? "${token.substring(0, 20)}..." : token}');
    print('💾 User ID: $userId');
    print('💾 Phone: $phone');

    try {
      await _storage.write(key: _tokenKey, value: token);
      print('✅ Token gravado com sucesso');

      await _storage.write(key: _userIdKey, value: userId.toString());
      print('✅ User ID gravado com sucesso');

      await _storage.write(key: _userPhoneKey, value: phone);
      print('✅ Phone gravado com sucesso');

      print('✅ [SecureStorage] Todos os dados gravados com sucesso');

      // Verificação imediata
      final savedToken = await _storage.read(key: _tokenKey);
      final savedUserId = await _storage.read(key: _userIdKey);
      final savedPhone = await _storage.read(key: _userPhoneKey);

      print('🔍 [SecureStorage] Verificação pós-gravação:');
      print('   Token existe: ${savedToken != null}');
      print('   User ID existe: ${savedUserId != null}');
      print('   Phone existe: ${savedPhone != null}');
    } catch (e) {
      print('❌ [SecureStorage] ERRO ao gravar dados: $e');
      rethrow;
    }
  }

  /// ------------------ READ ------------------

  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      print('🔑 [SecureStorage] Token lido: ${token != null ? "EXISTE (${token.length} chars)" : "NULL"}');
      return token;
    } catch (e) {
      print('❌ [SecureStorage] Erro ao ler token: $e');
      return null;
    }
  }

  static Future<int?> getUserId() async {
    try {
      final idStr = await _storage.read(key: _userIdKey);
      final userId = idStr != null ? int.tryParse(idStr) : null;
      print('👤 [SecureStorage] User ID lido: $userId');
      return userId;
    } catch (e) {
      print('❌ [SecureStorage] Erro ao ler user ID: $e');
      return null;
    }
  }

  static Future<String?> getUserPhone() async {
    try {
      final phone = await _storage.read(key: _userPhoneKey);
      print('📞 [SecureStorage] Phone lido: $phone');
      return phone;
    } catch (e) {
      print('❌ [SecureStorage] Erro ao ler phone: $e');
      return null;
    }
  }

  /// ------------------ DELETE ------------------

  static Future<void> deleteToken() async {
    print('🗑️ [SecureStorage] Apagando token...');
    try {
      await _storage.delete(key: _tokenKey);
      print('✅ Token apagado');
    } catch (e) {
      print('❌ [SecureStorage] Erro ao apagar token: $e');
      rethrow;
    }
  }

  static Future<void> clearAll() async {
    print('🗑️ [SecureStorage] Apagando TODOS os dados...');
    try {
      await _storage.deleteAll();
      print('✅ Todos os dados apagados');
    } catch (e) {
      print('❌ [SecureStorage] Erro ao apagar dados: $e');
      rethrow;
    }
  }

  /// ------------------ DEBUG ------------------

  static Future<void> printAllKeys() async {
    print('🔍 [SecureStorage] Listando todas as chaves armazenadas:');
    try {
      final all = await _storage.readAll();
      if (all.isEmpty) {
        print('   (vazio)');
      } else {
        all.forEach((key, value) {
          print('   $key: ${value.length > 30 ? "${value.substring(0, 30)}..." : value}');
        });
      }
    } catch (e) {
      print('❌ [SecureStorage] Erro ao listar chaves: $e');
    }
  }
}