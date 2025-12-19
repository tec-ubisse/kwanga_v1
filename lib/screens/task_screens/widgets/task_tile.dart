import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/widgets/cards/card_container.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final bool isSelected;

  final void Function(TaskModel) onDelete;
  final void Function(TaskModel) onUpdate;
  final void Function(TaskModel, int) onToggleFinal;
  final void Function(TaskModel)? onMove; // 👈 NOVO

  final VoidCallback? onLongPress;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onUpdate,
    required this.onToggleFinal,
    this.onMove,
    required this.isSelected,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.completed == 1;
    final isAction = task.listType == 'action';
    final createdDate = DateFormat('dd/MM/yyyy').format(task.createdAt);

    return CardContainer(
      padding: const EdgeInsets.only(left: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Slidable(
          key: ValueKey(task.id),

          endActionPane: ActionPane(
            extentRatio: 0.64,
            motion: const StretchMotion(),
            children: [
              if (!isAction && onMove != null)
                SlidableAction(
                  backgroundColor: const Color(0xff2c82b5),
                  foregroundColor: Colors.white,
                  icon: Icons.playlist_add,
                  label: "Mover",
                  onPressed: (ctx) {
                    Slidable.of(ctx)?.close();
                    onMove!(task);
                  },
                ),

              SlidableAction(
                backgroundColor: cSecondaryColor,
                onPressed: (_) {
                  Slidable.of(context)?.close();
                  onUpdate(task);
                },
                icon: Icons.edit,
                label: "Editar",
              ),
              SlidableAction(
                backgroundColor: cTertiaryColor,
                foregroundColor: Colors.white,
                onPressed: (_) {
                  Slidable.of(context)?.close();
                  onDelete(task);
                },
                icon: Icons.delete,
                label: "Eliminar",
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            onLongPress: onLongPress,
            title: Text(
              task.description,
              style: tNormal.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.calendar_month,
                    color: Colors.grey, size: 12),
                const SizedBox(width: 4),
                Text(createdDate, style: tSmall.copyWith(color: Colors.grey)),
              ],
            ),
            trailing: isSelected
                ? const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.check, color: cWhiteColor),
            )
                : isAction
                ? Transform.scale(
              scale: 1.4,
              child: Checkbox(
                value: isCompleted,
                activeColor: cSecondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                side: const BorderSide(color: cBlackColor),
                onChanged: (_) =>
                    onToggleFinal(task, isCompleted ? 0 : 1),
              ),
            )
                : null,
          ),
        ),
      ),
    );
  }
}

