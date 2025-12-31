import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/services/sync_service.dart';

import '../auth_provider.dart';

/// ------------------------------------------------------------
/// DAO PROVIDER (domínio)
/// ------------------------------------------------------------
final taskDaoProvider = Provider((ref) => TaskDao());

/// ------------------------------------------------------------
/// TASKS NOTIFIER (DOMÍNIO)
/// ------------------------------------------------------------
class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() async {
    final user = ref.read(authProvider).value;
    if (user?.id == null) return [];

    final dao = ref.read(taskDaoProvider);
    return dao.getTaskByUserId(user!.id!);
  }

  List<TaskModel> get current => state.value ?? [];

  /// ------------------------------------------------------------
  /// INTERNAL HELPERS
  /// ------------------------------------------------------------
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

  Future<void> _syncLinkedInMemory(String linkedActionId) async {
    final dao = ref.read(taskDaoProvider);
    final linked = await dao.getTasksByLinkedActionId(linkedActionId);
    final map = {for (final t in linked) t.id: t};

    final merged = current.map((t) => map[t.id] ?? t).toList();
    state = AsyncData(merged);
  }

  /// ------------------------------------------------------------
  /// CREATE
  /// ------------------------------------------------------------
  Future<void> addTask(TaskModel task) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;

    state = AsyncData([...before, task]);

    try {
      await dao.insert(task);
      final saved = await dao.getTaskById(task.id);
      if (saved == null) {
        state = AsyncData(before);
        return;
      }

      var finalSaved = saved;

      if (saved.projectId != null &&
          (saved.linkedActionId == null ||
              saved.linkedActionId!.isEmpty)) {
        finalSaved = saved.copyWith(linkedActionId: saved.id);
        await dao.updateTask(finalSaved);
      }

      _upsertInMemory(finalSaved);
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  /// ------------------------------------------------------------
  /// UPDATE
  /// ------------------------------------------------------------
  Future<void> updateTask(TaskModel task) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;

    final idx = before.indexWhere((t) => t.id == task.id);
    if (idx == -1) return;

    final optimistic = [...before];
    optimistic[idx] = task;
    state = AsyncData(optimistic);

    try {
      await dao.updateTask(task);

      if (task.linkedActionId != null) {
        await SyncService.syncLinkedCopies(task, dao);
        await _syncLinkedInMemory(task.linkedActionId!);
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

    final updated =
    before[idx].copyWith(completed: isCompleted ? 1 : 0);

    final optimistic = [...before];
    optimistic[idx] = updated;
    state = AsyncData(optimistic);

    try {
      await dao.updateTaskStatus(taskId, isCompleted ? 1 : 0);

      if (updated.linkedActionId != null) {
        await SyncService.syncLinkedCopies(updated, dao);
        await _syncLinkedInMemory(updated.linkedActionId!);
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

  /// ------------------------------------------------------------
  /// DELETE
  /// ------------------------------------------------------------
  Future<void> deleteTask(String taskId) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;

    final target =
    before.firstWhere((t) => t.id == taskId);

    if (target.linkedActionId != null) {
      final linked =
      await dao.getTasksByLinkedActionId(target.linkedActionId!);
      final linkedIds = linked.map((t) => t.id).toSet();

      state = AsyncData(
        before.where((t) => !linkedIds.contains(t.id)).toList(),
      );

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

    state = AsyncData(before.where((t) => t.id != taskId).toList());

    try {
      await dao.deleteTask(taskId);
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> deleteTasks(List<String> taskIds) async {
    if (taskIds.isEmpty) return;

    final dao = ref.read(taskDaoProvider);
    final before = current;

    state = AsyncData(
      before.where((t) => !taskIds.contains(t.id)).toList(),
    );

    try {
      for (final id in taskIds) {
        await dao.deleteTask(id);
      }
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  /// ------------------------------------------------------------
  /// PROJECT / LIST OPERATIONS
  /// ------------------------------------------------------------
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
      frequency: projectTask.frequency == null
          ? null
          : List<String>.from(projectTask.frequency!),
      completed: projectTask.completed,
      linkedActionId:
      projectTask.linkedActionId ?? projectTask.id,
      orderIndex:
      isProjectList ? projectTask.orderIndex : null,
    );

    state = AsyncData([...before, copy]);

    try {
      await dao.insert(copy);
      final saved = await dao.getTaskById(copy.id);
      if (saved != null) _upsertInMemory(saved);
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> copyTaskToProject(
      String taskId, String newProjectId) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;

    final original =
    before.firstWhere((t) => t.id == taskId);

    final existing =
    await dao.getTasksByProjectId(newProjectId);
    final nextIndex = existing.length;

    final copy = TaskModel(
      userId: original.userId,
      listId: "project-$newProjectId",
      projectId: newProjectId,
      description: original.description,
      listType: original.listType,
      deadline: original.deadline,
      time: original.time,
      frequency: original.frequency == null
          ? null
          : List<String>.from(original.frequency!),
      completed: original.completed,
      linkedActionId:
      original.linkedActionId ?? original.id,
      orderIndex: nextIndex,
    );

    state = AsyncData([...before, copy]);

    try {
      await dao.insert(copy);
      final saved = await dao.getTaskById(copy.id);
      if (saved != null) _upsertInMemory(saved);
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }

  /// ------------------------------------------------------------
  /// MOVE ENTRY → ACTION LIST
  /// ------------------------------------------------------------
  Future<void> moveTaskToList({
    required String taskId,
    required String targetListId,
  }) async {
    final dao = ref.read(taskDaoProvider);
    final before = current;

    final idx = before.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final original = before[idx];

    // Apenas tarefas de entrada podem ser movidas
    if (original.listType == 'action') return;

    final updated = original.copyWith(
      listId: targetListId,
      listType: 'action',
      projectId: null,
      orderIndex: null,
      linkedActionId:
      original.linkedActionId ?? original.id,
    );

    final optimistic = [...before];
    optimistic[idx] = updated;
    state = AsyncData(optimistic);

    try {
      await dao.updateTask(updated);

      if (updated.linkedActionId != null) {
        await SyncService.syncLinkedCopies(updated, dao);
        await _syncLinkedInMemory(updated.linkedActionId!);
      }
    } catch (e) {
      state = AsyncData(before);
      rethrow;
    }
  }
}

/// ------------------------------------------------------------
/// FINAL PROVIDER
/// ------------------------------------------------------------
final tasksProvider =
AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(
    TasksNotifier.new);