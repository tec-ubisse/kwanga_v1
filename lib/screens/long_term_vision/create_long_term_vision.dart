import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/long_term_vision_model.dart';
import 'package:kwanga/models/user.dart';
import 'package:kwanga/screens/long_term_vision/read_long_term_visions_screen.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import '../../data/database/long_term_vision_dao.dart';

class CreateLongTermVision extends StatefulWidget {
  final LifeArea selectedArea;

  const CreateLongTermVision({super.key, required this.selectedArea});

  @override
  State<CreateLongTermVision> createState() => _CreateLongTermVisionState();
}

class _CreateLongTermVisionState extends State<CreateLongTermVision> {
  final _formKey = GlobalKey<FormState>();
  final LongTermVisionDao _longTermVisionDao = LongTermVisionDao();
  final TextEditingController _visionController = TextEditingController();

  DateTime currentDate = DateTime.now();
  late int currentYear;
  late List<int> _deadlines;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    currentYear = currentDate.year;
    _deadlines = [currentYear + 3, currentYear + 4, currentYear + 5];
    selectedYear = _deadlines.first;
  }

  Future<void> _saveVision() async {
    if (_visionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreva a visão')),
      );
      return;
    }

    final newVision = LongTermVision(
      User('1', 'alberto@gmail.com', 'tech@123'),
      widget.selectedArea,
      _visionController.text.trim(),
      selectedYear.toString(), // convertido para string
      '0',
    );

    await _longTermVisionDao.insert(newVision);

    // Redirecionar para a tela de visões
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => const LongTermVisionsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: const Text('Nova Visão'),
      ),
      body: Padding(
        padding: defaultPadding,
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 12.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Área da Vida', style: tSmallTitle.copyWith(color: cMainColor)),

              // Área selecionada
              Container(
                decoration: BoxDecoration(
                  color: cWhiteColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  spacing: 12.0,
                  children: [
                    Image.asset(
                      'assets/icons/${widget.selectedArea.iconPath}.png',
                      width: 32.0,
                    ),
                    Text(widget.selectedArea.designation,
                        style: tNormal.copyWith(fontSize: 24.0)),
                  ],
                ),
              ),

              const SizedBox(height: 32.0),

              // Campo da visão
              Text('Visão de Longo Prazo',
                  style: tSmallTitle.copyWith(color: cMainColor)),
              TextFormField(
                controller: _visionController,
                maxLines: 5,
                decoration: inputDecoration.copyWith(
                  hintText: 'Escreva a sua visão de longo prazo',
                ),
              ),

              const SizedBox(height: 20),

              // Ano de conclusão
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ano de Conclusão',
                        style: tSmallTitle.copyWith(color: cMainColor),
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<int>(
                        value: selectedYear,
                        isExpanded: true,
                        elevation: 16,
                        style: tNormal,
                        items: _deadlines
                            .map((year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        ))
                            .toList(),
                        onChanged: (newYear) {
                          if (newYear != null) {
                            setState(() => selectedYear = newYear);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: _saveVision,
                child: const MainButton(buttonText: 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
