import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/screens/lists_screens/create_lists_screen.dart';
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
  String? shownDate = '';
  late Future<List<TaskModel>> _tasksFuture;
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
      setState(() {
        _tasksFuture = _taskDao.getTaskByUserId(currentUser!.id!);
      });
    });
  }

  void deleteTask(TaskModel currentTask) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Eliminar Tarefa',
          style: tTitle.copyWith(color: cTertiaryColor),
        ),
        content: Text(
          'Tem certeza que deseja eliminar a tarefa ${currentTask.description}?',
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
              _taskDao.deleteTask(currentTask.id);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => TaskScreen()),
              );
            },
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

  void completeTask(TaskModel currentTask) async {
    setState(() {
      currentTask.completed = !currentTask.completed;
    });
    await _taskDao.updateTask(currentTask);
  }

  String formatTime(DateTime time) {
    final timeOfDay = TimeOfDay.fromDateTime(time);
    return timeOfDay.format(context); // Ex: "14:30"
  }

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      loadTasks();
    } else {
      print('Nenhum usuário logado');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget emptyData = Padding(
      padding: defaultPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const Spacer(),
          Text(
            'Você não tem tarefas ainda',
            style: tSmallTitle.copyWith(),
            textAlign: TextAlign.center,
          ),
          Text(
            'Crie uma lista para adicionar tarefas',
            style: tNormal.copyWith(fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
          // const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => CreateListsScreen()));
            },
            child: MainButton(buttonText: 'Criar Lista de Tarefas'),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text('Meu Dia'),
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR BUTTONS
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // TODAS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: cSecondaryColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'Todas',
                      style: tNormal.copyWith(color: cWhiteColor),
                    ),
                  ),
                  // ACCAO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 24.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text('Hoje', style: tNormal),
                  ),
                  // ENTRADAS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 24.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text('Amanhã', style: tNormal),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 24.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text('Planejado', style: tNormal),
                  ),
                ],
              ),
            ),

            // TASKS LIST
            Expanded(
              flex: 19,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('Tarefas  ', style: tSmallTitle),
                                CircleAvatar(
                                  radius: 8.0,
                                  backgroundColor: cSecondaryColor,
                                  child: Text(
                                    '${tasks.length}',
                                    style: tSmallTitle.copyWith(color: cWhiteColor, fontSize: 10.0),
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down, color: cBlackColor,)
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 19,
                        child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return GestureDetector(
                              onTap: () {
                                completeTask(task);
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
                                        onPressed: (_) {
                                          deleteTask(task);
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
                                          task.completed
                                              ? CircleAvatar(
                                                  radius: 10.0,
                                                  backgroundColor:
                                                      cSecondaryColor,
                                                )
                                              : CircleAvatar(
                                                  radius: 10.0,
                                                  backgroundColor:
                                                      cSecondaryColor,
                                                  child: CircleAvatar(
                                                    radius: 8.0,
                                                    backgroundColor: Color(
                                                      0xffEAEFF4,
                                                    ),
                                                  ),
                                                ),
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
                                                // LIST AND DEADLINE
                                                Row(
                                                  spacing: 32.0,
                                                  children: [
                                                    Row(
                                                      spacing: 4.0,
                                                      children: [
                                                        Icon(
                                                          Icons.list,
                                                          color:
                                                              cSecondaryColor,
                                                          size: 16.0,
                                                        ),
                                                        Text(
                                                          task.listType,
                                                          style: tNormal
                                                              .copyWith(
                                                                fontSize: 10,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (task.deadline != null)
                                                      Row(
                                                        spacing: 4.0,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_month,
                                                            color:
                                                                cSecondaryColor,
                                                            size: 16.0,
                                                          ),
                                                          Text(
                                                            displayDate(
                                                              task.deadline!,
                                                            ),
                                                            style: tNormal
                                                                .copyWith(
                                                                  fontSize: 10,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),

                                                // TIME
                                                if (task.time != null)
                                                  Row(
                                                    spacing: 4.0,
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_today,
                                                        color: cSecondaryColor,
                                                        size: 12.0,
                                                      ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: cMainColor,
        child: Icon(Icons.add, color: cWhiteColor),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => CreateTaskScreen()));
        },
      ),
    );
  }
}
