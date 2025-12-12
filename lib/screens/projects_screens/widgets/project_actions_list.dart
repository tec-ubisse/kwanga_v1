// lib/screens/projects_screens/widgets/project_actions_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/project_actions_provider.dart';
import 'package:kwanga/providers/projects_provider.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/screens/projects_screens/dialogs/select_list_dialog.dart';
import 'package:kwanga/screens/projects_screens/dialogs/select_project_dialog.dart';
import '../../../providers/task_list_provider.dart';
import '../../../widgets/dialogs/kwanga_dialog.dart';
import '../../../widgets/dialogs/kwanga_delete_dialog.dart';

class ProjectActionsList extends ConsumerWidget {
  final List<TaskModel> actions;
  final String projectId;

  const ProjectActionsList({
    super.key,
    required this.actions,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: actions.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(projectActionsProvider.notifier).reorderActions(oldIndex, newIndex);
      },
      itemBuilder: (context, idx) {
        final task = actions[idx];
        final createdDate = DateFormat('dd/MM/yyyy').format(task.createdAt);

        return Slidable(
          key: ValueKey(task.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.8,
            children: [
              SlidableAction(
                backgroundColor: const Color(0xff2c82b5),
                foregroundColor: Colors.white,
                icon: Icons.folder_copy,
                label: 'Mover',
                onPressed: (_) => _moveAction(context, ref, task),
              ),
              SlidableAction(
                backgroundColor: const Color(0xff0261a1),
                foregroundColor: Colors.white,
                icon: Icons.send,
                label: 'Alocar',
                onPressed: (_) => _allocateAction(context, ref, task),
              ),
              SlidableAction(
                backgroundColor: const Color(0xff3271D1),
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
                onPressed: (_) => _editAction(context, ref, task),
              ),
              SlidableAction(
                backgroundColor: cTertiaryColor,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Apagar',
                onPressed: (_) => _deleteAction(context, ref, task),
              ),
            ],
          ),
          child: Container(
            color: idx % 2 == 0 ? Colors.white : cSecondaryColor.withAlpha(6),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ReorderableDragStartListener(
                      index: idx,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 24),
                      ),
                    ),
                    Text(
                      task.description,
                      style: tNormal.copyWith(
                        decoration: task.completed == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                        color: task.completed == 1 ? Colors.grey : Colors.black,
                      ),
                    ),

                    const Spacer(),
                    Checkbox(
                      value: task.completed == 1,
                      onChanged: (_) => ref.read(projectActionsProvider.notifier).toggleActionDone(task.id),
                    ),

                  ],
                ),
                Row(
                  spacing: 4,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 48.0),
                      child: const Icon(Icons.date_range_outlined, size: 12, color: Colors.grey,),
                    ),

                    Text(
                      createdDate,
                      style: tSmall.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editAction(BuildContext context, WidgetRef ref, TaskModel task) async {
    final newText = await showKwangaActionDialog(
      context,
      title: "Editar ação",
      hint: "Descreva a ação",
      initialValue: task.description,
    );
    if (newText == null || newText.trim().isEmpty) return;
    await ref.read(projectActionsProvider.notifier).editAction(task.copyWith(description: newText.trim()));
  }

  Future<void> _deleteAction(BuildContext context, WidgetRef ref, TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => KwangaDeleteDialog(
        title: "Eliminar ação",
        message: 'Tem a certeza que pretende eliminar "${task.description}"?',
      ),
    );

    if (confirm == true) {
      await ref.read(projectActionsProvider.notifier).removeAction(task.id);
    }
  }

  Future<void> _moveAction(BuildContext context, WidgetRef ref, TaskModel task) async {
    final projects = ref.read(projectsProvider).value ?? [];

    final newProjectId = await showDialog<String>(
      context: context,
      builder: (_) => SelectProjectDialog(
        projects: projects,
        currentProjectId: task.projectId,
      ),
    );

    if (newProjectId == null) return;

    // Use provider convenience method
    await ref.read(projectActionsProvider.notifier).moveActionToProject(task.id, newProjectId);
  }

  Future<void> _allocateAction(BuildContext context, WidgetRef ref, TaskModel task) async {
    final asyncLists = ref.watch(taskListsProvider);

    // --- SOLUÇÃO 1: Esperar o carregamento real ---
    if (asyncLists.isLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // Aguarda o provider terminar realmente
      await ref.read(taskListsProvider.future);

      Navigator.pop(context);
    }

    // Atualiza estado após o carregamento
    final loadedLists = ref.read(taskListsProvider);

    if (loadedLists.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao carregar listas."))
      );
      return;
    }

    final allLists = loadedLists.value ?? [];
    final actionLists = allLists.where((l) => l.listType == "action").toList();

    if (actionLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nenhuma lista de ações disponível."))
      );
      return;
    }

    final listId = await showDialog<String>(
      context: context,
      builder: (_) => SelectListDialog(lists: actionLists),
    );

    if (listId == null) return;

    final user = ref.read(authProvider).value;
    if (user == null || user.id == null) return;

    await ref.read(projectActionsProvider.notifier).allocateActionToList(task, listId, user.id!);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ação alocada com sucesso!"))
    );
  }

}
