import 'package:kwanga/data/repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository _repo = AuthRepository();

  Future<bool> loginUser(String email, String password) async {
    print('Auth: $email Pass: $password');
    return await _repo.login(email, password);
  }

  Future<bool> registerUser(String email, String password) async {
    return await _repo.register(email, password);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return await _repo.getUserData();
  }

  Future<bool> logoutUser() async {
    return await _repo.logout();
  }

  Future<bool> verifyEmail(String email, String code) async {
    return await _repo.verifyEmail(email, code);
  }
}
