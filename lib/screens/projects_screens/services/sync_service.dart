import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/database/project_actions_dao.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/project_action_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/project_actions_provider.dart';
import 'package:kwanga/providers/tasks_provider.dart';

final syncCoordinatorProvider = Provider((ref) => SyncCoordinator(ref));

class SyncCoordinator {
  final Ref ref;
  bool _isLocked = false;

  SyncCoordinator(this.ref);

  bool get locked => _isLocked;

  void _lock() => _isLocked = true;
  void _unlock() => _isLocked = false;

  // ---------------------------------------------------------------------------
  // Action → Tasks
  // ---------------------------------------------------------------------------
  Future<void> applyActionUpdate(ProjectActionModel action) async {
    if (_isLocked) return;
    _lock();

    try {
      final taskDao = ref.read(taskDaoProvider);

      final linked = await taskDao.getTasksByLinkedActionId(action.id);

      for (final t in linked) {
        final updated = t.copyWith(
          description: action.description,
          completed: action.isDone ? 1 : 0,
        );
        await taskDao.updateTask(updated);
      }

      ref.invalidate(tasksProvider);

      // 🔥 CORRIGIDO: Aguardar reload e recalcular progresso
      await ref.read(tasksProvider.future);
      await ref.read(tasksProvider.notifier).recalculateProgress();

    } finally {
      _unlock();
    }
  }

  // ---------------------------------------------------------------------------
  // Task → Action
  // ---------------------------------------------------------------------------
  Future<void> applyTaskUpdate(TaskModel task) async {
    if (_isLocked) return;
    _lock();

    try {
      if (task.linkedActionId == null) return;

      final actionDao = ref.read(projectActionsDaoProvider);

      await actionDao.setActionCompletion(
        task.linkedActionId!,
        task.completed == 1,
      );

      ref.invalidate(projectActionsProvider);
    } finally {
      _unlock();
    }
  }
}