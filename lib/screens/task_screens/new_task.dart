import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';

import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/providers/tasks/tasks_provider.dart';

import 'package:kwanga/screens/task_screens/widgets/day_widget.dart';
import 'package:kwanga/screens/task_screens/widgets/frequency_widget.dart';
import 'package:kwanga/screens/task_screens/widgets/reminder_widget.dart';

import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import '../../widgets/feedback_widget.dart';
import '../../widgets/kwanga_dropdown_button.dart';

class NewTaskScreen extends ConsumerStatefulWidget {
  const NewTaskScreen({
    super.key,
    required this.listModel,
    this.projectId,
    this.taskModel,
    this.fixList,
  });

  final ListModel listModel;
  final TaskModel? taskModel;
  final bool? fixList;
  final String? projectId;

  @override
  ConsumerState<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends ConsumerState<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;

  bool get isEditing => widget.taskModel != null;
  bool get isListFixed => widget.fixList == true;

  late bool isAction;

  String? _selectedListId;
  DateTime? _selectedDate;

  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _reminderEnabled = false;

  Set<int> _selectedFrequencyDays = {};

  String? _listTypeError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    isAction =
        widget.projectId != null || widget.listModel.listType == 'action';

    _descriptionController = TextEditingController(
      text: widget.taskModel?.description ?? '',
    );

    _selectedListId = isEditing
        ? widget.taskModel!.listId
        : widget.projectId != null
        ? 'project-${widget.projectId}'
        : widget.listModel.id;

    if (isEditing) {
      final t = widget.taskModel!;

      _selectedDate = t.deadline;

      if (t.time != null) {
        _reminderEnabled = true;
        _selectedTime =
            TimeOfDay(hour: t.time!.hour, minute: t.time!.minute);
      }

      if (t.frequency != null && t.frequency!.isNotEmpty) {
        _selectedFrequencyDays = t.frequency!
            .map((e) => int.tryParse(e))
            .whereType<int>()
            .where((e) => e >= 0 && e < 7)
            .toSet();
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String? _extractProjectId(String listId) {
    if (listId.startsWith('project-')) {
      return listId.substring('project-'.length);
    }
    return null;
  }

  Future<void> _saveOrUpdateTask() async {
    if (_isLoading) return;

    final msg = isAction ? 'Tarefa' : 'Entrada';

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final tasksNotifier = ref.read(tasksProvider.notifier);
      final projectId = _extractProjectId(_selectedListId!);

      final DateTime? timeToSave = _reminderEnabled
          ? DateTime(
        0,
        1,
        1,
        _selectedTime.hour,
        _selectedTime.minute,
      )
          : null;

      final List<String>? frequencyToSave =
      _selectedFrequencyDays.isEmpty
          ? null
          : _selectedFrequencyDays.map((d) => d.toString()).toList();

      // =========================
      // ✏️ EDIÇÃO
      // =========================
      if (isEditing) {
        final updatedTask = widget.taskModel!.copyWith(
          listId: _selectedListId!,
          projectId: projectId,
          description: _descriptionController.text.trim(),

          // 🔑 CORREÇÃO CRÍTICA
          deadline: Nullable(_selectedDate),
          time: Nullable(timeToSave),
          frequency: Nullable(frequencyToSave),
        );

        await tasksNotifier.updateTask(updatedTask);

        if (mounted) Navigator.pop(context, updatedTask);
        showFeedbackScaffoldMessenger(
          context,
          '$msg actualizada com sucesso',
        );
        return;
      }

      // =========================
      // ➕ CRIAÇÃO
      // =========================
      final newTask = TaskModel(
        userId: userId,
        listId: _selectedListId!,
        projectId: projectId,
        listType:
        widget.projectId != null ? 'action' : widget.listModel.listType,
        description: _descriptionController.text.trim(),
        deadline: _selectedDate,
        time: timeToSave,
        frequency: frequencyToSave,
        completed: 0,
      );

      await tasksNotifier.addTask(newTask);

      if (mounted) Navigator.pop(context, newTask);
      showFeedbackScaffoldMessenger(
        context,
        '$msg adicionada com sucesso',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncLists = ref.watch(listsProvider);
    final msg = isAction ? 'Tarefa' : 'Entrada';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar $msg' : 'Adicionar $msg'),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),
      bottomNavigationBar: BottomActionBar(
        buttonText: isEditing ? 'Actualizar' : 'Salvar',
        onPressed: _isLoading ? null : _saveOrUpdateTask,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: defaultPadding,
          child: widget.projectId != null
              ? _buildForm(null)
              : asyncLists.when(
            loading: () =>
            const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (lists) {
              final filtered = lists
                  .where(
                    (l) => l.listType == widget.listModel.listType,
              )
                  .toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text('Nenhuma lista disponível.'),
                );
              }

              return _buildForm(filtered);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(List<ListModel>? lists) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.projectId == null && lists != null) ...[
            Text('Escolha uma lista', style: tLabel),
            KwangaDropdownButton<String>(
              isDisabled: isListFixed,
              value: _selectedListId,
              errorMessage: _listTypeError,
              items: lists
                  .map(
                    (l) => DropdownMenuItem(
                  value: l.id,
                  child: Text(l.description),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedListId = v;
                _listTypeError = null;
              }),
              labelText: '',
              hintText: 'Seleccione uma lista',
            ),
            const SizedBox(height: 16),
          ],
          Text('Descrição', style: tLabel),
          TextFormField(
            controller: _descriptionController,
            decoration:
            inputDecoration.copyWith(labelText: 'Descrição'),
            maxLines: 3,
            validator: (v) =>
            v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
          ),
          if (isAction) ...[
            const SizedBox(height: 16),
            DayWidget(
              value: _selectedDate,
              onChanged: (d) => setState(() => _selectedDate = d),
            ),
            const SizedBox(height: 16),
            ReminderWidget(
              enabled: _reminderEnabled,
              time: _selectedTime,
              onToggle: (v) => setState(() {
                _reminderEnabled = v;
                if (!v) {
                  _selectedTime =
                  const TimeOfDay(hour: 9, minute: 0);
                }
              }),
              onTimeChanged: (t) =>
                  setState(() => _selectedTime = t),
            ),
            const SizedBox(height: 16),
            FrequencyWidget(
              value: _selectedFrequencyDays,
              onChanged: (v) =>
                  setState(() => _selectedFrequencyDays = v),
            ),
          ],
        ],
      ),
    );
  }
}
