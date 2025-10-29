import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/screens/lists_screens/create_lists_screen.dart';
import 'package:kwanga/widgets/buttons/floating_button.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import 'package:kwanga/widgets/custom_drawer.dart';
import 'package:kwanga/models/user.dart';
import 'create_task_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskDao _taskDao = TaskDao();
  final ListDao _listDao = ListDao();
  int selectedButton = 0;
  String? shownDate = '';
  late Future<List<TaskModel>> _tasksFuture;
  late Future<List<ListModel>> _listsFuture;
  bool initialTaskState = false;

  UserModel? currentUser = UserModel(
    id: 2025,
    email: 'alberto.ubisse@gmail.com',
    password: 'tech@123',
  );

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

  void loadTasks() {
    setState(() {
      _tasksFuture = _taskDao.getTaskByUserId(currentUser!.id!);
      _listsFuture = _listDao.getAll();
    });
  }

  void selectButton(int buttonIndex) {
    setState(() {
      selectedButton = buttonIndex;
    });
  }

  Future<void> deleteTask(TaskModel currentTask) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Eliminar Tarefa',
          style: tTitle.copyWith(color: cTertiaryColor),
        ),
        content: Text(
          'Tem certeza que deseja eliminar a tarefa "${currentTask.description}"?',
          style: tNormal,
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _taskDao.deleteTask(currentTask.id);
      loadTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa eliminada com sucesso.')),
      );
    }
  }

  Future<void> updateTaskStatus(String taskId, int statusValue) async {
    await _taskDao.updateTaskStatus(taskId, statusValue);
  }

  String formatTime(DateTime time) {
    final timeOfDay = TimeOfDay.fromDateTime(time);
    return timeOfDay.format(context);
  }

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      loadTasks();
    } else {
      debugPrint('Nenhum usuário logado');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget emptyData = Padding(
      padding: defaultPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Você não tem tarefas ainda', style: tSmallTitle),
          Text(
            'Crie uma lista para adicionar tarefas',
            style: tNormal.copyWith(fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: const Text('Meu Dia'),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 20,
              child: FutureBuilder<List<TaskModel>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return emptyData;
                  }

                  final tasks = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔘 Filtros (Listas)
                      Expanded(
                        child: FutureBuilder<List<ListModel>>(
                          future: _listsFuture,
                          builder: (context, listSnapshot) {
                            if (listSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (listSnapshot.hasError) {
                              return Center(
                                child: Text('Erro: ${listSnapshot.error}'),
                              );
                            }

                            final lists = listSnapshot.data ?? [];

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: lists.length + 1,
                              itemBuilder: (context, index) {
                                final isSelected = selectedButton == index;
                                final color = isSelected
                                    ? cSecondaryColor
                                    : null;
                                final textColor = isSelected
                                    ? cWhiteColor
                                    : cBlackColor;

                                final label = index == 0
                                    ? 'Todas'
                                    : lists[index - 1].description;

                                return GestureDetector(
                                  onTap: () => selectButton(index),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      label,
                                      style: tNormal.copyWith(color: textColor),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      Expanded(
                        flex: 19,
                        child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  initialTaskState = !initialTaskState;
                                });
                                final newStatus = initialTaskState == true ? 1 : 0;
                                updateTaskStatus(task.id, newStatus);
                                setState(() {
                                  task.completed = newStatus;
                                });
                              },
                              child: Padding(
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
                                        onPressed: (_) => deleteTask(task),
                                        icon: Icons.delete,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xffEAEFF4),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10.0,
                                          backgroundColor: cSecondaryColor,
                                          child: initialTaskState
                                              ? null
                                              : CircleAvatar(
                                            radius: 8.0,
                                            backgroundColor: const Color(
                                              0xffEAEFF4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.description,
                                                style: tNormal.copyWith(
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.list,
                                                    color: cSecondaryColor,
                                                    size: 16.0,
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  Text(
                                                    task.listType,
                                                    style: tNormal.copyWith(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  if (task.deadline !=
                                                      null) ...[
                                                    const SizedBox(width: 32.0),
                                                    Icon(
                                                      Icons.calendar_month,
                                                      color: cSecondaryColor,
                                                      size: 16.0,
                                                    ),
                                                    const SizedBox(width: 4.0),
                                                    Text(
                                                      displayDate(
                                                        task.deadline!,
                                                      ),
                                                      style: tNormal.copyWith(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              if (task.time != null)
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      color: cSecondaryColor,
                                                      size: 12.0,
                                                    ),
                                                    const SizedBox(width: 4.0),
                                                    Text(
                                                      formatTime(task.time!),
                                                      style: tNormal.copyWith(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8.0),
                      Text('Concluídas', style: tSmallTitle),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingButton(navigateTo: CreateTaskScreen()),
    );
  }
}
