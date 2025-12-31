// lib/providers/project_actions_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/tasks/tasks_notifier.dart';
import 'package:kwanga/data/database/task_dao.dart';

final projectActionsDaoProvider = Provider((ref) => TaskDao());

final projectActionsProvider =
AsyncNotifierProvider<ProjectActionsNotifier, List<TaskModel>>(
  ProjectActionsNotifier.new,
);

class ProjectActionsNotifier extends AsyncNotifier<List<TaskModel>> {
  late final TaskDao _dao;
  String? _projectId;

  @override
  Future<List<TaskModel>> build() async {
    _dao = ref.read(projectActionsDaoProvider);
    return <TaskModel>[];
  }

  // -------------------------------------------------------------
  // LOAD ACTIONS
  // -------------------------------------------------------------
  Future<void> loadByProjectId(String projectId) async {
    _projectId = projectId;
    final list = await _dao.getTasksByProjectId(projectId);
    state = AsyncData(List<TaskModel>.from(list));
  }

  // -------------------------------------------------------------
  // ADD ACTION
  // -------------------------------------------------------------
  Future<void> addAction({
    required String projectId,
    required int userId,
    required String description,
  }) async {
    final newTask = TaskModel(
      userId: userId,
      listId: 'project-$projectId',
      projectId: projectId,
      description: description.trim(),
      listType: 'action',
      completed: 0,
    );

    await ref.read(tasksProvider.notifier).addTask(newTask);

    // Recarregar apenas se estiver no mesmo projeto
    if (_projectId == projectId) {
      final refreshed = await _dao.getTasksByProjectId(projectId);
      state = AsyncData(List<TaskModel>.from(refreshed));
    }
  }

  // -------------------------------------------------------------
  // EDIT ACTION
  // -------------------------------------------------------------
  Future<void> editAction(TaskModel updated) async {
    await ref.read(tasksProvider.notifier).updateTask(updated);

    if (_projectId != null && updated.projectId != null) {
      final refreshed =
      await _dao.getTasksByProjectId(updated.projectId!);
      state = AsyncData(List<TaskModel>.from(refreshed));
    }
  }

  // -------------------------------------------------------------
  // TOGGLE COMPLETE
  // -------------------------------------------------------------
  Future<void> toggleActionDone(String actionId) async {
    final items = state.value ?? [];
    final idx = items.indexWhere((t) => t.id == actionId);
    if (idx == -1) return;

    final action = items[idx];

    await ref.read(tasksProvider.notifier).updateTaskStatus(
      actionId,
      action.completed == 0,
    );

    if (_projectId != null && action.projectId != null) {
      final refreshed =
      await _dao.getTasksByProjectId(action.projectId!);
      state = AsyncData(List<TaskModel>.from(refreshed));
    }
  }

  // -------------------------------------------------------------
  // REMOVE ACTION
  // -------------------------------------------------------------
  Future<void> removeAction(String actionId) async {
    await ref.read(tasksProvider.notifier).deleteTask(actionId);

    if (_projectId != null) {
      final refreshed =
      await _dao.getTasksByProjectId(_projectId!);
      state = AsyncData(List<TaskModel>.from(refreshed));
    }
  }

  // -------------------------------------------------------------
  // ALLOCATE ACTION TO LIST
  // -------------------------------------------------------------
  Future<void> allocateActionToList(TaskModel action,
      String listId,
      int userId,) async {
    await ref.read(tasksProvider.notifier).allocateProjectTaskToList(
        projectTask: action, targetListId: listId, userId: userId);

    if (_projectId != null) {
      final refreshed =
      await _dao.getTasksByProjectId(_projectId!);
      state = AsyncData(List<TaskModel>.from(refreshed));
    }
  }

  // -------------------------------------------------------------
  // MOVE ACTION TO ANOTHER PROJECT
  // -------------------------------------------------------------
  Future<void> moveActionToProject(String actionId, String newProjectId) async {
    final items = state.value ?? [];
    final idx = items.indexWhere((a) => a.id == actionId);
    if (idx == -1) return;

    final action = items[idx];

    final updated = action.copyWith(
      projectId: newProjectId,
      listId: 'project-$newProjectId',
    );

    await ref.read(tasksProvider.notifier).updateTask(updated);

    if (_projectId != null) {
      final refreshed =
      await _dao.getTasksByProjectId(_projectId!);
      state = AsyncData(List<TaskModel>.from(refreshed));
    }
  }

  // -------------------------------------------------------------
  // REORDER ACTIONS (OTIMIZADO E SEGURO)
  // -------------------------------------------------------------
  Future<void> reorderActions(int oldIndex, int newIndex) async {
    final items = state.value ?? [];
    if (items.isEmpty) return;

    // Cópia segura
    final list = List<TaskModel>.from(items);

    // Ajuste do newIndex (comportamento padrão do ReorderableListView)
    // Quando move para baixo, o Flutter conta como se o item ainda estivesse lá
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);

    // UI otimista imediata
    state = AsyncData(List<TaskModel>.from(list));

    try {
      // Atualizar apenas orderIndex alterados
      final updates = <Future>[];

      for (int i = 0; i < list.length; i++) {
        final task = list[i];
        if (task.orderIndex != i) {
          final updated = task.copyWith(orderIndex: i);
          updates.add(
            ref.read(tasksProvider.notifier).updateTask(updated),
          );
        }
      }

      // Executa updates em paralelo
      await Future.wait(updates);

      // Garantir estado final consistente
      if (_projectId != null) {
        final refreshed =
        await _dao.getTasksByProjectId(_projectId!);
        state = AsyncData(List<TaskModel>.from(refreshed));
      }
    } catch (e) {
      // Fallback seguro
      if (_projectId != null) {
        final refreshed =
        await _dao.getTasksByProjectId(_projectId!);
        state = AsyncData(List<TaskModel>.from(refreshed));
      }
    }
  }
}