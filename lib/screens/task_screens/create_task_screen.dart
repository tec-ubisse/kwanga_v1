import 'package:flutter/material.dart';
import 'package:kwanga/data/database/task_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/models/task_model.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/screens/lists_screens/create_lists_screen.dart';
import 'package:kwanga/screens/task_screens/task_screen.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import '../../custom_themes/blue_accent_theme.dart';
import '../../custom_themes/text_style.dart';
import '../../data/database/list_dao.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final ListDao _listDao = ListDao();
  late Future<List<ListModel>> _listsFuture;
  final _formKey = GlobalKey<FormState>();
  String _taskDescription = '';
  String _selectedOption = 'Sem Data';
  DateTime? _selectedDate;
  final List<String> _options = ['Sem Data', 'Hoje', 'Amanhã'];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _reminderEnabled = false;
  bool _frequencyEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedFrequency = 'Todos os dias';
  String? _selectedListType;
  String? _listDescription;
  final UserModel _userModel = UserModel(
    id: 2025,
    email: 'alberto.ubisse@techworks.com',
    password: 'tech@123',
  );
  TaskDao _taskDao = TaskDao();

  void _onOptionChanged(String option) async {
    setState(() {
      _selectedOption = option;
      _selectedDate = null;
      updateSelectedDate(option);
      print(_selectedDate);
    });
  }

  void updateSelectedDate(String newOption) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    switch (newOption) {
      case 'Sem data':
        _selectedDate = null;
        break;

      case 'Hoje':
        _selectedDate = today;
        break;

      case 'Amanhã':
        _selectedDate = today.add(const Duration(days: 1));
        break;

      case 'Data específica':
        break;

      default:
        _selectedDate = null;
        break;
    }
  }

  void saveTask() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final newTask = TaskModel(
        description: _taskDescription,
        listType: _selectedList!.description,
        listId: _selectedList!.id,
        deadline: _selectedDate,
        frequency: [],
        userId: _userModel.id!,
        time: _selectedTime == null
            ? null
            : DateTime(
          now.year,
          now.month,
          now.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
      );
      await _taskDao.insert(newTask);

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (ctx) => TaskScreen()));
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = _selectedTime ?? TimeOfDay.now();
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

  Widget _buildRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.blueAccent,
          ),
          Text(
            label,
            style: TextStyle(
              color: value ? Colors.black : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: value ? 1 : 0.4,
            child: trailing,
          ),
        ],
      ),
    );
  }

  ListModel? _selectedList;

  void loadLists() {
    setState(() {
      _listsFuture = _listDao.getAll();
    });
  }

  @override
  void initState() {
    super.initState();
    loadLists();
  }

  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = selectedDate ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      print("Data selecionada: $selectedDate");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: const Text('Adicionar Tarefa'),
      ),
      body: Padding(
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
                  'Erro ao carregar listas: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nenhuma lista encontrada.'),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (ctx) => CreateListsScreen()));
                    },
                    child: MainButton(buttonText: 'Criar Lista de Tarefas'),
                  ),
                ],
              );
            }

            final lists = snapshot.data!;

            return Form(
              key: _formKey,
              child: Column(
                spacing: 12.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Descrição', style: tNormal),
                  TextFormField(
                    decoration: inputDecoration,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deve conter a descrição da lista';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _taskDescription = value;
                    },
                  ),
                  Text('Selecione uma lista:', style: tNormal),
                  DropdownButtonFormField<ListModel>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    isExpanded: true,
                    hint: Text('Escolha uma lista', style: tNormal),
                    initialValue: _selectedList,
                    items: lists.map((list) {
                      return DropdownMenuItem<ListModel>(
                        value: list,
                        child: Text(list.description, style: tNormal),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedList = value;
                      });
                    },
                  ),
                  // Sem Data, Hoje ou Amanhã
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                          onChanged: (_) {
                                            _onOptionChanged(option);
                                          }
                                              ,
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
                                                : Colors.grey.shade700,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
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
                      Expanded(child: Text('')),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Selecione a Data'),
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
                                _selectedTime.format(context),
                                style: const TextStyle(fontSize: 16),
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
                                style: const TextStyle(fontSize: 16),
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
                  const Spacer(),
                  GestureDetector(
                    onTap: saveTask,
                    child: MainButton(buttonText: 'Salvar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
