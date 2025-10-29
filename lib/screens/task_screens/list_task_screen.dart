import 'package:flutter/material.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/screens/task_screens/update_task_screen.dart';
import 'package:kwanga/screens/task_screens/widgets/create_task_to_list.dart';
import 'package:kwanga/screens/task_screens/widgets/task_tile.dart';

import '../../widgets/buttons/floating_button.dart';
import 'create_task_screen.dart';

class ListTasksScreen extends StatefulWidget {
  final ListModel listModel;

  const ListTasksScreen({super.key, required this.listModel});

  @override
  State<ListTasksScreen> createState() => _ListTasksScreenState();
}

class _ListTasksScreenState extends State<ListTasksScreen> {
  final TaskDao _taskDao = TaskDao();

  bool _loading = true;
  List<TaskModel> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _taskDao.getTasksByListId(widget.listModel.id);
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar tarefas: $e')));
    }
  }

  Future<void> _updateTask(TaskModel task) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateTaskScreen(task: task),
      ),
    ).then((updated) {
      if (updated == true) {
        ListTasksScreen(listModel: widget.listModel,);
      }
    });

  }

  void _selectTasks() {

  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Tarefa',
          style: tTitle.copyWith(color: cTertiaryColor),
        ),
        content: Text(
          'Tem certeza que deseja eliminar a tarefa "${task.description}"?',
          style: tNormal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!(confirm ?? false)) return;

    final idx = _tasks.indexWhere((t) => t.id == task.id);
    TaskModel? backup;
    if (idx != -1) {
      backup = _tasks[idx];
      setState(() => _tasks.removeAt(idx));
    }

    try {
      await _taskDao.deleteTask(task.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa eliminada com sucesso.')),
      );
    } catch (e) {
      // Reverte se falhar
      if (backup != null && mounted) {
        setState(() => _tasks.insert(idx, backup!));
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao eliminar tarefa: $e')));
      }
    }
  }

  Future<void> _toggleTaskStatus(TaskModel task, int newStatus) async {
    // Atualização otimista (sem copyWith; mutamos o objeto e rebuild)
    final prev = task.completed;
    setState(() {
      task.completed = newStatus;
    });

    try {
      await _taskDao.updateTaskStatus(task.id, newStatus);
    } catch (e) {
      // Reverte em caso de falha
      if (!mounted) return;
      setState(() {
        task.completed = prev;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar tarefa: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(widget.listModel.description),
      ),
      body: Padding(
        padding: defaultPadding,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma tarefa nesta lista.',
                  style: tNormal.copyWith(fontStyle: FontStyle.italic),
                ),
              )
            : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return TaskTile(
                    task: task,
                    onDelete: _deleteTask,
                    onTap: _updateTask,
                    onLongPress: _selectTasks,
                    onToggleComplete: (TaskModel t, int status) {
                      _toggleTaskStatus(t, status);
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingButton(navigateTo: CreateTaskToList(selectedList: widget.listModel),),
    );
  }
}
