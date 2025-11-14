import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/task_model.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final void Function(TaskModel) onDelete;
  final void Function(TaskModel) onUpdate;

  /// Chamado quando o utilizador marca como concluída / desmarca
  final void Function(TaskModel, int) onToggleFinal;

  final void Function()? onLongPress;
  final void Function()? onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onUpdate,
    required this.onToggleFinal,
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
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        onTap: onTap ??
                () {
              final newValue = isCompleted ? 0 : 1;
              onToggleFinal(task, newValue);
            },

        onLongPress: onLongPress,

        title: Text(
          task.description,
          style: tNormal.copyWith(
            decoration:
            isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),

        subtitle: _buildMeta(),

        trailing: Transform.scale(
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
        ),
      ),
    );
  }

  Widget _buildMeta() {
    final items = <Widget>[];

    // listType
    items.add(_meta(Icons.list, task.listType));

    // deadline
    final d = _formatDate(task.deadline);
    if (d != null) items.add(_meta(Icons.calendar_month, d));

    // time
    final t = _formatTime(task.time);
    if (t != null) items.add(_meta(Icons.access_time, t));

    // frequency
    if (task.frequency != null && task.frequency!.isNotEmpty) {
      items.add(_meta(Icons.repeat, task.frequency!.join(", ")));
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

  Widget _meta(IconData icon, String text) {
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
