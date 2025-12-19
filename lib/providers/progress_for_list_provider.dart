import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/providers/tasks/tasks_provider.dart';

final progressForListProvider =
Provider.family<Map<String, int>, String>((ref, listId) {
  final asyncTasks = ref.watch(tasksProvider);
  return asyncTasks.when(
    data: (tasks) {
      final listTasks = tasks.where((t) => t.listId == listId).toList();
      final total = listTasks.length;
      final completed = listTasks.where((t) => t.completed == 1).length;
      return {'total': total, 'completed': completed};
    },
    loading: () => {'total': 0, 'completed': 0},
    error: (_, __) => {'total': 0, 'completed': 0},
  );
});
