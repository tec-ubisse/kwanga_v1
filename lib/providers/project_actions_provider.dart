import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/providers/tasks_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:kwanga/models/project_action_model.dart';
import 'package:kwanga/data/database/project_actions_dao.dart';

import 'package:kwanga/models/task_model.dart';

import '../services/sync_service.dart';

final projectActionsProvider =
AsyncNotifierProvider<ProjectActionsNotifier, List<ProjectActionModel>>(
    ProjectActionsNotifier.new);

// -----------------------------------------------------------------------------
// Notifier
// -----------------------------------------------------------------------------
class ProjectActionsNotifier extends AsyncNotifier<List<ProjectActionModel>> {
  final _dao = ProjectActionsDao();
  final _uuid = const Uuid();

  bool _isSyncing = false; // evita loops recursivos Task <-> Action

  String? _currentProjectId;

  @override
  Future<List<ProjectActionModel>> build() async {
    return [];
  }

  // ---------------------------------------------------------------------------
  // Carregar ações do projeto
  // ---------------------------------------------------------------------------
  Future<void> loadByProjectId(String projectId) async {
    _currentProjectId = projectId;
    final actions = await _dao.getActionsByProjectId(projectId);
    state = AsyncData(actions);
  }

  // ---------------------------------------------------------------------------
  // Criar nova ação
  // ---------------------------------------------------------------------------
  Future<void> addAction({
    required String projectId,
    required String description,
  }) async {
    final current = state.value ?? [];
    final newIndex = current.length;

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

    if (projectId == _currentProjectId) {
      state = AsyncData([...current, newAction]);
    }
  }

  // ---------------------------------------------------------------------------
  // Mover ação para outro projeto
  // ---------------------------------------------------------------------------
  Future<void> moveActionToProject(
      String actionId, String newProjectId) async {
    final actions = state.value ?? [];
    final index = actions.indexWhere((a) => a.id == actionId);
    if (index == -1) return;

    final action = actions[index];

    final newProjectActions =
    await _dao.getActionsByProjectId(newProjectId);
    final newOrderIndex = newProjectActions.length;

    final updated = action.copyWith(
      projectId: newProjectId,
      orderIndex: newOrderIndex,
    );

    await _dao.updateAction(updated);



    final remaining = [...actions]..removeAt(index);

    for (int i = 0; i < remaining.length; i++) {
      remaining[i] = remaining[i].copyWith(orderIndex: i);
      await _dao.updateActionOrder(remaining[i].id, i);
    }

    state = AsyncData(remaining);
  }

  // ---------------------------------------------------------------------------
  // Togglar estado done (com sincronização para tasks)
  // ---------------------------------------------------------------------------
  Future<void> toggleActionDone(String actionId) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final current = state.value ?? [];
      final action = current.firstWhere((a) => a.id == actionId);
      final updated = action.copyWith(isDone: !action.isDone);

      // atualizar DB
      await _dao.updateAction(updated);

      // atualizar estado UI
      state = AsyncData([
        for (final a in current) if (a.id == actionId) updated else a,
      ]);

      // 🔥 sincronizar tasks ligadas
      await SyncService.syncActionToTasks(ref, updated);

    } finally {
      _isSyncing = false;
    }
  }


  // ---------------------------------------------------------------------------
  // Remover ação
  // ---------------------------------------------------------------------------
  Future<void> removeAction(String actionId) async {
    await _dao.deleteAction(actionId);

    final current = state.value ?? [];
    final newList =
    current.where((a) => a.id != actionId).toList();

    for (int i = 0; i < newList.length; i++) {
      newList[i] = newList[i].copyWith(orderIndex: i);
      await _dao.updateActionOrder(newList[i].id, i);
    }

    state = AsyncData(newList);
  }

  // ---------------------------------------------------------------------------
  // Editar descrição
  // ---------------------------------------------------------------------------
  Future<void> editAction(ProjectActionModel updated) async {
    await _dao.updateAction(updated);

    final current = state.value ?? [];

    state = AsyncData([
      for (final a in current) if (a.id == updated.id) updated else a,
    ]);

    // 🔥 atualizar tasks ligadas (descrição + done se necessário)
    await SyncService.syncActionToTasks(ref, updated);
  }


  // ---------------------------------------------------------------------------
  // Reordenar ações
  // ---------------------------------------------------------------------------
  Future<void> reorderActions(int oldIndex, int newIndex) async {
    final list = [...state.value!];

    if (newIndex > oldIndex) newIndex--;

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
      await _dao.updateActionOrder(list[i].id, i);
    }

    state = AsyncData(list);
  }

  // ---------------------------------------------------------------------------
  // Alocar ação numa Task (cria Task com vínculo)
  // ---------------------------------------------------------------------------
  Future<void> allocateActionToList(
      ProjectActionModel action,
      String listId,
      int userId,
      ) async {
    final taskDao = ref.read(taskDaoProvider);

    final task = TaskModel(
      userId: userId,
      listId: listId,
      description: action.description,
      listType: "action",
      completed: action.isDone ? 1 : 0,
      linkedActionId: action.id,
    );

    await taskDao.insert(task);
  }
}
