import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/providers/project_actions_provider.dart';
import 'package:kwanga/providers/projects_provider.dart';
import 'package:kwanga/providers/auth_provider.dart';

import 'package:kwanga/screens/projects_screens/dialogs/select_list_dialog.dart';
import 'package:kwanga/screens/projects_screens/dialogs/select_project_dialog.dart';

import '../../../models/project_action_model.dart';
import '../../../providers/task_list_provider.dart';
import '../../../utils/list_type_utils.dart';
import '../../../widgets/dialogs/kwanga_dialog.dart';
import '../../../widgets/dialogs/kwanga_delete_dialog.dart';

class ProjectActionsList extends ConsumerWidget {
  final List actions;

  const ProjectActionsList({super.key, required this.actions});

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
        final a = actions[idx];

        return Slidable(
          key: ValueKey(a.id),

          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.8,
            children: [

              SlidableAction(
                backgroundColor: Color(0xff2c82b5),
                foregroundColor: Colors.white,
                icon: Icons.folder_copy,
                label: 'Mover',
                onPressed: (_) => _moveAction(context, ref, a),
              ),

              SlidableAction(
                backgroundColor: Color(0xff0261a1),
                foregroundColor: Colors.white,
                icon: Icons.send,
                label: 'Alocar',
                onPressed: (_) => _allocateAction(context, ref, a),
              ),

              SlidableAction(
                backgroundColor: Color(0xff3271D1),
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
                onPressed: (_) => _editAction(context, ref, a),
              ),

              SlidableAction(
                backgroundColor: cTertiaryColor,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Apagar',
                onPressed: (_) => _deleteAction(context, ref, a),
              ),
            ],
          ),

          child: Container(
            color: idx % 2 == 0 ? Colors.white : cSecondaryColor.withAlpha(6),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),

            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: idx,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 24),
                  ),
                ),

                Expanded(
                  child: Text(
                    a.description,
                    style: tNormal.copyWith(
                      decoration: a.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      color: a.isDone ? Colors.grey : Colors.black,
                    ),
                  ),
                ),

                Checkbox(
                  value: a.isDone,
                  onChanged: (_) {
                    ref.read(projectActionsProvider.notifier).toggleActionDone(a.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editAction(
      BuildContext context,
      WidgetRef ref,
      ProjectActionModel action,
      ) async {
    final newText = await showKwangaActionDialog(
      context,
      title: "Editar ação",
      hint: "Descreva a ação",
      initialValue: action.description,
    );

    if (newText == null || newText.trim().isEmpty) return;

    await ref.read(projectActionsProvider.notifier).editAction(
      action.copyWith(description: newText.trim()),
    );
  }

  Future<void> _deleteAction(
      BuildContext context,
      WidgetRef ref,
      ProjectActionModel action,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => KwangaDeleteDialog(
        title: "Eliminar Tarefa",
        message: "Tem a certeza que pretende eliminar \"${action.description}\"? Esta ação é irreversível.",
      ),
    );

    if (confirm == true) {
      await ref.read(projectActionsProvider.notifier).removeAction(action.id);
    }
  }

  Future<void> _moveAction(
      BuildContext context,
      WidgetRef ref,
      ProjectActionModel action,
      ) async {
    final projects = ref.read(projectsProvider).value ?? [];

    final projectId = await showDialog<String>(
      context: context,
      builder: (_) => SelectProjectDialog(
        projects: projects,
        currentProjectId: action.projectId,
      ),
    );

    if (projectId == null) return;

    await ref.read(projectActionsProvider.notifier).moveActionToProject(action.id, projectId);
  }

  Future<void> _allocateAction(
      BuildContext context,
      WidgetRef ref,
      ProjectActionModel action,
      ) async {
    final asyncLists = ref.watch(taskListsProvider);

    // 1️⃣ Se ainda está carregando, NÃO abre caixa vazia
    if (asyncLists.isLoading) {
      showDialog(
        context: context,
        builder: (_) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // Adicionar um pequeno delay para permitir que o diálogo apareça
      await Future.delayed(const Duration(milliseconds: 300));

      Navigator.pop(context); // fecha o loading
      return;
    }

    // 2️⃣ Se deu erro
    if (asyncLists.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao carregar listas.")),
      );
      return;
    }

    // 3️⃣ Temos as listas
    final allLists = asyncLists.value ?? [];

    // 4️⃣ Filtrar apenas listas ACTION
    final actionLists = allLists
        .where((l) => normalizeListType(l.listType) == "action")
        .toList();

    if (actionLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nenhuma lista de ações disponível.")),
      );
      return;
    }

    // 5️⃣ Abrir diálogo
    final listId = await showDialog<String>(
      context: context,
      builder: (_) => SelectListDialog(lists: actionLists),
    );

    if (listId == null) return;

    // 6️⃣ Obter userId
    final user = ref.read(authProvider).value;
    if (user == null || user.id == null) {
      debugPrint("ERRO: userId não encontrado!");
      return;
    }

    // 7️⃣ Alocar ação
    await ref.read(projectActionsProvider.notifier).allocateActionToList(
      action,
      listId,
      user.id!,
    );

    // Opcional: feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ação alocada com sucesso!")),
    );
  }

}
