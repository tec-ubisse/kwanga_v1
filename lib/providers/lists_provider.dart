import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

/// ------------------------------------------------------------
///  FILTROS USADOS NA TELA DE LISTAS (LISTS SCREEN)
/// ------------------------------------------------------------

class ListFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setFilter(int index) => state = index;
}

final listFilterProvider = NotifierProvider<ListFilterNotifier, int>(
  ListFilterNotifier.new,
);

class ListSelectionModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void enable() => state = true;
  void disable() => state = false;
}

final listSelectionModeProvider =
NotifierProvider<ListSelectionModeNotifier, bool>(
  ListSelectionModeNotifier.new,
);

class SelectedListsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final updated = Set<String>.from(state);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = updated;
  }

  void clear() => state = {};
}

final selectedListsProvider =
NotifierProvider<SelectedListsNotifier, Set<String>>(
  SelectedListsNotifier.new,
);

/// ------------------------------------------------------------
///   PROVIDER DE DADOS — LISTAS (AsyncNotifier)
/// ------------------------------------------------------------

final listDaoProvider = Provider((ref) => ListDao());

class ListsNotifier extends AsyncNotifier<List<ListModel>> {
  @override
  Future<List<ListModel>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null || user.id == null) return [];

    return ref.read(listDaoProvider).getAllByUser(user.id!);
  }

  Future<void> addList({
    required String description,
    required String listType,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.id == null) return;

    final newList = ListModel(
      id: const Uuid().v4(),
      userId: user.id!,
      description: description,
      listType: listType,
    );

    await ref.read(listDaoProvider).insert(newList);
    ref.invalidateSelf();
  }

  Future<void> updateList(ListModel list) async {
    await ref.read(listDaoProvider).update(list);
    ref.invalidateSelf();
  }

  Future<void> deleteOne(String listId) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.id == null) return;

    await ref.read(listDaoProvider).delete(listId, user.id!);
    ref.invalidateSelf();
  }

  Future<void> restoreList(ListModel list) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.id == null) return;

    await ref.read(listDaoProvider).restore(list.id, user.id!);
    ref.invalidateSelf();
  }

  Future<void> deleteSelected() async {
    final user = ref.read(authProvider).value;
    final selectedIds = ref.read(selectedListsProvider);

    if (user == null || user.id == null || selectedIds.isEmpty) return;

    final dao = ref.read(listDaoProvider);

    await Future.wait(
      selectedIds.map((id) => dao.delete(id, user.id!)),
    );

    ref.read(selectedListsProvider.notifier).clear();
    ref.read(listSelectionModeProvider.notifier).disable();

    ref.invalidateSelf();
  }

  Future<void> syncPending() async {
    print("Sincronização de listas pendente...");
    await Future.delayed(const Duration(seconds: 1));
    ref.invalidateSelf();
  }
}

final listsProvider =
AsyncNotifierProvider<ListsNotifier, List<ListModel>>(() {
  return ListsNotifier();
});
