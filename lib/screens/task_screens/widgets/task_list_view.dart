import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'task_tile.dart';

class TaskListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<ListModel> lists;
  final int selectedButton;
  final void Function(int) onSelectButton;
  final void Function(TaskModel) onDelete;
  final void Function(TaskModel) onUpdate;
  final void Function(TaskModel, int) onToggleComplete;
  final Set<String> selectedTaskIds;
  final void Function(TaskModel)? onLongPressTask;
  final void Function(TaskModel, int) onTapTask;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.lists,
    required this.selectedButton,
    required this.onSelectButton,
    required this.selectedTaskIds,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onUpdate,
    this.onLongPressTask,
    required this.onTapTask,
  });

  @override
  Widget build(BuildContext context) {
    // Separar pendentes e concluídas
    final pendingTasks = tasks.where((t) => t.completed == 0).toList();
    final completedTasks = tasks.where((t) => t.completed == 1).toList();

    if (tasks.isEmpty) {
      return const Center(
        child: Text('Você não tem tarefas ainda.'),
      );
    }

    Widget buildTile(TaskModel task) {
      final isSelected = selectedTaskIds.contains(task.id);

      return TaskTile(
        key: ValueKey(task.id),
        task: task,
        isSelected: isSelected, // <-- NOVO
        onDelete: onDelete,
        onUpdate: onUpdate,
        onToggleFinal: (t, status) => onToggleComplete(t, status),
        onLongPress: () => onLongPressTask?.call(task),
        onTap: () => onTapTask(task, task.completed),
      );
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            '${pendingTasks.length} pendentes · ${completedTasks.length} concluídas',
            style: tNormal.copyWith(color: Colors.grey[700]),
          ),
        ),

        Expanded(
          child: ListView(
            children: [
              Text("Tarefas", style: tSmallTitle),
              const SizedBox(height: 8),

              if (pendingTasks.isNotEmpty)
                ...pendingTasks.map(buildTile)
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Nenhuma tarefa pendente.",
                    style: tNormal.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),

              const SizedBox(height: 24),

              if (completedTasks.isNotEmpty) ...[
                Text("Concluídas", style: tSmallTitle),
                const SizedBox(height: 8),
                ...completedTasks.map(buildTile),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
