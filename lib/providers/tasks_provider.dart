import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/auth_provider.dart';

final taskFilterProvider =
NotifierProvider<TaskFilterNotifier, int>(TaskFilterNotifier.new);

class TaskFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setFilter(int index) => state = index;
}

final taskSelectionModeProvider =
NotifierProvider<TaskSelectionModeNotifier, bool>(TaskSelectionModeNotifier.new);

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

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() async {
    final user = ref.watch(authProvider).value;
    if (user?.id == null) return [];
    return ref.read(taskDaoProvider).getTaskByUserId(user!.id!);
  }

  Future<void> addTask(TaskModel task) async {
    await ref.read(taskDaoProvider).insert(task);
    ref.invalidateSelf();
  }

  Future<void> updateTask(TaskModel task) async {
    await ref.read(taskDaoProvider).updateTask(task);
    ref.invalidateSelf();
  }

  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    await ref
        .read(taskDaoProvider)
        .updateTaskStatus(taskId, isCompleted ? 1 : 0);
    ref.invalidateSelf();
  }

  Future<void> deleteTask(String taskId) async {
    await ref.read(taskDaoProvider).deleteTask(taskId);
    ref.invalidateSelf();
  }

  Future<void> deleteSelected() async {
    final selectedIds = ref.read(selectedTasksProvider);
    if (selectedIds.isEmpty) return;

    final dao = ref.read(taskDaoProvider);
    await Future.wait(selectedIds.map((id) => dao.deleteTask(id)));

    ref.read(selectedTasksProvider.notifier).clear();
    ref.read(taskSelectionModeProvider.notifier).disable();
    ref.invalidateSelf();
  }
}

final tasksProvider =
AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

final tasksByListProvider =
Provider.family<List<TaskModel>, String>((ref, listId) {
  final asyncTasks = ref.watch(tasksProvider);
  return asyncTasks.when(
    data: (tasks) =>
        tasks.where((task) => task.listId == listId).toList(),
    loading: () => [],
    error: (e, s) => [],
  );
});

final taskProgressProvider =
Provider.family<Map<String, int>, String>((ref, listId) {
  final asyncTasks = ref.watch(tasksProvider);
  return asyncTasks.when(
    data: (tasks) {
      final tasksForList =
      tasks.where((task) => task.listId == listId).toList();
      return {
        'total': tasksForList.length,
        'completed': tasksForList.where((t) => t.completed == 1).length,
      };
    },
    loading: () => {'total': 0, 'completed': 0},
    error: (e, s) => {'total': 0, 'completed': 0},
  );
});
