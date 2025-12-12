// lib/providers/tasks_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/services/sync_service.dart';

import 'lists_provider.dart';

final taskDaoProvider = Provider((ref) => TaskDao());

final taskFilterProvider = NotifierProvider<TaskFilterNotifier, int>(TaskFilterNotifier.new);
class TaskFilterNotifier extends Notifier<int> { @override int build() => 0; void setFilter(int i) => state = i; }

final taskSelectionModeProvider = NotifierProvider<TaskSelectionModeNotifier, bool>(TaskSelectionModeNotifier.new);
class TaskSelectionModeNotifier extends Notifier<bool> { @override bool build() => false; void enable() => state = true; void disable() => state = false; }

final selectedTasksProvider = NotifierProvider<SelectedTasksNotifier, Set<String>>(SelectedTasksNotifier.new);
class SelectedTasksNotifier extends Notifier<Set<String>> {
  @override Set<String> build() => {};
  void toggle(String id) { final copy = Set<String>.from(state); copy.contains(id) ? copy.remove(id) : copy.add(id); state = copy; }
  void clear() => state = {};
}

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {

  Future<void> syncLinkedCopiesInMemory(String linkId) async {
    final dao = ref.read(taskDaoProvider);
    final refreshed = await dao.getTasksByLinkedActionId(linkId);

    final before = current;

    final updated = before.map((t) {
      if (t.linkedActionId == linkId) {
        final match = refreshed.firstWhere(
              (r) => r.id == t.id,
          orElse: () => t,
        );
        return match;
      }
      return t;
    }).toList();

    state = AsyncData(updated);
  }


  @override
  Future<List<TaskModel>> build() async {
    final user = ref.read(authProvider).value;
    if (user?.id == null) return [];
    final dao = ref.read(taskDaoProvider);
    final tasks = await dao.getTaskByUserId(user!.id!);
    return tasks;
  }

  List<TaskModel> get current => state.value ?? [];

  void _upsertInMemory(TaskModel t) {
    final before = current;
    final idx = before.indexWhere((x) => x.id == t.id);
    if (idx == -1) {
      state = AsyncData([...before, t]);
    } else {
      final copy = [...before];
      copy[idx] = t;
      state = AsyncData(copy);
    }
  }

  Future<void> refreshLinkedInMemory(String linkedActionId) async {
    final dao = ref.read(taskDaoProvider);
    final linked = await dao.getTasksByLinkedActionId(linkedActionId);
    final map = {for (final t in linked) t.id: t};
    final merged = current.map((t) => map[t.id] ?? t).toList();
    state = AsyncData(merged);
  }

  Future<void> syncLinkedTasks(String linkedActionId) async {
    await refreshLinkedInMemory(linkedActionId);
  }

  Future<void> addTask(TaskModel task) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;
    final optimistic = [...before, task];
    state = AsyncData(optimistic);

    try {
      await dao.insert(task);
      final saved = await dao.getTaskById(task.id);
      if (saved == null) {
        state = AsyncData(before);
        return;
      }

      TaskModel finalSaved = saved;
      if (saved.projectId != null && (saved.linkedActionId == null || saved.linkedActionId!.isEmpty)) {
        finalSaved = saved.copyWith(linkedActionId: saved.id);
        await dao.updateTask(finalSaved);
      }

      _upsertInMemory(finalSaved);
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;

    final idx = before.indexWhere((t) => t.id == task.id);
    if (idx == -1) return;

    // Optimistic
    final optimistic = [...before];
    optimistic[idx] = task;
    state = AsyncData(optimistic);

    try {
      await dao.updateTask(task);

      // Nova lógica: sincronizar cópias antes de repor UI
      if (task.linkedActionId != null) {
        await SyncService.syncLinkedCopies(task, dao);
        await syncLinkedCopiesInMemory(task.linkedActionId!);
      } else {
        final refreshed = await dao.getTaskById(task.id);
        if (refreshed != null) {
          optimistic[idx] = refreshed;
          state = AsyncData(optimistic);
        }
      }
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;

    final idx = before.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final old = before[idx];
    final updated = old.copyWith(completed: isCompleted ? 1 : 0);

    final optimistic = [...before];
    optimistic[idx] = updated;
    state = AsyncData(optimistic);

    try {
      await dao.updateTaskStatus(taskId, isCompleted ? 1 : 0);

      if (updated.linkedActionId != null) {
        await SyncService.syncLinkedCopies(updated, dao);
        await syncLinkedCopiesInMemory(updated.linkedActionId!);
      } else {
        final refreshed = await dao.getTaskById(taskId);
        if (refreshed != null) {
          optimistic[idx] = refreshed;
          state = AsyncData(optimistic);
        }
      }
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;
    final target = before.firstWhere((t) => t.id == taskId, orElse: () => throw Exception("Task not found"));

    if (target.linkedActionId != null) {
      final linked = await dao.getTasksByLinkedActionId(target.linkedActionId!);
      final linkedIds = linked.map((t) => t.id).toSet();
      final optimistic = before.where((t) => !linkedIds.contains(t.id)).toList();
      state = AsyncData(optimistic);

      try {
        for (final id in linkedIds) {
          await dao.deleteTask(id);
        }
      } catch (e) {
        state = AsyncData(before);
        rethrow;
      }
      return;
    }

    final optimistic = before.where((t) => t.id != taskId).toList();
    state = AsyncData(optimistic);
    try {
      await dao.deleteTask(taskId);
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> deleteSelected() async {
    final dao = ref.read(taskDaoProvider);
    final selected = ref.read(selectedTasksProvider);
    if (selected.isEmpty) return;
    final before = current;
    final optimistic = before.where((t) => !selected.contains(t.id)).toList();
    state = AsyncData(optimistic);

    try {
      for (final id in selected) {
        await dao.deleteTask(id);
      }
      ref.read(selectedTasksProvider.notifier).clear();
      ref.read(taskSelectionModeProvider.notifier).disable();
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> allocateProjectTaskToList({
    required TaskModel projectTask,
    required String targetListId,
    required int userId,
  }) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;

    final isProjectList = targetListId.startsWith("project-");

    final copy = TaskModel(
      userId: userId,
      listId: targetListId,
      projectId: isProjectList ? projectTask.projectId : null,
      description: projectTask.description,
      listType: 'action',
      deadline: projectTask.deadline,
      time: projectTask.time,
      frequency: projectTask.frequency == null ? null : List<String>.from(projectTask.frequency!),
      completed: projectTask.completed,
      linkedActionId: projectTask.linkedActionId ?? projectTask.id,
      orderIndex: isProjectList ? projectTask.orderIndex : null,
    );

    // Atualizar estado para UI imediatamente
    state = AsyncData([...before, copy]);

    try {
      await dao.insert(copy);

      final saved = await dao.getTaskById(copy.id);
      if (saved != null) {
        _upsertInMemory(saved);
      }
    } catch (e) {
      // Reverter caso BD falhe
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> copyTaskToProject(String taskId, String newProjectId) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;

    final original =
    before.firstWhere((t) => t.id == taskId, orElse: () => throw Exception("Task not found"));

    final existing = await dao.getTasksByProjectId(newProjectId);
    final nextIndex = existing.length;

    final copy = TaskModel(
      userId: original.userId,
      listId: "project-$newProjectId",
      projectId: newProjectId,
      description: original.description,
      listType: original.listType,
      deadline: original.deadline,
      time: original.time,
      frequency:
      original.frequency == null ? null : List<String>.from(original.frequency!),
      completed: original.completed,
      linkedActionId: original.linkedActionId ?? original.id,
      orderIndex: nextIndex,
    );

    final optimistic = [...before, copy];
    state = AsyncData(optimistic);

    try {
      await dao.insert(copy);
      final saved = await dao.getTaskById(copy.id);
      if (saved != null) {
        _upsertInMemory(saved);
      }
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> reorderProjectTasks(
      String projectId, int oldIndex, int newIndex) async {
    final before = current;
    final dao = ref.read(taskDaoProvider);

    final projectTasks = before.where((t) => t.projectId == projectId).toList();
    if (projectTasks.isEmpty) return;

    final moved = [...projectTasks];

    if (newIndex > oldIndex) newIndex--;

    final item = moved.removeAt(oldIndex);
    moved.insert(newIndex, item);

    // Atualizar ordem no BD
    for (int i = 0; i < moved.length; i++) {
      if (moved[i].orderIndex != i) {
        final updated = moved[i].copyWith(orderIndex: i);
        await dao.updateTask(updated); // usa updated.toMap()
      }
    }

    // Atualizar estado global
    final updatedGlobal = <TaskModel>[];
    final added = <String>{};

    for (final t in before) {
      if (t.projectId == projectId) {
        final next = moved.firstWhere((m) => !added.contains(m.id), orElse: () => t);
        updatedGlobal.add(next);
        added.add(next.id);
      } else {
        updatedGlobal.add(t);
      }
    }

    state = AsyncData(updatedGlobal);
  }

}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

final tasksByListProvider = Provider.family<List<TaskModel>, String>((ref, listId) {
  final asyncTasks = ref.watch(tasksProvider);
  return asyncTasks.when(
    data: (tasks) => tasks.where((task) => task.listId == listId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
