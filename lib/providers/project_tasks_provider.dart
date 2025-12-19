import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/tasks/tasks_provider.dart';

final projectTasksProvider =
Provider.family<List<TaskModel>, String>((ref, projectId) {
  final asyncTasks = ref.watch(tasksProvider);

  return asyncTasks.when(
    data: (tasks) => tasks.where((t) => t.projectId == projectId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
