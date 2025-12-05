import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:kwanga/models/project_action_model.dart';
import 'package:kwanga/data/database/project_actions_dao.dart';

final projectActionsProvider =
AsyncNotifierProvider<ProjectActionsNotifier, List<ProjectActionModel>>(() {
  return ProjectActionsNotifier();
});

class ProjectActionsNotifier extends AsyncNotifier<List<ProjectActionModel>> {
  final _dao = ProjectActionsDao();
  final _uuid = const Uuid();

  @override
  Future<List<ProjectActionModel>> build() async {
    // Inicialmente vazio — deve ser carregado por projectId
    return [];
  }

  Future<void> loadByProjectId(String projectId) async {
    final actions = await _dao.getActionsByProjectId(projectId);
    state = AsyncData(actions);
  }

  Future<void> addAction({
    required String projectId,
    required String description,
  }) async {
    final current = state.value ?? [];
    final newIndex = current.length; // último índice disponível

    final newAction = ProjectActionModel(
      id: _uuid.v4(),
      projectId: projectId,
      description: description.trim(),
      isDone: false,
      isDeleted: false,
      isSynced: false,
      orderIndex: newIndex,
    );

    await _dao.createAction(newAction);

    state = AsyncData([...current, newAction]);
  }

  Future<void> toggleActionDone(String actionId) async {
    final current = state.value ?? [];
    final action = current.firstWhere((a) => a.id == actionId);
    final updated = action.copyWith(isDone: !action.isDone);

    await _dao.updateAction(updated);

    state = AsyncData([
      for (final a in current) if (a.id == actionId) updated else a,
    ]);
  }

  Future<void> removeAction(String actionId) async {
    await _dao.deleteAction(actionId);

    final current = state.value ?? [];
    final newList = current.where((a) => a.id != actionId).toList();

    // Reindexar após remoção
    for (int i = 0; i < newList.length; i++) {
      newList[i] = newList[i].copyWith(orderIndex: i);
      await _dao.updateActionOrder(newList[i].id, i);
    }

    state = AsyncData(newList);
  }

  Future<void> editAction(ProjectActionModel updated) async {
    await _dao.updateAction(updated);

    final current = state.value ?? [];
    state = AsyncData([
      for (final a in current) if (a.id == updated.id) updated else a,
    ]);
  }

  // ✔ VERSÃO FINAL — reorder persistente
  Future<void> reorderActions(int oldIndex, int newIndex) async {
    final list = [...state.value!];

    if (newIndex > oldIndex) newIndex--;

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // atualizar índices em memória
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
    }

    state = AsyncData(list);

    // persistir ordem no banco
    for (final action in list) {
      await _dao.updateActionOrder(action.id, action.orderIndex);
    }
  }

  
}
