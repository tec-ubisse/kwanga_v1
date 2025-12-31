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

import '../../../models/list_model.dart';
import '../../../providers/task_list_provider.dart';

import '../../../widgets/dialogs/kwanga_delete_dialog.dart';
import '../../../widgets/feedback_widget.dart';

import '../../task_screens/new_task.dart';

class ProjectActionsList extends ConsumerStatefulWidget {
  final List<TaskModel> actions;
  final String projectId;

  const ProjectActionsList({
    super.key,
    required this.actions,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectActionsList> createState() =>
      _ProjectActionsListState();
}

class _ProjectActionsListState extends ConsumerState<ProjectActionsList> {
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  // =========================
  // SELEÇÃO
  // =========================

  void _toggleSelection(String taskId) {
    setState(() {
      if (_selectedIds.contains(taskId)) {
        _selectedIds.remove(taskId);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(taskId);
        _isSelectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  List<TaskModel> get _selectedTasks =>
      widget.actions.where((t) => _selectedIds.contains(t.id)).toList();

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isSelectionMode) _buildActionBar(context),

        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: widget.actions.length,

          onReorder: _isSelectionMode
              ? (_, __) {}
              : (oldIndex, newIndex) {
            ref
                .read(projectActionsProvider.notifier)
                .reorderActions(oldIndex, newIndex);
          },

          itemBuilder: (context, idx) {
            final task = widget.actions[idx];
            final isSelected = _selectedIds.contains(task.id);
            final createdDate = DateFormat('dd/MM/yyyy').format(task.createdAt);

            return Slidable(
              key: ValueKey(task.id),
              enabled: !_isSelectionMode,
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
                color: isSelected
                    ? cSecondaryColor.withAlpha(30)
                    : (idx.isEven
                    ? Colors.white
                    : cSecondaryColor.withAlpha(6)),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DRAG HANDLE - Isolado, só para drag
                    if (!_isSelectionMode)
                      ReorderableDragStartListener(
                        index: idx,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: const Icon(
                            Icons.drag_handle_rounded,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),

                    // CHECKBOX DE SELEÇÃO
                    if (_isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected ? cSecondaryColor : Colors.grey,
                          size: 24,
                        ),
                      ),

                    // CONTEÚDO DA TAREFA - Área clicável
                    Expanded(
                      child: GestureDetector(
                        onTap: _isSelectionMode
                            ? () => _toggleSelection(task.id)
                            : null,
                        onLongPress: !_isSelectionMode
                            ? () => _toggleSelection(task.id)
                            : null,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8, top: 4),
                              child: Text(
                                task.description,
                                style: tNormal.copyWith(
                                  decoration: task.completed == 1
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.completed == 1
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.date_range_outlined,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  createdDate,
                                  style: tSmall.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // CHECKBOX DE COMPLETAR
                    if (!_isSelectionMode)
                      Checkbox(
                        value: task.completed == 1,
                        onChanged: (_) => ref
                            .read(projectActionsProvider.notifier)
                            .toggleActionDone(task.id),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // =========================
  // ACTION BAR
  // =========================

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: cSecondaryColor.withAlpha(20),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: _clearSelection,
            tooltip: 'Cancelar',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_selectedIds.length} selecionada${_selectedIds.length > 1 ? 's' : ''}',
              style: tNormal.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.folder_copy, size: 22),
            onPressed: () => _moveMultipleActions(context, ref),
            tooltip: 'Mover',
            color: const Color(0xff2c82b5),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.send, size: 22),
            onPressed: () => _allocateMultipleActions(context, ref),
            tooltip: 'Alocar',
            color: const Color(0xff0261a1),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete, size: 22),
            onPressed: () => _deleteMultipleActions(context, ref),
            tooltip: 'Apagar',
            color: cTertiaryColor,
          ),
        ],
      ),
    );
  }

  // =========================
  // AÇÕES MÚLTIPLAS
  // =========================

  Future<void> _moveMultipleActions(
      BuildContext context, WidgetRef ref) async {
    final projects = ref.read(projectsProvider).value ?? [];

    final newProjectId = await showDialog<String>(
      context: context,
      builder: (_) => SelectProjectDialog(
        projects: projects,
        currentProjectId: widget.projectId,
      ),
    );

    if (newProjectId == null) return;

    for (final id in _selectedIds) {
      await ref
          .read(projectActionsProvider.notifier)
          .moveActionToProject(id, newProjectId);
    }

    if (context.mounted) {
      showFeedbackScaffoldMessenger(
          context, '${_selectedIds.length} tarefa(s) movida(s)');
    }
    _clearSelection();
  }

  Future<void> _allocateMultipleActions(
      BuildContext context, WidgetRef ref) async {
    ref.invalidate(taskListsProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final lists = await ref.read(taskListsProvider.future);
      if (!context.mounted) return;
      Navigator.pop(context);

      final actionLists = lists.where((l) => l.listType == 'action').toList();
      if (actionLists.isEmpty) {
        if (context.mounted) {
          showFeedbackScaffoldMessenger(
              context, 'Nenhuma lista disponível');
        }
        return;
      }

      final listId = await showDialog<String>(
        context: context,
        builder: (_) => SelectListDialog(lists: actionLists),
      );

      if (listId == null) return;

      final user = ref.read(authProvider).value;
      if (user == null || user.id == null) return;

      for (final task in _selectedTasks) {
        await ref
            .read(projectActionsProvider.notifier)
            .allocateActionToList(task, listId, user.id!);
      }

      if (context.mounted) {
        showFeedbackScaffoldMessenger(
            context, '${_selectedIds.length} tarefa(s) alocada(s)');
      }
      _clearSelection();
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        showFeedbackScaffoldMessenger(context, 'Erro ao carregar listas');
      }
    }
  }

  Future<void> _deleteMultipleActions(
      BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => KwangaDeleteDialog(
        title: 'Eliminar tarefas',
        message:
        'Tem a certeza que pretende eliminar ${_selectedIds.length} tarefa(s)?',
      ),
    );

    if (confirm == true) {
      for (final id in _selectedIds) {
        await ref
            .read(projectActionsProvider.notifier)
            .removeAction(id);
      }
      if (context.mounted) {
        showFeedbackScaffoldMessenger(
            context, '${_selectedIds.length} tarefa(s) eliminada(s)');
      }
      _clearSelection();
    }
  }

  // =========================
  // AÇÕES INDIVIDUAIS
  // =========================

  Future<void> _editAction(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewTaskScreen(
          taskModel: task,
          projectId: widget.projectId,
          fixList: true,
          listModel: ListModel(
            userId: task.userId,
            listType: 'action',
            description: 'Tarefas do projecto',
            isProject: true,
          ),
        ),
      ),
    );

    if (result != null && context.mounted) {
      ref
          .read(projectActionsProvider.notifier)
          .loadByProjectId(widget.projectId);
      showFeedbackScaffoldMessenger(
          context, 'Tarefa actualizada');
    }
  }

  Future<void> _deleteAction(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => KwangaDeleteDialog(
        title: 'Eliminar tarefa',
        message:
        'Tem a certeza que pretende eliminar "${task.description}"?',
      ),
    );

    if (confirm == true) {
      await ref
          .read(projectActionsProvider.notifier)
          .removeAction(task.id);
    }
  }

  Future<void> _moveAction(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    final projects = ref.read(projectsProvider).value ?? [];

    final newProjectId = await showDialog<String>(
      context: context,
      builder: (_) => SelectProjectDialog(
        projects: projects,
        currentProjectId: task.projectId,
      ),
    );

    if (newProjectId == null) return;

    await ref
        .read(projectActionsProvider.notifier)
        .moveActionToProject(task.id, newProjectId);

    if (context.mounted) {
      showFeedbackScaffoldMessenger(context, 'Tarefa movida');
    }
  }

  Future<void> _allocateAction(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    ref.invalidate(taskListsProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final lists = await ref.read(taskListsProvider.future);
      if (!context.mounted) return;
      Navigator.pop(context);

      final actionLists = lists.where((l) => l.listType == 'action').toList();
      if (actionLists.isEmpty) {
        if (context.mounted) {
          showFeedbackScaffoldMessenger(
              context, 'Nenhuma lista disponível');
        }
        return;
      }

      final listId = await showDialog<String>(
        context: context,
        builder: (_) => SelectListDialog(lists: actionLists),
      );

      if (listId == null) return;

      final user = ref.read(authProvider).value;
      if (user == null || user.id == null) return;

      await ref
          .read(projectActionsProvider.notifier)
          .allocateActionToList(task, listId, user.id!);

      if (context.mounted) {
        showFeedbackScaffoldMessenger(context, 'Tarefa alocada');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        showFeedbackScaffoldMessenger(context, 'Erro ao carregar listas');
      }
    }
  }
}