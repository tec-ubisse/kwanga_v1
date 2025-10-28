import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/screens/task_screens/widgets/task_list_view.dart';
import 'package:kwanga/widgets/custom_drawer.dart';
import 'create_task_screen.dart';

class TaskTrailingScreen extends StatefulWidget {
  const TaskTrailingScreen({super.key});

  @override
  State<TaskTrailingScreen> createState() => _TaskTrailingScreenState();
}

class _TaskTrailingScreenState extends State<TaskTrailingScreen> {
  final TaskDao _taskDao = TaskDao();
  final ListDao _listDao = ListDao();
  int selectedButton = 0;

  late Future<List<TaskModel>> _tasksFuture;
  late Future<List<ListModel>> _listsFuture;

  final UserModel currentUser = UserModel(
    id: 2025,
    email: 'alberto.ubisse@gmail.com',
    password: 'tech@123',
  );

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    setState(() {
      _tasksFuture = _taskDao.getTaskByUserId(currentUser.id!);
      _listsFuture = _listDao.getAll();
    });
  }

  void selectButton(int index) {
    setState(() => selectedButton = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: const Text('Meu Dia'),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: FutureBuilder<List<TaskModel>>(
          future: _tasksFuture,
          builder: (context, taskSnap) {
            if (taskSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (taskSnap.hasError) {
              return Center(child: Text('Erro: ${taskSnap.error}'));
            }
            final tasks = taskSnap.data ?? [];

            return FutureBuilder<List<ListModel>>(
              future: _listsFuture,
              builder: (context, listSnap) {
                if (listSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (listSnap.hasError) {
                  return Center(child: Text('Erro: ${listSnap.error}'));
                }
                final lists = listSnap.data ?? [];

                return TaskListView(
                  tasks: tasks,
                  lists: lists,
                  selectedButton: selectedButton,
                  onSelectButton: selectButton,
                  onDelete: (task) async {
                    await _taskDao.deleteTask(task.id);
                    loadData();
                  },
                  onToggleComplete: (task, newValue) async {
                    await _taskDao.updateTaskStatus(task.id, newValue);
                    setState(() {
                      task.completed = newValue;
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cMainColor,
        child: const Icon(Icons.add, color: cWhiteColor),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
        },
      ),
    );
  }
}
