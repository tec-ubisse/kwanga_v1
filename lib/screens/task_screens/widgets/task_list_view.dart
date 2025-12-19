import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'task_tile.dart';

class TaskListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<ListModel> lists;

  // 🔹 Opcionais (nem todos os ecrãs usam)
  final int? selectedButton;
  final void Function(int)? onSelectButton;
  final void Function(TaskModel)? onMove;

  // 🔹 Essenciais
  final void Function(TaskModel) onDelete;
  final void Function(TaskModel) onUpdate;
  final void Function(TaskModel, int) onToggleComplete;
  final Set<String> selectedTaskIds;
  final void Function(TaskModel)? onLongPressTask;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.lists,
    this.selectedButton,
    this.onSelectButton,
    this.onMove,
    required this.selectedTaskIds,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onUpdate,
    this.onLongPressTask,
  });

  @override
  Widget build(BuildContext context) {
    final pendingTasks = tasks.where((t) => t.completed == 0).toList();
    final completedTasks = tasks.where((t) => t.completed == 1).toList();

    if (tasks.isEmpty) {
      return const Center(
        child: Text('Você não tem tarefas ainda.'),
      );
    }

    Widget buildTile(TaskModel task) {
      final isSelected = selectedTaskIds.contains(task.id);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TaskTile(
          key: ValueKey(task.id),
          task: task,
          isSelected: isSelected,
          onDelete: onDelete,
          onUpdate: onUpdate,
          onMove: onMove, // 👈 pode ser null (TaskTile já trata)
          onToggleFinal: (t, status) => onToggleComplete(t, status),
          onLongPress: () => onLongPressTask?.call(task),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        // ---------- PENDENTES ----------
        if (pendingTasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              pendingTasks.length == 1
                  ? '${pendingTasks.length} • Pendente'
                  : '${pendingTasks.length} • Pendentes',
              style: tSmallTitle.copyWith(color: Colors.grey),
            ),
          ),

        if (pendingTasks.isNotEmpty)
          ...pendingTasks.map(buildTile)
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Nenhuma tarefa pendente.',
              style: tNormal.copyWith(fontStyle: FontStyle.italic),
            ),
          ),

        if (pendingTasks.isNotEmpty && completedTasks.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),

        // ---------- CONCLUÍDAS ----------
        if (completedTasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              completedTasks.length == 1
                  ? '${completedTasks.length} • Concluída'
                  : '${completedTasks.length} • Concluídas',
              style: tSmallTitle.copyWith(color: Colors.grey),
            ),
          ),

        if (completedTasks.isNotEmpty)
          ...completedTasks.map(buildTile)
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Nenhuma tarefa concluída.',
              style: tNormal.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}
