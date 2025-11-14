import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/database/task_dao.dart';

final taskProgressProvider = FutureProvider.family<Map<String, int>, String>((
  ref,
  listId,
) async {
  final dao = TaskDao();
  final progress = await dao.getTaskProgress(listId);
  return {
    'completed': progress['completed'] ?? 0,
    'total': progress['total'] ?? 0,
  };
});
