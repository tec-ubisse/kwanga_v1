import 'package:flutter/material.dart';
import 'package:kwanga/data/database/database_helper.dart';
import 'package:kwanga/data/database/tarefa_dao.dart';

import 'package:kwanga/models/tarefa_model.dart';

class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key});

  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  final TarefaDao _databaseService = TarefaDao();
  String? _task = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'To-Do App',
          style: TextStyle(color: Theme.of(context).canvasColor),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text('Add Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _task = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Add Task',
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        if (_task == null || _task == " ") return;
                        _databaseService.addTask(_task!);
                        setState(() {
                          _task = null;
                        });
                        Navigator.pop(context);
                      },
                      color: Theme.of(context).colorScheme.primary,
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder<List<Tarefa>>(
        future: _databaseService.getTarefas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa encontrada.'));
          } else {
            final tarefas = snapshot.data!;
            return ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = tarefas[index];
                return ListTile(
                  title: Text(tarefa.content),
                  onLongPress: () async {
                    await _databaseService.apagarTarefa(tarefa.id);
                    setState(() {}); // recarrega a lista
                  },
                  trailing: Checkbox(
                    value: tarefa.status == 1,
                    onChanged: (value) async {
                      await _databaseService.actualizarTarefa(
                        tarefa.id,
                        value == true ? 1 : 0,
                      );
                      setState(() {}); // recarrega a lista
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
