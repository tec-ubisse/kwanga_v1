import 'package:kwanga/data/database/user_dao.dart';
import 'package:kwanga/data/repositories/auth_repository.dart';
import 'package:kwanga/models/user.dart';

class UserSyncService {
  final UserDao _userDao;
  final AuthRepository _authRepository;

  UserSyncService(this._userDao, this._authRepository);

  Future<void> syncUsers() async {
    final unsyncedUsers = await _userDao.getUnsyncedUsers();

    for (final user in unsyncedUsers) {
      try {
        await _syncSingleUser(user);
      } catch (_) {
        // falha isolada, não bloqueia os outros
      }
    }
  }

  Future<void> _syncSingleUser(UserModel user) async {
    if (user.isSynced) return;

    if (user.nome == null ||
        user.apelido == null ||
        user.email == null ||
        user.genero == null ||
        user.dataNascimento == null) {
      return;
    }

    // 🌐 LOCAL → BACKEND (local wins)
    await _authRepository.updateProfile(
      nome: user.nome!,
      apelido: user.apelido!,
      email: user.email!,
      genero: user.genero!,
      dataNascimento: user.dataNascimento!,
    );

    // ✅ Backend confirmou → apenas marca como sincronizado
    final syncedUser = user.copyWith(
      updatedAt: DateTime.now(),
      isSynced: true,
    );

    await _userDao.update(syncedUser);
  }
}
