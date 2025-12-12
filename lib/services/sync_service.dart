import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/task_model.dart';

class SyncService {
  static Future<List<TaskModel>> syncLinkedCopies(
      TaskModel task,
      TaskDao dao,
      ) async {
    if (task.linkedActionId == null) return [];

    final linked = await dao.getTasksByLinkedActionId(task.linkedActionId!);

    if (linked.isEmpty) return [];

    for (final t in linked) {
      if (t.id == task.id) continue;

      final updated = t.copyWith(
        description: task.description,
        completed: task.completed,
        deadline: task.deadline,
        time: task.time,
        frequency: task.frequency == null
            ? null
            : List<String>.from(task.frequency!),
      );

      await dao.updateTask(updated);
    }

    return await dao.getTasksByLinkedActionId(task.linkedActionId!);
  }
}
