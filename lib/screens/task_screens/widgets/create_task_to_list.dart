import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';

import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/providers/tasks_provider.dart';

import 'package:kwanga/screens/task_screens/widgets/date_option_selector.dart';
import 'package:kwanga/screens/task_screens/widgets/task_switch_row.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

class CreateTaskToList extends ConsumerStatefulWidget {
  final ListModel selectedList;

  const CreateTaskToList({super.key, required this.selectedList});

  @override
  ConsumerState<CreateTaskToList> createState() => _CreateTaskToListState();
}

class _CreateTaskToListState extends ConsumerState<CreateTaskToList> {
  final _formKey = GlobalKey<FormState>();

  String _taskDescription = '';
  DateTime? _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  String _selectedFrequency = 'Todos os dias';
  bool _reminderEnabled = false;
  bool _frequencyEnabled = false;

  void _onDateChanged(DateTime? date) => setState(() => _selectedDate = date);
  void _onTimePicked(TimeOfDay time) => setState(() => _selectedTime = time);
  void _onFrequencySelected(String freq) => setState(() => _selectedFrequency = freq);

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).value;
    if (user?.id == null) return;

    final now = DateTime.now();

    final task = TaskModel(
      userId: user!.id!,
      listId: widget.selectedList.id,
      listType: widget.selectedList.listType,
      projectId: widget.selectedList.listType == "action"
          ? null
          : null, // externo, não é de projecto

      description: _taskDescription,
      deadline: _selectedDate,
      time: DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute),
      frequency: _frequencyEnabled ? [_selectedFrequency] : [],
      completed: 0,
    );

    await ref.read(tasksProvider.notifier).addTask(task);

    if (!mounted) return;
    Navigator.pop(context); // volta à lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Tarefa'),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: defaultPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // título
                      Text(
                        'Lista selecionada:',
                        style: tNormal.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cMainColor,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(widget.selectedList.description, style: tNormal),
                      ),

                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: inputDecoration.copyWith(labelText: 'Descrição'),
                        maxLines: 3,
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Este campo é obrigatório' : null,
                        onChanged: (v) => _taskDescription = v,
                      ),

                      const SizedBox(height: 20),
                      DateOptionSelector(onDateChanged: _onDateChanged),
                      const SizedBox(height: 20),

                      TaskSwitchRow.reminder(
                        enabled: _reminderEnabled,
                        time: _selectedTime,
                        onChanged: (v) => setState(() => _reminderEnabled = v),
                        onTimePicked: _onTimePicked,
                      ),

                      const SizedBox(height: 20),

                      TaskSwitchRow.frequency(
                        enabled: _frequencyEnabled,
                        frequency: _selectedFrequency,
                        onChanged: (v) => setState(() => _frequencyEnabled = v),
                        onFrequencySelected: _onFrequencySelected,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: GestureDetector(
                onTap: _saveTask,
                child: MainButton(buttonText: 'Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
