import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/repositories/auth_repository.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/utils/secure_storage.dart';

final authProvider =
AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final token = await SecureStorage.getToken();
    final phone = await SecureStorage.getUserPhone();
    final userId = await SecureStorage.getUserId();

    if (token == null || phone == null) return null;

    return UserModel(
      id: userId,
      phone: phone,
      token: token,
    );
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

      final user = UserModel.fromMap({
        ...authData['user'],
        'token': authData['token'],
      });

      await SecureStorage.saveAuthData(
        user.token!,
        user.id!,
        user.phone,
      );

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ============================================================
  // 👤 PERFIL
  // ============================================================

  Future<void> updateUserProfile({
    required String nome,
    required String apelido,
    required String email,
    required String genero,
    required DateTime dataNascimento,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

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

      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    state = const AsyncValue.data(null);
  }
}
