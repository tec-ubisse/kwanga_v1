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
  final void Function(TaskModel)? onMove;

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

    return CardContainer(
      padding: const EdgeInsets.only(left: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12)),
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
                  onPressed: (_) => onMove!(task),
                ),
              SlidableAction(
                backgroundColor: cSecondaryColor,
                icon: Icons.edit,
                label: "Editar",
                onPressed: (_) => onUpdate(task),
              ),
              SlidableAction(
                backgroundColor: cTertiaryColor,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: "Eliminar",
                onPressed: (_) => onDelete(task),
              ),
            ],
          ),

          /// 🔥 SUBSTITUIÇÃO DO ListTile
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.white,),
            padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Conteúdo principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.description,
                        style: tNormal.copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _TaskMetaRow(task: task),
                    ],
                  ),
                ),

                /// Trailing
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child:
                    Icon(Icons.check, color: cWhiteColor),
                  )
                else if (isAction)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Transform.scale(
                      scale: 1.4,
                      child: Checkbox(
                        value: isCompleted,
                        activeColor: cSecondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        side: const BorderSide(color: cBlackColor),
                        onChanged: (_) => onToggleFinal(
                          task,
                          isCompleted ? 0 : 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _TaskMetaRow extends StatelessWidget {
  final TaskModel task;

  const _TaskMetaRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    items.add(
      _MetaItem(
        icon: Icons.calendar_month,
        text: DateFormat('dd/MM/yyyy').format(task.createdAt),
      ),
    );

    if (task.deadline != null) {
      items.add(
        _MetaItem(
          icon: Icons.calendar_today_rounded,
          text: DateFormat('dd/MM').format(task.deadline!),
        ),
      );
    }

    if (task.time != null) {
      items.add(
        _MetaItem(
          icon: Icons.alarm,
          text: DateFormat('HH:mm').format(task.time!),
        ),
      );
    }

    if (task.frequency != null && task.frequency!.isNotEmpty) {
      items.add(
        _MetaItem(
          icon: Icons.repeat,
          text: _formatFrequency(task.frequency!),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: items,
      ),
    );
  }

  String _formatFrequency(List<String> days) {
    const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return days
        .map((d) => int.tryParse(d))
        .where((d) => d != null && d! >= 0 && d < 7)
        .map((d) => labels[d!])
        .join(' • ');
  }
}


class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: tSmall.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
