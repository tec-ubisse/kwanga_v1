import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/database/lists_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/providers/task_list_provider.dart';
import 'package:uuid/uuid.dart';

/// ------------------------------------------------------------
///  FILTROS (UI State)
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
    updated.contains(id) ? updated.remove(id) : updated.add(id);
    state = updated;
  }

  void clear() => state = {};
}

final selectedListsProvider =
    NotifierProvider<SelectedListsNotifier, Set<String>>(
      SelectedListsNotifier.new,
    );

/// ------------------------------------------------------------
///  DAO Provider
/// ------------------------------------------------------------

final listDaoProvider = Provider((ref) => ListDao());

final listsByIdProvider = Provider<Map<String, String>>((ref) {
  final asyncLists = ref.watch(taskListsProvider);

  return asyncLists.when(
    data: (lists) => {for (final l in lists) l.id: l.description},
    loading: () => {},
    error: (_, __) => {},
  );
});

final appMessageProvider = NotifierProvider<AppMessageNotifier, String?>(
  AppMessageNotifier.new,
);

class AppMessageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String msg) => state = msg;

  void clear() => state = null;
}

/// ------------------------------------------------------------
///  LISTS NOTIFIER (AsyncNotifier)
/// ------------------------------------------------------------

class ListsNotifier extends AsyncNotifier<List<ListModel>> {
  @override
  Future<List<ListModel>> build() async {
    final auth = ref.watch(authProvider);

    return auth.maybeWhen(
      data: (user) async {
        if (user == null || user.id == null) return [];
        // Aqui EXCLUÍMOS listas de projecto da UI
        return await ref
            .read(listDaoProvider)
            .getAllByUser(user.id!, excludeProject: true);
      },
      orElse: () => [],
    );
  }

  /// ------------------------------------------------------------
  /// ADD LIST (listas normais → isProject = false)
  /// ------------------------------------------------------------
  Future<void> addList({
    required String description,
    required String listType,
  }) async {
    final auth = ref.watch(authProvider);
    final user = auth.value;
    if (user == null || user.id == null) return;

    final newList = ListModel(
      id: const Uuid().v4(),
      userId: user.id!,
      description: description,
      listType: listType,
      isProject: false, // <-- MUITO IMPORTANTE
    );

    await ref.read(listDaoProvider).insert(newList);

    ref.invalidateSelf();
  }

  /// ------------------------------------------------------------
  /// UPDATE LIST
  /// ------------------------------------------------------------
  Future<void> updateList(ListModel list) async {
    await ref.read(listDaoProvider).update(list);
    ref.invalidateSelf();
  }

  /// ------------------------------------------------------------
  /// DELETE ONE
  /// ------------------------------------------------------------
  Future<void> deleteOne(String listId) async {
    final auth = ref.watch(authProvider);
    final user = auth.value;
    if (user == null || user.id == null) return;

    await ref.read(listDaoProvider).delete(listId, user.id!);
    ref.invalidateSelf();
  }

  /// ------------------------------------------------------------
  /// RESTORE LIST
  /// ------------------------------------------------------------
  Future<void> restoreList(ListModel list) async {
    final auth = ref.watch(authProvider);
    final user = auth.value;
    if (user == null || user.id == null) return;

    await ref.read(listDaoProvider).restore(list.id, user.id!);
    ref.invalidateSelf();
  }

  /// ------------------------------------------------------------
  /// DELETE SELECTED
  /// ------------------------------------------------------------
  Future<void> deleteSelected() async {
    final auth = ref.watch(authProvider);
    final user = auth.value;
    final selected = ref.read(selectedListsProvider);

    if (user == null || user.id == null || selected.isEmpty) return;

    final dao = ref.read(listDaoProvider);

    await Future.wait(selected.map((id) => dao.delete(id, user.id!)));

    ref.read(selectedListsProvider.notifier).clear();
    ref.read(listSelectionModeProvider.notifier).disable();

    ref.invalidateSelf();
  }

  /// ------------------------------------------------------------
  /// FAKE SYNC (placeholder)
  /// ------------------------------------------------------------
  Future<void> syncPending() async {
    await Future.delayed(const Duration(milliseconds: 800));
    ref.invalidateSelf();
  }
}

/// ------------------------------------------------------------
/// FINAL PROVIDER
/// ------------------------------------------------------------
final listsProvider = AsyncNotifierProvider<ListsNotifier, List<ListModel>>(
  ListsNotifier.new,

);

