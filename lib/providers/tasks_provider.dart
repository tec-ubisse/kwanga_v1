import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/data/database/project_actions_dao.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/auth_provider.dart';

final taskFilterProvider =
NotifierProvider<TaskFilterNotifier, int>(TaskFilterNotifier.new);

class TaskFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setFilter(int index) => state = index;
}

final taskSelectionModeProvider = NotifierProvider<TaskSelectionModeNotifier, bool>(
  TaskSelectionModeNotifier.new,
);

class TaskSelectionModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void enable() => state = true;
  void disable() => state = false;
}

final selectedTasksProvider =
NotifierProvider<SelectedTasksNotifier, Set<String>>(SelectedTasksNotifier.new);

class SelectedTasksNotifier extends Notifier<Set<String>> {
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

final taskDaoProvider = Provider((ref) => TaskDao());
final projectActionsDaoProvider = Provider((ref) => ProjectActionsDao());

final progressByListProvider =
NotifierProvider<ProgressByListNotifier, Map<String, Map<String, int>>>(
  ProgressByListNotifier.new,
);

class ProgressByListNotifier extends Notifier<Map<String, Map<String, int>>> {
  @override
  Map<String, Map<String, int>> build() => {};

  void replaceAll(Map<String, Map<String, int>> newProgress) {
    state = Map.from(newProgress);
  }

  void updateList(String listId, int total, int completed) {
    final updated = Map<String, Map<String, int>>.from(state);
    updated[listId] = {'total': total, 'completed': completed};
    state = updated;
  }

  Map<String, int> getForList(String listId) {
    return state[listId] ?? {'total': 0, 'completed': 0};
  }
}

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  bool _isSyncing = false;

  @override
  Future<List<TaskModel>> build() async {
    final user = ref.read(authProvider).value;

    if (user?.id == null) return [];

    final dao = ref.read(taskDaoProvider);
    final tasks = await dao.getTaskByUserId(user!.id!);

    // 🔥 CORRIGIDO: Reconstruir o cache de progresso no load inicial
    _rebuildProgressCache(tasks);

    return tasks;
  }

  void _rebuildProgressCache(List<TaskModel> tasks) {
    final progress = <String, Map<String, int>>{};

    for (final t in tasks) {
      progress[t.listId] ??= {'total': 0, 'completed': 0};
      progress[t.listId]!['total'] = (progress[t.listId]!['total'] ?? 0) + 1;
      if (t.completed == 1) {
        progress[t.listId]!['completed'] = (progress[t.listId]!['completed'] ?? 0) + 1;
      }
    }

    // 🔥 Atualizar o provider de progresso
    ref.read(progressByListProvider.notifier).replaceAll(progress);
  }

  void _updateProgressForList(String listId) {
    final tasks = state.value ?? [];
    final listTasks = tasks.where((t) => t.listId == listId).toList();

    final total = listTasks.length;
    final completed = listTasks.where((t) => t.completed == 1).length;

    ref.read(progressByListProvider.notifier).updateList(listId, total, completed);
  }

  // Getter para UI externa (compatibilidade com código existente)
  Map<String, int> getProgressForList(String listId) {
    return ref.read(progressByListProvider.notifier).getForList(listId);
  }

  Future<void> addTask(TaskModel task) async {
    final dao = ref.read(taskDaoProvider);
    await dao.insert(task);

    // 🔥 CORRIGIDO: invalidateSelf não retorna Future
    ref.invalidateSelf();

    // Aguardar reload
    await future;
    _updateProgressForList(task.listId);
  }

  Future<void> updateTask(TaskModel task) async {
    final dao = ref.read(taskDaoProvider);
    await dao.updateTask(task);

    ref.invalidateSelf();

    await future;
    _updateProgressForList(task.listId);
  }

  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final dao = ref.read(taskDaoProvider);
      await dao.updateTaskStatus(taskId, isCompleted ? 1 : 0);

      final t = await dao.getTaskById(taskId);
      if (t != null) {
        // 🔥 Sync com ProjectAction
        if (t.linkedActionId != null) {
          final actDao = ref.read(projectActionsDaoProvider);
          await actDao.setActionCompletion(t.linkedActionId!, isCompleted);
        }

        ref.invalidateSelf();

        // Aguardar reload
        await future;
        _updateProgressForList(t.listId);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    final dao = ref.read(taskDaoProvider);
    final t = await dao.getTaskById(taskId);

    await dao.deleteTask(taskId);

    ref.invalidateSelf();

    // Aguardar reload
    if (t != null) {
      await future;
      _updateProgressForList(t.listId);
    }
  }

  Future<void> deleteSelected() async {
    final selected = ref.read(selectedTasksProvider);
    if (selected.isEmpty) return;

    final dao = ref.read(taskDaoProvider);
    final affectedLists = <String>{};

    for (final id in selected) {
      final t = await dao.getTaskById(id);
      if (t != null) {
        affectedLists.add(t.listId);
        await dao.deleteTask(id);
      }
    }

    ref.read(selectedTasksProvider.notifier).clear();
    ref.read(taskSelectionModeProvider.notifier).disable();

    ref.invalidateSelf();

    // Aguardar reload
    await future;
    for (final listId in affectedLists) {
      _updateProgressForList(listId);
    }
  }

  Future<void> recalculateProgress() async {
    final tasks = state.value ?? [];
    _rebuildProgressCache(tasks);
  }
}

final tasksProvider =
AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

final tasksByListProvider =
Provider.family<List<TaskModel>, String>((ref, listId) {
  final asyncTasks = ref.watch(tasksProvider);

  return asyncTasks.when(
    data: (tasks) => tasks.where((task) => task.listId == listId).toList(),
    loading: () => [],
    error: (e, s) => [],
  );
});

final progressForListProvider =
Provider.family<Map<String, int>, String>((ref, listId) {
  final allProgress = ref.watch(progressByListProvider);
  return allProgress[listId] ?? {'total': 0, 'completed': 0};
});