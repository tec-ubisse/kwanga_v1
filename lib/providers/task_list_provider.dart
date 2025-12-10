import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/providers/auth_provider.dart';
import '../data/database/list_dao.dart';

final listsDaoProvider = Provider((ref) => ListDao());
final taskListsProvider = FutureProvider<List<ListModel>>((ref) async {
  final auth = ref.watch(authProvider);
  final user = auth.value;

  if (auth.isLoading) {
    return [];
  }

  if (user == null || user.id == null) {
    return [];
  }

  final lists = await ref.read(listsDaoProvider).getAllByUser(user.id!);

  return lists;
});
