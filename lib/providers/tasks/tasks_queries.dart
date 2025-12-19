import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/tasks/tasks_provider.dart';

final tasksByListProvider =
Provider.family<List<TaskModel>, String>((ref, listId) {
  final asyncTasks = ref.watch(tasksProvider);

  return asyncTasks.when(
    data: (tasks) {
      final listTasks = tasks.where((t) => t.listId == listId).toList();

      final pending = listTasks.where((t) => t.completed == 0).toList();
      final completed = listTasks.where((t) => t.completed == 1).toList();

      return [...pending, ...completed];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
