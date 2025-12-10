import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/project_action_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/tasks_provider.dart';
import 'package:kwanga/providers/project_actions_provider.dart';
import 'package:kwanga/data/database/project_actions_dao.dart';
import 'package:kwanga/data/database/task_dao.dart';

class SyncService {
  /// Quando uma Action muda, actualiza *todas* as Tasks ligadas.
  /// Usa Ref para poder invalidar / ler providers.
  static Future<void> syncActionToTasks(Ref ref, ProjectActionModel action) async {
    final taskDao = ref.read(taskDaoProvider);
    final linkedTasks = await taskDao.getTasksByLinkedActionId(action.id);

    // Atualiza tarefas ligadas (só campos sincronizados: description + completed)
    for (final t in linkedTasks) {
      final updated = t.copyWith(
        description: action.description,
        completed: action.isDone ? 1 : 0,
      );
      await taskDao.updateTask(updated);
    }

    // Recarrega tasksProvider (ele próprio recalcula progress)
    ref.invalidate(tasksProvider);
  }

  /// Quando uma Task muda, actualiza a Action correspondente (se existir)
  static Future<void> syncTaskToAction(Ref ref, TaskModel task) async {
    if (task.linkedActionId == null) return;

    final actionDao = ref.read(projectActionsDaoProvider);
    await actionDao.setActionCompletion(
      task.linkedActionId!,
      task.completed == 1,
    );

    // força refresh das actions visíveis
    ref.invalidate(projectActionsProvider);
  }
}
