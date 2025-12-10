import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/database/project_actions_dao.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/project_action_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/project_actions_provider.dart';
import 'package:kwanga/providers/tasks_provider.dart';
import 'package:kwanga/providers/progress_provider.dart';

final syncCoordinatorProvider = Provider((ref) => SyncCoordinator(ref));

class SyncCoordinator {
  final Ref ref;
  bool _lock = false; // evita ciclos Action→Task→Action

  SyncCoordinator(this.ref);

  bool get isLocked => _lock;

  void _startLock() => _lock = true;
  void _stopLock() => _lock = false;

  // -------------------------------------------------------------
  // Quando Action muda → Atualiza Tasks ligadas
  // -------------------------------------------------------------
  Future<void> applyActionUpdate(ProjectActionModel action) async {
    if (_lock) return;
    _startLock();

    try {
      final taskDao = ref.read(taskDaoProvider);
      final tasks = await taskDao.getTasksByLinkedActionId(action.id);

      for (final t in tasks) {
        final updatedTask = t.copyWith(
          description: action.description,
          completed: action.isDone ? 1 : 0,
        );

        await taskDao.updateTask(updatedTask);
      }

      // Refresca TasksNotifier
      ref.invalidate(tasksProvider);
    } finally {
      _stopLock();
    }
  }

  // -------------------------------------------------------------
  // Quando Task muda → Atualiza Action correspondente
  // -------------------------------------------------------------
  Future<void> applyTaskUpdate(TaskModel task) async {
    if (_lock) return;
    _startLock();

    try {
      if (task.linkedActionId == null) return;

      final actionDao = ref.read(projectActionsDaoProvider);

      await actionDao.setActionCompletion(
        task.linkedActionId!,
        task.completed == 1,
      );

      // Atualiza lista de actions na UI
      ref.invalidate(projectActionsProvider);
    } finally {
      _stopLock();
    }
  }
}
