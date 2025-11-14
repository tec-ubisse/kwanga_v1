import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/repositories/auth_repository.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/utils/secure_storage.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    try {
      final token = await SecureStorage.getToken();
      final userId = await SecureStorage.getUserId();
      final userEmail = await SecureStorage.getUserEmail();

      if (token != null && userId != null && userEmail != null) {
        return UserModel(id: userId, email: userEmail);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();

    try {
      final authData = await authRepository.login(email, password);

      final user = authData['user'];
      final token = authData['token'];

      await SecureStorage.saveAuthData(token, user['id'], user['email']);

      state = AsyncValue.data(UserModel.fromMap({...user, 'token': token}));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String email, String password) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();

    try {
      await authRepository.register(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> verifyEmail(String email, String code) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();

    try {
      final authData = await authRepository.verifyEmail(email, code);
      final user = authData['user'];
      final token = authData['token'];

      await SecureStorage.saveAuthData(token, user['id'], user['email']);

      state = AsyncValue.data(UserModel.fromMap({...user, 'token': token}));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// ✅ Corrigido aqui — usa o authRepositoryProvider
  Future<void> resendVerificationCode(String email) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();

    try {
      await authRepository.resendVerificationCode(email);
      state = AsyncValue.data(state.value); // mantém o estado anterior
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {}

    await SecureStorage.clearAll();
    state = const AsyncValue.data(null);
  }
}
