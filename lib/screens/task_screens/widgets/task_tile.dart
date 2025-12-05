import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/task_model.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final bool isSelected;

  final void Function(TaskModel) onDelete;
  final void Function(TaskModel) onUpdate;
  final void Function(TaskModel, int) onToggleFinal;

  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onUpdate,
    required this.onToggleFinal,
    required this.isSelected,
    this.onLongPress,
    this.onTap,
  });

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.day}/${date.month}/${date.year}";
  }

  String? _formatTime(DateTime? time) {
    if (time == null) return null;
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.completed == 1;
    final isAction = task.listType == 'action';

    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            backgroundColor: cSecondaryColor,
            onPressed: (_) => onUpdate(task),
            icon: Icons.edit,
          ),
          SlidableAction(
            backgroundColor: cTertiaryColor,
            onPressed: (_) => onDelete(task),
            icon: Icons.delete,
          ),
        ],
      ),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,

        decoration: BoxDecoration(
          color: isSelected
              ? cSecondaryColor.withOpacity(0.20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          children: [
            ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

              onTap: () {
                if (onTap != null) onTap!();
              },

              onLongPress: onLongPress,

              title: Text(
                task.description,
                style: tNormal.copyWith(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : Colors.black,
                ),
              ),

              subtitle: isAction ? _buildTaskInfo() : null,

              trailing: isSelected
                  ? const Icon(Icons.check, color: cWhiteColor)
                  : (isAction
                  ? Transform.scale(
                scale: 1.4,
                child: Checkbox(
                  value: isCompleted,
                  activeColor: cSecondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  side: const BorderSide(color: cBlackColor),
                  onChanged: (_) {
                    final newValue = isCompleted ? 0 : 1;
                    onToggleFinal(task, newValue);
                  },
                ),
              )
                  : null),
            ),

            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfo() {
    final items = <Widget>[];

    items.add(_taskInfo(Icons.list, task.listType));

    final d = _formatDate(task.deadline);
    if (d != null) items.add(_taskInfo(Icons.calendar_month, d));

    final t = _formatTime(task.time);
    if (t != null) items.add(_taskInfo(Icons.access_time, t));

    if (task.frequency != null && task.frequency!.isNotEmpty) {
      items.add(_taskInfo(Icons.repeat, task.frequency!.join(", ")));
    }

    return items.isEmpty
        ? const SizedBox.shrink()
        : Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: items,
      ),
    );
  }

  Widget _taskInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: tSmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
