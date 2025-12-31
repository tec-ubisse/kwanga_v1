import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/repositories/auth_repository.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/utils/secure_storage.dart';
import 'package:kwanga/data/database/user_dao.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final UserDao _userDao;

  // ============================================================
  // 🔁 BOOTSTRAP / AUTO-LOGIN
  // ============================================================

  @override
  Future<UserModel?> build() async {
    _userDao = UserDao();

    final token = await SecureStorage.getToken();
    final phone = await SecureStorage.getUserPhone();
    final userId = await SecureStorage.getUserId();

    if (token == null || phone == null || userId == null) {
      return null;
    }

    // ✅ Busca usuário completo do banco local
    final existingUser = await _userDao.getById(userId);

    if (existingUser != null) {
      return existingUser;
    }

    // ⚠️ Usuário mínimo (restore parcial / primeiro arranque)
    final user = UserModel(
      id: userId,
      phone: phone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: true,
    );

    // ✅ Garante existência local SEM apagar dados futuros
    await _userDao.insertOrReplace(user);

    return user;
  }

  // ============================================================
  // 🔐 LOGIN OTP
  // ============================================================

  Future<void> verifyOTP(
      String phone,
      String code,
      ) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(authRepositoryProvider);
      final authData = await repo.loginVerifyOTP(phone, code);

      final userData = authData['user'] as Map<String, dynamic>;
      final token = authData['token'] as String;

      final user = UserModel.fromMap(userData);

      // 🔐 Token fica apenas no SecureStorage
      await SecureStorage.saveAuthData(
        token,
        user.id!,
        user.phone,
      );

      // 👤 User sem token no SQLite
      await _userDao.insertOrReplace(user);

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ============================================================
  // 👤 PERFIL — UPDATE VIA BACKEND
  // ============================================================

  Future<void> updateUserProfile({
    required String nome,
    required String apelido,
    required String email,
    required String genero,
    required DateTime dataNascimento,
  }) async {
    final currentUser = state.value;
    if (currentUser == null || currentUser.id == null) {
      throw Exception('Usuário não autenticado');
    }

    state = const AsyncValue.loading();

    try {
      final repo = ref.read(authRepositoryProvider);
      final data = await repo.updateProfile(
        nome: nome,
        apelido: apelido,
        email: email,
        genero: genero,
        dataNascimento: dataNascimento,
      );

      final updatedUser = currentUser.copyWith(
        nome: data['first_name'],
        apelido: data['last_name'],
        email: data['email'],
        genero: data['gender'],
        dataNascimento: data['date_of_birth'] != null
            ? DateTime.parse(data['date_of_birth'])
            : null,
        updatedAt: DateTime.now(),
        isSynced: true,
      );

      await _userDao.update(updatedUser);

      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ============================================================
  // 🛠 PERFIL — UPDATE LOCAL (RESTORE / OFFLINE / CORREÇÃO)
  // ============================================================

  /// 🔥 ESTE MÉTODO É O QUE FALTAVA
  /// Usado pela tela "Editar Perfil"
  /// Não chama backend
  /// Não mexe em token
  /// Marca isSynced = false
  Future<void> updateLocalProfile(UserModel updatedUser) async {
    final currentUser = state.value;
    if (currentUser == null || currentUser.id == null) return;

    final merged = currentUser.copyWith(
      nome: updatedUser.nome,
      apelido: updatedUser.apelido,
      email: updatedUser.email,
      genero: updatedUser.genero,
      dataNascimento: updatedUser.dataNascimento,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    // 🔁 Atualiza estado em memória
    state = AsyncValue.data(merged);

    // 💾 Persiste APENAS no SQLite
    await _userDao.update(merged);
  }

  // ============================================================
  // 🔄 REFRESH USER (do banco local)
  // ============================================================

  Future<void> refreshUser() async {
    final currentUser = state.value;
    if (currentUser?.id == null) return;

    try {
      final updatedUser = await _userDao.getById(currentUser!.id!);
      if (updatedUser != null) {
        state = AsyncValue.data(updatedUser);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ============================================================
  // 🚪 LOGOUT
  // ============================================================

  Future<void> logout() async {
    await SecureStorage.clearAll();
    state = const AsyncValue.data(null);
  }
}
