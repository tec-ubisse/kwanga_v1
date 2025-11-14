import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/providers/tasks_provider.dart';
import 'package:kwanga/screens/task_screens/create_task_screen.dart';
import 'package:kwanga/screens/task_screens/widgets/task_list_view.dart';
import 'package:kwanga/widgets/custom_drawer.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  String _norm(Object? v) {
    if (v == null) return '';
    return v.toString().trim().toLowerCase();
  }

  bool _isEntryList(ListModel l) {
    final type = _norm(l.listType);
    final desc = _norm(l.description);

    return type.contains('entrada') ||
        type.contains('inbox') ||
        type == 'in' ||
        desc.contains('entrada') ||
        desc.contains('inbox');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(tasksProvider);
    final asyncLists = ref.watch(listsProvider);
    final userId = ref.watch(authProvider).value?.id;

    final isSelectionMode = ref.watch(taskSelectionModeProvider);
    final selectedTaskIds = ref.watch(selectedTasksProvider);
    final selectedButton = ref.watch(taskFilterProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: isSelectionMode
            ? Text('${selectedTaskIds.length} selecionada(s)')
            : const Text('Tarefas'),
        actions: isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar selecionadas',
            onPressed: () =>
                ref.read(tasksProvider.notifier).deleteSelected(),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Cancelar selecção',
            onPressed: () {
              ref.read(taskSelectionModeProvider.notifier).disable();
              ref.read(selectedTasksProvider.notifier).clear();
            },
          ),
        ]
            : [],
      ),
      drawer: isSelectionMode ? null : const CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: asyncTasks.when(
          data: (tasks) => asyncLists.when(
            data: (lists) {
              if (userId == null) {
                return const Center(child: Text('Utilizador não encontrado.'));
              }

              final entryLists = lists.where(_isEntryList).toList();
              final entryIds = entryLists.map((e) => e.id).toSet();

              final tasksFiltered = tasks
                  .where((t) => !entryIds.contains(_norm(t.listId)))
                  .toList();

              if (tasksFiltered.isEmpty) {
                return const Center(
                  child: Text('Nenhuma tarefa de ação encontrada.'),
                );
              }

              return TaskListView(
                tasks: tasksFiltered,
                lists: lists,
                selectedButton: selectedButton,
                onSelectButton: (index) =>
                    ref.read(taskFilterProvider.notifier).setFilter(index),
                onDelete: (task) =>
                    ref.read(tasksProvider.notifier).deleteTask(task.id),
                onToggleComplete: (task, newValue) =>
                    ref.read(tasksProvider.notifier)
                        .updateTaskStatus(task.id, newValue == 1),
                onUpdate: (task) async {
                  final list = lists.firstWhere(
                        (l) => l.id == task.listId,
                    orElse: () => ListModel(
                      id: '',
                      userId: userId,
                      description: 'Lista desconhecida',
                      listType: '',
                    ),
                  );

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateTaskScreen(
                        listModel: list,
                        taskModel: task,
                      ),
                    ),
                  );
                },
                onLongPressTask: null,
                onTapTask: (task, _) {
                  ref.read(tasksProvider.notifier)
                      .updateTaskStatus(task.id, task.completed == 0);
                },
              );
            },
            loading: () =>
            const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Erro a carregar listas: $err')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Erro a carregar tarefas: $err')),
        ),
      ),
    );
  }
}
