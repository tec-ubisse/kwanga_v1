import 'package:kwanga/domain/usecases/auth_usecases.dart';
import 'package:kwanga/utils/secure_storage.dart';

class CurrentUser {
  static int? _userId;
  static String? _userEmail;
  static final _authUsecases = AuthUseCases();



  static Future<int?> getUserId() async {

    if (_userId != null) return _userId;


    final savedId = await SecureStorage.getUserId();
    if (savedId != null) {
      _userId = savedId;
      return _userId;
    }

    final userData = await _authUsecases.getUserData();
    if (userData != null && userData['id'] != null) {
      _userId = userData['id'] as int;
      _userEmail = userData['email'] ?? '';

      await SecureStorage.saveAuthData(
        await SecureStorage.getToken() ?? '',
        _userId!,
        _userEmail ?? '',
      );

      return _userId;
    }

    return null;
  }


  static Future<String?> getUserEmail() async {

    if (_userEmail != null) return _userEmail;


    final email = await SecureStorage.getUserEmail();
    if (email != null) {
      _userEmail = email;
      return _userEmail;
    }


    final userData = await _authUsecases.getUserData();
    if (userData != null && userData['email'] != null) {
      _userEmail = userData['email'];
      _userId = userData['id'];

      await SecureStorage.saveAuthData(
        await SecureStorage.getToken() ?? '',
        _userId!,
        _userEmail!,
      );

      return _userEmail;
    }

    return null;
  }


  static Future<void> clear() async {
    _userId = null;
    _userEmail = null;
    await SecureStorage.clearAll();
  }
}
