import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/screens/task_screens/list_task_screen.dart';
import 'package:kwanga/screens/task_screens/task_trailing_screen.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

class UpdateTaskScreen extends StatefulWidget {
  final TaskModel task;

  const UpdateTaskScreen({super.key, required this.task});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final ListDao _listDao = ListDao();
  final TaskDao _taskDao = TaskDao();
  late Future<List<ListModel>> _listsFuture;
  ListModel? _selectedList;
  String _taskDescription = '';
  String _selectedOption = 'Sem Data';
  DateTime? _selectedDate;
  final List<String> _options = ['Sem Data', 'Hoje', 'Amanhã'];
  bool _reminderEnabled = false;
  bool _frequencyEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedFrequency = 'Todos os dias';
  int _completed = 0;

  void loadLists() {
    setState(() {
      _listsFuture = _listDao.getAll();
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize fields from the received task
    _taskDescription = widget.task.description;
    _completed = widget.task.completed;
    _selectedDate = widget.task.deadline;
    _selectedOption = _inferOptionFromDate(widget.task.deadline);
    if (widget.task.time != null) {
      _reminderEnabled = true;
      _selectedTime = TimeOfDay(
        hour: widget.task.time!.hour,
        minute: widget.task.time!.minute,
      );
    } else {
      _reminderEnabled = false;
    }
    if (widget.task.frequency != null && widget.task.frequency!.isNotEmpty) {
      _frequencyEnabled = true;
      _selectedFrequency = widget.task.frequency!.first;
    } else {
      _frequencyEnabled = false;
      _selectedFrequency = 'Todos os dias';
    }

    loadLists();
  }

  String _inferOptionFromDate(DateTime? date) {
    if (date == null) return 'Sem Data';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cmp = DateTime(date.year, date.month, date.day);
    if (cmp == today) return 'Hoje';
    if (cmp == today.add(const Duration(days: 1))) return 'Amanhã';
    return 'Data específica';
  }

  void _onOptionChanged(String option) {
    setState(() {
      _selectedOption = option;
      if (option == 'Sem Data') {
        _selectedDate = null;
      } else if (option == 'Hoje') {
        final now = DateTime.now();
        _selectedDate = DateTime(now.year, now.month, now.day);
      } else if (option == 'Amanhã') {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        _selectedDate = today.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initial = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedOption = _inferOptionFromDate(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _selectFrequency(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final options = ['Todos os dias', 'Dias úteis', 'Fins de semana'];
        return ListView(
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              onTap: () {
                setState(() {
                  _selectedFrequency = option;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedList == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecione uma lista.')));
        return;
      }

      final now = DateTime.now();
      final DateTime? timeDateTime = _reminderEnabled
          ? DateTime(
              now.year,
              now.month,
              now.day,
              _selectedTime.hour,
              _selectedTime.minute,
            )
          : null;

      final updated = TaskModel(
        id: widget.task.id,
        userId: widget.task.userId,
        listId: _selectedList!.id,
        description: _taskDescription,
        listType: _selectedList!.description,
        deadline: _selectedDate,
        time: timeDateTime,
        frequency: _frequencyEnabled
            ? <String>[_selectedFrequency]
            : <String>[],
        completed: _completed,
      );

      await _taskDao.updateTask(updated);
      // if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: const Text('Atualizar Tarefa'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: defaultPadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: FutureBuilder<List<ListModel>>(
                      future: _listsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erro ao carregar listas: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        final lists = snapshot.data ?? <ListModel>[];
                        if (lists.isEmpty) {
                          return const Center(
                            child: Text('Nenhuma lista encontrada.'),
                          );
                        }

                        _selectedList ??= lists.firstWhere(
                          (l) => l.id == widget.task.listId,
                          orElse: () => lists.first,
                        );

                        return Form(
                          key: _formKey,
                          child: Column(
                            spacing: 12.0,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Selecione uma lista:', style: tNormal),
                              DropdownButtonFormField<ListModel>(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                isExpanded: true,
                                hint: Text('Escolha uma lista', style: tNormal),
                                value: _selectedList,
                                // <== valor é ListModel
                                items: lists.map((list) {
                                  return DropdownMenuItem<ListModel>(
                                    value: list,
                                    child: Text(
                                      list.description,
                                      style: tNormal,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedList = value;
                                  });
                                },
                              ),

                              Text('Descrição', style: tNormal),
                              TextFormField(
                                initialValue: _taskDescription,
                                decoration: InputDecoration(
                                  hintText: 'Descreva a tarefa',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe a descrição';
                                  }
                                  return null;
                                },
                                onChanged: (value) => _taskDescription = value,
                              ),

                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800.withAlpha(10),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: _options.map((option) {
                                          final bool isSelected =
                                              _selectedOption == option;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Switch(
                                                      value: isSelected,
                                                      onChanged: (_) =>
                                                          _onOptionChanged(
                                                            option,
                                                          ),
                                                      activeThumbColor:
                                                          Colors.blue.shade700,
                                                      activeTrackColor:
                                                          Colors.blue.shade100,
                                                      inactiveThumbColor:
                                                          Colors.grey.shade300,
                                                      inactiveTrackColor:
                                                          Colors.grey.shade200,
                                                      splashRadius: 0,
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      option,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: isSelected
                                                            ? Colors.black
                                                            : Colors
                                                                  .grey
                                                                  .shade700,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Text('')),
                                ],
                              ),

                              ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: const Text('Selecione a Data'),
                              ),

                              Column(
                                children: [
                                  _buildRow(
                                    label: 'Lembrete',
                                    value: _reminderEnabled,
                                    onChanged: (val) =>
                                        setState(() => _reminderEnabled = val),
                                    trailing: InkWell(
                                      onTap: _reminderEnabled
                                          ? () => _selectTime(context)
                                          : null,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.alarm,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatTimeOfDay(_selectedTime),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildRow(
                                    label: 'Frequência',
                                    value: _frequencyEnabled,
                                    onChanged: (val) =>
                                        setState(() => _frequencyEnabled = val),
                                    trailing: InkWell(
                                      onTap: _frequencyEnabled
                                          ? () => _selectFrequency(context)
                                          : null,
                                      child: Row(
                                        children: [
                                          Text(
                                            _selectedFrequency,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SwitchListTile(
                                title: const Text('Tarefa concluída?'),
                                value: _completed == 1,
                                onChanged: (val) =>
                                    setState(() => _completed = val ? 1 : 0),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 24.0,
              ),
              child: GestureDetector(
                onTap: () async {
                  await _updateTask();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => TaskTrailingScreen()),
                  );
                },
                child: MainButton(buttonText: 'Salvar Alterações'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue.shade700,
            activeTrackColor: Colors.blue.shade100,
            inactiveThumbColor: Colors.grey.shade300,
            inactiveTrackColor: Colors.grey.shade200,
            splashRadius: 0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
