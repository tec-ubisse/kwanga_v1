import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/repositories/auth_repository.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/utils/secure_storage.dart';
import 'package:kwanga/data/database/user_dao.dart';

import '../data/repositories/user_sync_service.dart';

/// 🔧 FLAG GLOBAL — DEV MODE
/// true  → usuário sempre logado
/// false → autenticação real (OTP + SecureStorage)
const bool kDevAutoLogin = true;

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final UserDao _userDao;

  // ============================================================
  // 🚀 BOOTSTRAP AUTH
  // ============================================================
  @override
  Future<UserModel?> build() async {
    _userDao = UserDao();

    // ============================================================
    // 🔧 DEV MODE — USUÁRIO SEMPRE LOGADO
    // ============================================================
    if (kDevAutoLogin) {
      const devUserId = 1;

      final existingUser = await _userDao.getById(devUserId);
      if (existingUser != null) {
        return existingUser;
      }

      final devUser = UserModel(
        id: devUserId,
        phone: '+258840000000',
        nome: 'Usuário',
        apelido: 'Dev',
        email: 'dev@kwanga.app',
        genero: 'Outro',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: true,
        isDeleted: false,
      );

      await _userDao.ensureUser(devUser);
      return devUser;
    }

    // ============================================================
    // 🔐 PRODUÇÃO — LOGIN REAL (INALTERADO)
    // ============================================================
    final token = await SecureStorage.getToken();
    final phone = await SecureStorage.getUserPhone();
    final userId = await SecureStorage.getUserId();

    if (token == null || phone == null || userId == null) {
      return null;
    }

    final existingUser = await _userDao.getById(userId);
    if (existingUser != null) {
      return existingUser;
    }

    final minimalUser = UserModel(
      id: userId,
      phone: phone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _userDao.ensureUser(minimalUser);

    return await _userDao.getById(userId) ?? minimalUser;
  }

  // ============================================================
  // 🔐 LOGIN OTP (mantido para PROD)
  // ============================================================
  Future<void> verifyOTP(String phone, String code) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(authRepositoryProvider);
      final authData = await repo.loginVerifyOTP(phone, code);

      final user = authData['user'] as UserModel;
      final token = authData['token'] as String;

      await SecureStorage.saveAuthData(token, user.id!, user.phone);
      await _userDao.insertOrReplaceFromApi(user);

      final persistedUser = await _userDao.getById(user.id!);
      state = AsyncValue.data(persistedUser ?? user);
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
  // 🛠 PERFIL — UPDATE LOCAL (OFFLINE)
  // ============================================================
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

    state = AsyncValue.data(merged);
    await _userDao.update(merged);
  }

  // ============================================================
  // 🔄 REFRESH USER
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
  // 🔄 SYNC
  // ============================================================
  Future<void> syncIfNeeded() async {
    if (kDevAutoLogin) return;

    final service = UserSyncService(
      _userDao,
      ref.read(authRepositoryProvider),
    );

    await service.syncUsers();
    await refreshUser();
  }

  // ============================================================
  // 🚪 LOGOUT
  // ============================================================
  Future<void> logout() async {
    if (!kDevAutoLogin) {
      await SecureStorage.clearAll();
    }
    state = const AsyncValue.data(null);
  }
}
