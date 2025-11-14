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

  final void Function(TaskModel)? onLongPressTask;
  final void Function(TaskModel, int) onTapTask;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.lists,
    required this.selectedButton,
    required this.onSelectButton,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onUpdate,
    this.onLongPressTask,
    required this.onTapTask,
  });

  @override
  Widget build(BuildContext context) {
    // <-- FILTROS REMOVIDOS: mostramos todas as tarefas recebidas em `tasks`.

    // Separar pendentes e concluídas a partir da lista completa
    final pendingTasks = tasks.where((t) => t.completed == 0).toList();
    final completedTasks = tasks.where((t) => t.completed == 1).toList();

    // Mensagem quando não há tasks
    if (tasks.isEmpty) {
      return const Center(
        child: Text('Você não tem tarefas ainda.'),
      );
    }

    Widget buildTile(TaskModel task) {
      return TaskTile(
        key: ValueKey(task.id),
        task: task,

        onDelete: onDelete,
        onUpdate: onUpdate,

        // Chamado APENAS após animações (TaskTile controla tudo)
        onToggleFinal: (t, status) {
          onToggleComplete(t, status);
        },

        onLongPress: () => onLongPressTask?.call(task),

        onTap: () => onTapTask(task, 0),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Indicador simples de totais para toda a lista
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
              // -----------------------------
              // TAREFAS PENDENTES (todas)
              // -----------------------------
              Text("Tarefas", style: tSmallTitle),
              const SizedBox(height: 8),

              if (pendingTasks.isNotEmpty)
                ...pendingTasks.map(buildTile).toList()
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Nenhuma tarefa pendente.",
                    style: tNormal.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // -----------------------------
              // TAREFAS CONCLUÍDAS (todas)
              // -----------------------------
              if (completedTasks.isNotEmpty) ...[
                Text("Concluídas", style: tSmallTitle),
                const SizedBox(height: 8),
                ...completedTasks.map(buildTile).toList(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
