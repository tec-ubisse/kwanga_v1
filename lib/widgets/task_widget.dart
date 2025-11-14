import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/screens/task_screens/task_screen.dart';

import '../custom_themes/blue_accent_theme.dart';
import '../custom_themes/text_style.dart';
import '../data/database/task_dao.dart';

class TaskWidget extends StatefulWidget {
  final TaskModel task;
  final void Function() onTap;
  const TaskWidget({super.key, required this.task, required this.onTap});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  final TaskDao _taskDao = TaskDao();

  void deleteTask(TaskModel _currentTask) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Eliminar Tarefa',
          style: tTitle.copyWith(color: cTertiaryColor),
        ),
        content: Text(
          'Tem certeza que deseja eliminar a tarefa ${_currentTask.description}?',
          style: tNormal,
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () {
              widget.onTap;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => TaskScreen()),
              );
            },
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.onTap;
      // loadTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa eliminada com sucesso.')),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              backgroundColor: cTertiaryColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              onPressed: (_) {
                deleteTask(widget.task);
                widget.onTap;
              },
              icon: Icons.delete,
            ),
          ],
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffEAEFF4),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              spacing: 16.0,
              children: [
                CircleAvatar(
                  radius: 10.0,
                  backgroundColor: cMainColor,
                  foregroundColor: cSecondaryColor,
                ),
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.description,
                      style: tNormal.copyWith(fontSize: 20.0),
                    ),
                    Row(
                      spacing: 40.0,
                      children: [
                        Row(
                          spacing: 4.0,
                          children: [
                            Icon(
                              Icons.list,
                              color: cSecondaryColor,
                              size: 16.0,
                            ),
                            Text(
                              widget.task.listType,
                              style: tNormal,
                            ),
                          ],
                        ),
                        if (widget.task.deadline != null)
                          Row(
                            spacing: 4.0,
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: cSecondaryColor,
                                size: 16.0,
                              ),
                              Text(
                                displayDate(widget.task.deadline!),
                                style: tNormal,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
