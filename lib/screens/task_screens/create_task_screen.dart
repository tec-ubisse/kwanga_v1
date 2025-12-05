import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/providers/tasks_provider.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import 'widgets/date_option_selector.dart';
import 'widgets/task_switch_row.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({
    super.key,
    required this.listModel,
    this.taskModel,
  });

  final ListModel listModel;
  final TaskModel? taskModel;

  @override
  ConsumerState<CreateTaskScreen> createState() =>
      _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;

  late bool isAction;
  DateTime? _selectedDate;
  String? _selectedListId;

  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedFrequency = 'Todos os dias';

  bool _reminderEnabled = false;
  bool _frequencyEnabled = false;

  String? _listTypeError;
  bool _isLoading = false;

  bool get isEditing => widget.taskModel != null;

  @override
  void initState() {
    super.initState();

    isAction = widget.listModel.listType == 'action';

    _descriptionController = TextEditingController(
      text: widget.taskModel?.description ?? '',
    );

    _selectedListId =
    isEditing ? widget.taskModel!.listId : widget.listModel.id;

    if (isEditing) {
      final t = widget.taskModel!;

      _selectedDate = t.deadline;

      if (t.time != null) {
        _reminderEnabled = true;
        _selectedTime = TimeOfDay(
          hour: t.time!.hour,
          minute: t.time!.minute,
        );
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

  Future<void> _saveOrUpdateTask() async {
    final message = isAction ? "Tarefa" : "Entrada";

    if (!(_formKey.currentState?.validate() ?? false) ||
        _selectedListId == null) {
      if (_selectedListId == null) {
        setState(() =>
        _listTypeError = 'É obrigatório selecionar uma lista');
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
      final now = DateTime.now();

      if (isEditing) {
        final updatedTask = widget.taskModel!.copyWith(
          listId: _selectedListId!,
          description: _descriptionController.text.trim(),
          deadline: _selectedDate,
          time: _reminderEnabled
              ? DateTime(0, 1, 1, _selectedTime.hour, _selectedTime.minute)
              : null,
          frequency:
          _frequencyEnabled ? [_selectedFrequency] : null,
        );

        await tasksNotifier.updateTask(updatedTask);

        if (mounted) {
          Navigator.of(context).pop(updatedTask); // <-- SOLUÇÃO A
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$message atualizada com sucesso.')),
        );
      } else {
        final newTask = TaskModel(
          description: _descriptionController.text.trim(),
          listType: widget.listModel.listType,
          listId: _selectedListId!,
          deadline: _selectedDate,
          frequency:
          _frequencyEnabled ? [_selectedFrequency] : null,
          userId: userId,
          time: _reminderEnabled
              ? DateTime(0, 1, 1, _selectedTime.hour, _selectedTime.minute)
              : null,
          completed: 0,
        );

        await tasksNotifier.addTask(newTask);

        if (mounted) {
          Navigator.of(context).pop(newTask); // <-- SOLUÇÃO A
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$message adicionada com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncLists = ref.watch(listsProvider);
    final message = isAction ? "Tarefa" : "Entrada";

    return Scaffold(
      appBar: AppBar(
        title:
        Text(isEditing ? 'Editar $message' : 'Adicionar $message'),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: defaultPadding,
              child: asyncLists.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Erro: $err')),
                data: (lists) {
                  final filteredLists = lists
                      .where((l) =>
                  l.listType == widget.listModel.listType)
                      .toList();

                  final selectedList = filteredLists
                      .where((l) => l.id == _selectedListId)
                      .firstOrNull;

                  if (lists.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma lista encontrada.'),
                    );
                  }

                  return Form(
                    key: _formKey,
                    child: Column(
                      spacing: 8.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Escolha uma lista', style: tNormal),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(12.0),
                            border: Border.all(
                              color: _listTypeError != null
                                  ? Theme.of(context)
                                  .colorScheme
                                  .error
                                  : cBlackColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                'Escolha a ${widget.listModel.listType}',
                              ),
                              value: selectedList?.id,
                              items: filteredLists
                                  .map(
                                    (list) => DropdownMenuItem(
                                  value: list.id,
                                  child:
                                  Text(list.description),
                                ),
                              )
                                  .toList(),
                              onChanged: (value) => setState(
                                      () => _selectedListId = value),
                            ),
                          ),
                        ),
                        if (_listTypeError != null)
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _listTypeError!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16.0),
                        Text('Escreva a descrição', style: tNormal),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: inputDecoration.copyWith(
                            labelText: 'Descrição',
                          ),
                          maxLines: 3,
                          validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Este campo é obrigatório'
                              : null,
                        ),
                        if (isAction)
                          Column(
                            children: [
                              DateOptionSelector(
                                onDateChanged: (date) =>
                                    setState(() =>
                                    _selectedDate = date),
                              ),
                              TaskSwitchRow.reminder(
                                enabled: _reminderEnabled,
                                time: _selectedTime,
                                onChanged: (v) =>
                                    setState(() =>
                                    _reminderEnabled = v),
                                onTimePicked: (time) =>
                                    setState(() =>
                                    _selectedTime = time),
                              ),
                              TaskSwitchRow.frequency(
                                enabled: _frequencyEnabled,
                                frequency: _selectedFrequency,
                                onChanged: (v) =>
                                    setState(() =>
                                    _frequencyEnabled = v),
                                onFrequencySelected: (freq) =>
                                    setState(() =>
                                    _selectedFrequency = freq),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 12.0, horizontal: 24.0),
            child: _isLoading
                ? const CircularProgressIndicator()
                : GestureDetector(
              onTap: _saveOrUpdateTask,
              child:
              const MainButton(buttonText: 'Salvar'),
            ),
          ),
        ],
      ),
    );
  }
}
