import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/tasks/tasks_provider.dart';
import 'package:kwanga/screens/task_screens/create_task_screen.dart';
import 'package:kwanga/screens/task_screens/widgets/task_list_view.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import 'package:kwanga/widgets/dialogs/kwanga_delete_dialog.dart';

import '../../providers/lists_provider.dart';
import '../projects_screens/dialogs/select_list_dialog.dart';

class ListTasksScreen extends ConsumerWidget {
  final ListModel listModel;

  const ListTasksScreen({super.key, required this.listModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEntryList = listModel.listType == 'entry';

    final message = isEntryList
        ? 'Nenhum item de entrada nesta lista.'
        : 'Nenhuma tarefa nesta lista.';

    final itemLabel = isEntryList ? 'entrada' : 'tarefa';

    final tasks = ref.watch(tasksByListProvider(listModel.id));

    Future<void> deleteTask(TaskModel task) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => KwangaDeleteDialog(
          title: 'Eliminar $itemLabel',
          message:
          'Tem certeza que deseja eliminar a $itemLabel "${task.description}"? Esta ação é irreversível.',
        ),
      );

      if (confirm == true) {
        await ref.read(tasksProvider.notifier).deleteTask(task.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Eliminado com sucesso.'),
                Image.asset('assets/gifs/delete.gif', width: 40),
              ],
            ),
          ),
        );
      }
    }

    final total = tasks.length;
    final completed = tasks.where((t) => t.completed == 1).length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, {
            'completed': completed,
            'total': total,
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: cMainColor,
          foregroundColor: cWhiteColor,
          title: Text(listModel.description),
        ),
        bottomNavigationBar: BottomActionBar(
          buttonText: 'Adicionar Tarefa',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateTaskScreen(listModel: listModel),
              ),
            );

            if (result is TaskModel) {
              ref.invalidate(tasksProvider);
            }
          },
        ),
        body: Padding(
          padding: defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEntryList && total > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '$completed / $total tarefas',
                    style: tNormal.copyWith(color: Colors.grey[700]),
                  ),
                ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                  child: Text(
                    message,
                    style: tNormal.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
                    : TaskListView(
                  tasks: tasks,
                  lists: const [],
                  selectedTaskIds: const {},

                  onDelete: deleteTask,

                  // 🔹 Só permite mover se for lista de entradas
                  onMove: isEntryList
                      ? (task) async {
                    final actionLists = await ref
                        .read(listsProvider.future)
                        .then((lists) => lists
                        .where((l) =>
                    l.listType == 'action' &&
                        l.isProject == false)
                        .toList());

                    final listId =
                    await showDialog<String>(
                      context: context,
                      builder: (_) =>
                          SelectListDialog(lists: actionLists),
                    );

                    if (listId == null) return;

                    await ref
                        .read(tasksProvider.notifier)
                        .moveTaskToList(
                      taskId: task.id,
                      targetListId: listId,
                    );
                  }
                      : null,

                  onUpdate: (taskToEdit) async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateTaskScreen(
                          listModel: listModel,
                          taskModel: taskToEdit,
                        ),
                      ),
                    );

                    if (updated is TaskModel) {
                      ref.invalidate(tasksProvider);
                    }
                  },

                  onToggleComplete: (t, status) {
                    ref
                        .read(tasksProvider.notifier)
                        .updateTaskStatus(
                      t.id,
                      status == 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
