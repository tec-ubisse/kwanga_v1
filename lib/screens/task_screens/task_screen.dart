import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/providers/tasks/tasks_provider.dart';
import 'package:kwanga/screens/task_screens/widgets/task_list_view.dart';
import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';

import '../../widgets/feedback_widget.dart';
import 'new_task.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(tasksProvider);
    final asyncLists = ref.watch(listsProvider);
    final userId = ref.watch(authProvider).value?.id;

    final isSelectionMode = ref.watch(taskSelectionModeProvider);
    final selectedTaskIds = ref.watch(selectedTasksProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: isSelectionMode
            ? Text('${selectedTaskIds.length} selecionada(s)')
            : const Text('Tarefas'),
        actions: isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar selecionadas',
            onPressed: () async {
              final ids = selectedTaskIds.toList();

              await ref
                  .read(tasksProvider.notifier)
                  .deleteTasks(ids);

              ref.read(selectedTasksProvider.notifier).clear();
              ref
                  .read(taskSelectionModeProvider.notifier)
                  .disable();

              showFeedbackScaffoldMessenger(
                context,
                '${ids.length} tarefa(s) eliminada(s)',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Cancelar seleção',
            onPressed: () {
              ref
                  .read(taskSelectionModeProvider.notifier)
                  .disable();
              ref
                  .read(selectedTasksProvider.notifier)
                  .clear();
            },
          ),
        ]
            : [],
      ),
      backgroundColor: Colors.white,
      drawer: isSelectionMode ? null : const CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: asyncTasks.when(
          data: (tasks) => asyncLists.when(
            data: (lists) {
              if (userId == null) {
                return const Center(
                  child: Text('Utilizador não encontrado.'),
                );
              }

              // Apenas listas de ações (não projectos)
              final actionLists = lists
                  .where(
                    (l) => l.listType == 'action' && l.isProject == false,
              )
                  .toList();

              final allowedListIds =
              actionLists.map((l) => l.id).toSet();

              // Apenas tarefas de ação
              final tasksFiltered = tasks
                  .where((t) => allowedListIds.contains(t.listId))
                  .toList();

              if (tasksFiltered.isEmpty) {
                return const Center(
                  child: Text('Nenhuma tarefa de ação encontrada.'),
                );
              }

              return TaskListView(
                tasks: tasksFiltered,
                lists: lists,
                selectedTaskIds: selectedTaskIds,

                onDelete: (task) =>
                    ref.read(tasksProvider.notifier).deleteTask(task.id),

                onToggleComplete: (task, newValue) =>
                    ref.read(tasksProvider.notifier).updateTaskStatus(
                      task.id,
                      newValue == 1,
                    ),

                onUpdate: (task) async {
                  final list = lists.firstWhere(
                        (l) => l.id == task.listId,
                    orElse: () => ListModel(
                      id: '',
                      userId: userId,
                      description: 'Lista desconhecida',
                      listType: '',
                      isProject: false,
                    ),
                  );

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewTaskScreen(
                        listModel: list,
                        taskModel: task,
                      ),
                    ),
                  );
                },

                onLongPressTask: (task) {
                  final sel =
                  ref.read(selectedTasksProvider.notifier);
                  final mode =
                  ref.read(taskSelectionModeProvider.notifier);

                  if (!isSelectionMode) mode.enable();
                  sel.toggle(task.id);
                },
              );
            },
            loading: () =>
            const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text('Erro a carregar listas: $err'),
            ),
          ),
          loading: () =>
          const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('Erro a carregar tarefas: $err'),
          ),
        ),
      ),
    );
  }
}
