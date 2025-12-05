import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/providers/project_actions_provider.dart';
import 'package:kwanga/widgets/dialogs/kwanga_dialog.dart';

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
        ref
            .read(projectActionsProvider.notifier)
            .reorderActions(oldIndex, newIndex);
      },

      itemBuilder: (context, idx) {
        final a = actions[idx];

        return Slidable(
          key: ValueKey(a.id),

          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.7,
            children: [
              SlidableAction(
                backgroundColor: cSecondaryColor,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
                onPressed: (_) => _editAction(context, ref, a),
              ),
              SlidableAction(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                icon: Icons.folder_copy_outlined,
                label: 'Mover',
                onPressed: (_) {},
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
                // DRAG HANDLE
                ReorderableDragStartListener(
                  index: idx,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),

                // TEXTO
                Expanded(
                  child: Text(
                    a.description,
                    style: tNormal.copyWith(
                      decoration: a.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: a.isDone ? Colors.grey : Colors.black,
                    ),
                  ),
                ),

                // CHECKBOX
                Checkbox(
                  value: a.isDone,
                  onChanged: (_) {
                    ref
                        .read(projectActionsProvider.notifier)
                        .toggleActionDone(a.id);
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
    dynamic action,
  ) async {
    final newText = await showKwangaActionDialog(
      context,
      title: "Editar ação",
      hint: "Descreva a ação",
      initialValue: action.description,
    );

    if (newText == null || newText.trim().isEmpty) return;

    await ref
        .read(projectActionsProvider.notifier)
        .editAction(action.copyWith(description: newText.trim()));
  }

  Future<void> _deleteAction(
    BuildContext context,
    WidgetRef ref,
    dynamic action,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => KwangaDeleteDialog(
        title: "Eliminar Tarefa",
        message:
            "Tem a certeza que pretende eliminar a tarefa \"${action.description}\"? Esta acção é irreversível.",
      ),
    );

    if (confirm == true) {
      await ref.read(projectActionsProvider.notifier).removeAction(action.id);
    }
  }
}
