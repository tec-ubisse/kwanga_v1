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
import '../../../widgets/feedback_widget.dart';

class ProjectActionsList extends ConsumerStatefulWidget {
  final List<TaskModel> actions;
  final String projectId;

  const ProjectActionsList({
    super.key,
    required this.actions,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectActionsList> createState() => _ProjectActionsListState();
}

class _ProjectActionsListState extends ConsumerState<ProjectActionsList> {
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(String taskId) {
    setState(() {
      if (_selectedIds.contains(taskId)) {
        _selectedIds.remove(taskId);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(taskId);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(widget.actions.map((t) => t.id));
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  List<TaskModel> get _selectedTasks {
    return widget.actions.where((t) => _selectedIds.contains(t.id)).toList();
  }

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
              ? (_, __) {} // Desabilita reordenação no modo de seleção
              : (oldIndex, newIndex) {
            ref
                .read(projectActionsProvider.notifier)
                .reorderActions(oldIndex, newIndex);
          },
          itemBuilder: (context, idx) {
            final task = widget.actions[idx];
            final createdDate =
            DateFormat('dd/MM/yyyy').format(task.createdAt);
            final isSelected = _selectedIds.contains(task.id);

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
              child: InkWell(
                onLongPress: () => _toggleSelection(task.id),
                onTap: _isSelectionMode
                    ? () => _toggleSelection(task.id)
                    : null,
                child: Container(
                  color: isSelected
                      ? cSecondaryColor.withAlpha(30)
                      : (idx % 2 == 0
                      ? Colors.white
                      : cSecondaryColor.withAlpha(6)),
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_isSelectionMode)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? cSecondaryColor
                                    : Colors.grey,
                                size: 24,
                              ),
                            )
                          else
                            ReorderableDragStartListener(
                              index: idx,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(Icons.drag_handle_rounded,
                                    color: Colors.grey, size: 24),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              task.description,
                              style: tNormal.copyWith(
                                decoration: task.completed == 1
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.completed == 1
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                              softWrap: true,
                            ),
                          ),
                          if (!_isSelectionMode)
                            Checkbox(
                              value: task.completed == 1,
                              onChanged: (_) => ref
                                  .read(projectActionsProvider.notifier)
                                  .toggleActionDone(task.id),
                            ),
                        ],
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 48.0, bottom: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range_outlined,
                                size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              createdDate,
                              style: tSmall.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: cSecondaryColor.withAlpha(20),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clearSelection,
            tooltip: 'Cancelar',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              '${_selectedIds.length} selecionado(s)',
              style: tNormal.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.folder_copy),
            onPressed: () => _moveMultipleActions(context, ref),
            tooltip: 'Mover',
            color: const Color(0xff2c82b5),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _allocateMultipleActions(context, ref),
            tooltip: 'Alocar',
            color: const Color(0xff0261a1),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMultipleActions(context, ref),
            tooltip: 'Apagar',
            color: cTertiaryColor,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // --- AÇÕES MÚLTIPLAS ---

  Future<void> _moveMultipleActions(BuildContext context, WidgetRef ref) async {
    final projects = ref.read(projectsProvider).value ?? [];

    final newProjectId = await showDialog<String>(
      context: context,
      builder: (_) => SelectProjectDialog(
        projects: projects,
        currentProjectId: widget.projectId,
      ),
    );

    if (newProjectId == null) return;

    for (final taskId in _selectedIds) {
      await ref
          .read(projectActionsProvider.notifier)
          .moveActionToProject(taskId, newProjectId);
    }

    showFeedbackScaffoldMessenger(
        context, '${_selectedIds.length} tarefa(s) movida(s) com sucesso');
    _clearSelection();
  }

  Future<void> _allocateMultipleActions(
      BuildContext context, WidgetRef ref) async {
    ref.invalidate(taskListsProvider);

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

    try {
      final allLists = await ref.read(taskListsProvider.future);
      Navigator.pop(context);

      final actionLists =
      allLists.where((l) => l.listType == "action").toList();

      if (actionLists.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Nenhuma lista de ações disponível.")));
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

      showFeedbackScaffoldMessenger(
          context, '${_selectedIds.length} tarefa(s) alocada(s) com sucesso');
      _clearSelection();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao carregar listas.")));
    }
  }

  Future<void> _deleteMultipleActions(
      BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => KwangaDeleteDialog(
        title: "Eliminar ações",
        message:
        'Tem a certeza que pretende eliminar ${_selectedIds.length} tarefa(s)?',
      ),
    );

    if (confirm == true) {
      for (final taskId in _selectedIds) {
        await ref.read(projectActionsProvider.notifier).removeAction(taskId);
      }
      showFeedbackScaffoldMessenger(
          context, '${_selectedIds.length} tarefa(s) eliminada(s) com sucesso');
      _clearSelection();
    }
  }

  // --- AÇÕES INDIVIDUAIS ---

  Future<void> _editAction(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    final newText = await showKwangaActionDialog(
      context,
      title: "Editar tarefa",
      hint: "Descreva a acção",
      initialValue: task.description,
      icon: Icons.edit,
    );
    if (newText == null || newText.trim().isEmpty) return;
    await ref
        .read(projectActionsProvider.notifier)
        .editAction(task.copyWith(description: newText.trim()));
    showFeedbackScaffoldMessenger(context, "Tarefa actualizada com sucesso");
  }

  Future<void> _deleteAction(
      BuildContext context, WidgetRef ref, TaskModel task) async {
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
    showFeedbackScaffoldMessenger(context, "Tarefa movida com sucesso");
  }

  Future<void> _allocateAction(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    ref.invalidate(taskListsProvider);

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

    try {
      final allLists = await ref.read(taskListsProvider.future);
      Navigator.pop(context);

      final actionLists =
      allLists.where((l) => l.listType == "action").toList();

      if (actionLists.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Nenhuma lista de ações disponível.")));
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

      showFeedbackScaffoldMessenger(context, "Tarefa alocada com sucesso");
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao carregar listas.")));
    }
  }
}