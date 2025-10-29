import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/screens/task_screens/update_task_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final void Function(TaskModel) onTap;
  final void Function(TaskModel) onDelete;
  final void Function(TaskModel, int) onToggleComplete;
  final void Function() onLongPress;

  const TaskTile({
    super.key,
    required this.onTap,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onLongPress
  });

  String displayDate(DateTime userDate) {
    final now = DateTime.now();
    if (userDate.year == now.year &&
        userDate.month == now.month &&
        userDate.day == now.day) {
      return 'Hoje';
    } else {
      return 'Amanhã';
    }
  }

  String formatTime(BuildContext context, DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        onTap(task);
      },
      onLongPress: (){
        onLongPress();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Slidable(
            key: ValueKey(task.id),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
            SlidableAction(
              backgroundColor: cSecondaryColor,
              onPressed: (_) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => UpdateTaskScreen(task: task),
                ),
              ),
              icon: Icons.edit,
            ),
                SlidableAction(
                  backgroundColor: cTertiaryColor,
                  onPressed: (_) => onDelete(task),
                  icon: Icons.delete,
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(color: Color(0xffEAEFF4)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.description,
                        style: tNormal.copyWith(
                          decoration: task.completed == 1
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.completed == 1 ? Colors.grey : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        spacing: 8.0,
                        children: [
                          Icon(Icons.list, color: cSecondaryColor, size: 16.0),
                          Text(task.listType,
                              style: tNormal.copyWith(fontSize: 10)),
                          if (task.deadline != null) ...[
                            Icon(Icons.calendar_month,
                                color: cSecondaryColor, size: 16.0),
                            Text(displayDate(task.deadline!),
                                style: tNormal.copyWith(fontSize: 10)),
                          ],
                          if (task.time != null) ...[
                            Icon(Icons.access_time,
                                color: cSecondaryColor, size: 12.0),
                            Text(formatTime(context, task.time!),
                                style: tNormal.copyWith(fontSize: 10)),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: task.completed == 1,
                      activeColor: cSecondaryColor,
                      side: BorderSide(color: cBlackColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      onChanged: (value) {
                        final newValue = value == true ? 1 : 0;
                        onToggleComplete(task, newValue);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
