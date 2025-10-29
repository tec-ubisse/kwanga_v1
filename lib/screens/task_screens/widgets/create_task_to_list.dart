import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/screens/task_screens/list_task_screen.dart';
import 'package:kwanga/screens/task_screens/task_trailing_screen.dart';
import 'package:kwanga/screens/task_screens/widgets/date_option_selector.dart';
import 'package:kwanga/screens/task_screens/widgets/task_switch_row.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

class CreateTaskToList extends StatefulWidget {
  final ListModel selectedList;

  const CreateTaskToList({super.key, required this.selectedList});

  @override
  State<CreateTaskToList> createState() => _CreateTaskToListState();
}

class _CreateTaskToListState extends State<CreateTaskToList> {
  final _formKey = GlobalKey<FormState>();
  final _listDao = ListDao();
  final _taskDao = TaskDao();
  final _userModel = UserModel(
    id: 2025,
    email: 'alberto.ubisse@techworks.com',
    password: 'tech@123',
  );

  late Future<List<ListModel>> _listsFuture;
  String _taskDescription = '';
  DateTime? _selectedDate;
  ListModel? _selectedList;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedFrequency = 'Todos os dias';
  bool _reminderEnabled = false;
  bool _frequencyEnabled = false;

  @override
  void initState() {
    super.initState();
    _listsFuture = _listDao.getAll();
    _selectedList = widget.selectedList;
  }

  void _onDateChanged(DateTime? date) => setState(() => _selectedDate = date);

  void _onTimePicked(TimeOfDay time) => setState(() => _selectedTime = time);

  void _onFrequencySelected(String freq) =>
      setState(() => _selectedFrequency = freq);

  Future<void> saveTask() async {
    if (!_formKey.currentState!.validate() || _selectedList == null) return;

    final now = DateTime.now();
    final task = TaskModel(
      description: _taskDescription,
      listType: _selectedList!.description,
      listId: _selectedList!.id,
      deadline: _selectedDate,
      frequency: [],
      userId: _userModel.id!,
      time: DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      completed: 0,
    );

    await _taskDao.insert(task);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ListTasksScreen(listModel: widget.selectedList)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Tarefa'),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: defaultPadding,
                child: FutureBuilder<List<ListModel>>(
                  future: _listsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    final lists = snapshot.data ?? [];

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            child: Text(
                              widget.selectedList.description,
                              style: tNormal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: inputDecoration.copyWith(
                              labelText: 'Descrição',
                            ),
                            maxLines: 3,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Descreva a tarefa'
                                : null,
                            onChanged: (v) => _taskDescription = v,
                          ),
                          const SizedBox(height: 12),
                          DateOptionSelector(onDateChanged: _onDateChanged),
                          const SizedBox(height: 12),
                          TaskSwitchRow.reminder(
                            enabled: _reminderEnabled,
                            time: _selectedTime,
                            onChanged: (v) =>
                                setState(() => _reminderEnabled = v),
                            onTimePicked: _onTimePicked,
                          ),
                          const SizedBox(height: 12),
                          TaskSwitchRow.frequency(
                            enabled: _frequencyEnabled,
                            frequency: _selectedFrequency,
                            onChanged: (v) =>
                                setState(() => _frequencyEnabled = v),
                            onFrequencySelected: _onFrequencySelected,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: saveTask,
              child: MainButton(buttonText: 'Salvar'),
            ),
          ),
        ],
      ),
    );
  }
}
