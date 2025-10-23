import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/task_model.dart';
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
  late Future<List<TaskModel>> _tasksFuture;
  UserModel? currentUser = UserModel(
    id: 2025,
    email: 'alberto.ubisse@gmail.com',
    password: 'tech@123',
  );

  void loadTasks() {
    setState(() {
      setState(() {
        _tasksFuture = _taskDao.getTaskByUserId(currentUser!.id!);
      });
    });
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
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
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => CreateTaskScreen()));
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
          children: [
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

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xffEAEFF4),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(task.listType),
                          ),
                        ),
                      );
                    },
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
        )
    );
  }
}
