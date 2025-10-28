import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
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
  final void Function(TaskModel, int) onToggleComplete;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.lists,
    required this.selectedButton,
    required this.onSelectButton,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final selectedList =
    selectedButton == 0 ? null : lists[selectedButton - 1];

    // 🔹 Filtering by type of list
    final filteredTasks = selectedList == null
        ? tasks
        : tasks.where((t) => t.listType == selectedList.description).toList();

    // Separating completed / incomplete
    final pendingTasks = filteredTasks.where((t) => t.completed == 0).toList();
    final completedTasks = filteredTasks.where((t) => t.completed == 1).toList();

    if (tasks.isEmpty) {
      return const Center(
        child: Text('Você não tem tarefas ainda.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lists - to work as filters
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lists.length + 1,
            itemBuilder: (context, index) {
              final isSelected = selectedButton == index;
              final color = isSelected ? cSecondaryColor : null;
              final textColor = isSelected ? cWhiteColor : cBlackColor;
              final label =
              index == 0 ? 'Todas' : lists[index - 1].description;

              return GestureDetector(
                onTap: () => onSelectButton(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Text(label, style: tNormal.copyWith(color: textColor)),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ListView(
            children: [
              // Pending Tasks
              if (pendingTasks.isNotEmpty) ...[
                Text('Tarefas', style: tSmallTitle),
                const SizedBox(height: 8),
                ...pendingTasks.map(
                      (task) => TaskTile(
                    task: task,
                    onDelete: onDelete,
                    onToggleComplete: onToggleComplete,
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhuma tarefa pendente.',
                    style: tNormal.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),

              const SizedBox(height: 16),

              // Concluded
              if (completedTasks.isNotEmpty) ...[
                Text('Concluídas', style: tSmallTitle),
                const SizedBox(height: 8),
                ...completedTasks.map(
                      (task) => TaskTile(
                    task: task,
                    onDelete: onDelete,
                    onToggleComplete: onToggleComplete,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
