import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/tasks_provider.dart';
import 'package:kwanga/screens/task_screens/create_task_screen.dart';
import 'package:kwanga/screens/task_screens/widgets/task_tile.dart';

class ListTasksScreen extends ConsumerWidget {
  final ListModel listModel;

  const ListTasksScreen({super.key, required this.listModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksByListProvider(listModel.id));

    Future<void> deleteTask(TaskModel task) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Eliminar Tarefa',
            style: tTitle.copyWith(color: cTertiaryColor),
          ),
          content: Text(
            'Tem certeza que deseja eliminar a tarefa "${task.description}"?',
            style: tNormal,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await ref.read(tasksProvider.notifier).deleteTask(task.id);
      }
    }

    final total = tasks.length;
    final completed = tasks.where((t) => t.completed == 1).length;

    return PopScope(
      canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            final total = tasks.length;
            final completed = tasks.where((t) => t.completed == 1).length;

            Navigator.pop(context, {
              'completed': completed,
              'total': total,
            });
          }
        },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: cMainColor,
          foregroundColor: cWhiteColor,
          title: Text(listModel.description),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: cSecondaryColor,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateTaskScreen(listModel: listModel),
            ),
          ),
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (total > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '$completed / $total tarefas concluídas',
                    style: tNormal.copyWith(color: Colors.grey[700]),
                  ),
                ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                  child: Text(
                    'Nenhuma tarefa nesta lista.',
                    style: tNormal.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskTile(
                      key: ValueKey(task.id),
                      task: task,
                      onDelete: deleteTask,
                      onUpdate: (updatedTask) => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => CreateTaskScreen(
                            listModel: listModel,
                            taskModel: updatedTask,
                          ),
                        ),
                      ),
                      onLongPress: () {
                        // multiple-selection logic
                      },

                      onToggleFinal: (t, status) {
                        ref.read(tasksProvider.notifier).updateTaskStatus(t.id, status == 1);
                      },
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
