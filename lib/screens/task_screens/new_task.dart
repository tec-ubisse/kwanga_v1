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
import 'widgets/date_option_selector.dart';
import 'widgets/task_switch_row.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

class NewTaskScreen extends ConsumerStatefulWidget {
  const NewTaskScreen({super.key, required this.listModel, this.taskModel});

  final ListModel listModel;
  final TaskModel? taskModel;

  @override
  ConsumerState<NewTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;

  bool get isEditing => widget.taskModel != null;

  late bool isAction; // listType = action
  String? _selectedListId; // list destino
  DateTime? _selectedDate;

  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedFrequency = 'Todos os dias';

  bool _reminderEnabled = false;
  bool _frequencyEnabled = false;

  String? _listTypeError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    isAction = widget.listModel.listType == 'action';

    _descriptionController = TextEditingController(
      text: widget.taskModel?.description ?? '',
    );

    _selectedListId = isEditing
        ? widget.taskModel!.listId
        : widget.listModel.id;

    if (isEditing) {
      final t = widget.taskModel!;

      _selectedDate = t.deadline;

      if (t.time != null) {
        _reminderEnabled = true;
        _selectedTime = TimeOfDay(hour: t.time!.hour, minute: t.time!.minute);
      }

      if (t.frequency != null && t.frequency!.isNotEmpty) {
        _frequencyEnabled = true;
        _selectedFrequency = t.frequency!.first;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String? _extractProjectId(String listId) {
    if (listId.startsWith("project-")) {
      return listId.substring("project-".length);
    }
    return null;
  }

  Future<void> _saveOrUpdateTask() async {
    final msg = isAction ? "Tarefa" : "Entrada";

    if (!(_formKey.currentState?.validate() ?? false) ||
        _selectedListId == null) {
      if (_selectedListId == null) {
        setState(() => _listTypeError = 'É obrigatório selecionar uma lista');
      }
      return;
    }

    final userId = ref.read(authProvider).value?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilizador não autenticado.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tasksNotifier = ref.read(tasksProvider.notifier);

      final projectId = _extractProjectId(_selectedListId!);

      if (isEditing) {
        final updatedTask = widget.taskModel!.copyWith(
          listId: _selectedListId!,
          projectId: projectId,
          description: _descriptionController.text.trim(),
          deadline: _selectedDate,
          time: _reminderEnabled
              ? DateTime(0, 1, 1, _selectedTime.hour, _selectedTime.minute)
              : null,
          frequency: _frequencyEnabled ? [_selectedFrequency] : null,
        );

        await tasksNotifier.updateTask(updatedTask);

        if (mounted) Navigator.of(context).pop(updatedTask);

        showFeedbackScaffoldMessenger(context, "$msg actualizada com sucesso");

        return;
      }

      final newTask = TaskModel(
        userId: userId,
        listId: _selectedListId!,
        projectId: projectId,
        listType: widget.listModel.listType,
        description: _descriptionController.text.trim(),
        deadline: _selectedDate,
        time: _reminderEnabled
            ? DateTime(0, 1, 1, _selectedTime.hour, _selectedTime.minute)
            : null,
        frequency: _frequencyEnabled ? [_selectedFrequency] : null,
        completed: 0,
      );

      await tasksNotifier.addTask(newTask);

      if (mounted) Navigator.of(context).pop(newTask);

      showFeedbackScaffoldMessenger(context, "$msg adicionada com sucesso");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncLists = ref.watch(listsProvider);
    final msg = isAction ? "Tarefa" : "Entrada";

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar $msg' : 'Adicionar $msg'),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomActionBar(
        buttonText: isEditing ? 'Actualizar' : 'Salvar',
        onPressed: _saveOrUpdateTask,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: defaultPadding,
                child: asyncLists.when(
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(child: Text("Erro: $err")),
                  data: (lists) {
                    if (lists.isEmpty) {
                      return const Center(
                        child: Text("Nenhuma lista disponível."),
                      );
                    }

                    // apenas listas do mesmo tipo (action/entry)
                    final filtered = lists
                        .where((l) => l.listType == widget.listModel.listType)
                        .toList();

                    final selected = filtered.firstWhere(
                          (l) => l.id == _selectedListId,
                      orElse: () => filtered.first,
                    );

                    return Form(
                      key: _formKey,
                      child: Column(
                        spacing: 8.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Escolha uma lista", style: tNormal),
                          KwangaDropdownButton<String>(
                            value: _selectedListId,
                            errorMessage: _listTypeError,
                            items: filtered.map((l) {
                              return DropdownMenuItem(
                                value: l.id,
                                child: Text(l.description),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() {
                              _selectedListId = v;
                              _listTypeError = null;
                            }),
                            labelText: '',
                            hintText: 'Seleccione uma lista',
                          ),


                          const SizedBox(height: 16),
                          Text("Descrição", style: tNormal),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: inputDecoration.copyWith(
                              labelText: "Descrição",
                            ),
                            maxLines: 3,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "Este campo é obrigatório"
                                : null,
                          ),

                          if (isAction) ...[
                            const SizedBox(height: 16),
                            DayWidget(),
                            const SizedBox(height: 16),
                            ReminderWidget(),
                            const SizedBox(height: 16),
                            FrequencyWidget(),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
