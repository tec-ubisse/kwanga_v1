import 'package:flutter/material.dart';
import 'package:kwanga/data/life_areas.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/purpose_model.dart';
import 'package:kwanga/screens/purpose_screens/read_purposes.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import '../../data/database/purpose_dao.dart';

class CreatePurpose extends StatefulWidget {
  const CreatePurpose({super.key});

  @override
  State<CreatePurpose> createState() => _CreatePurposeState();
}

class _CreatePurposeState extends State<CreatePurpose> {
  // Inserted data by user
  String _enteredDescription = '';
  LifeArea? _selectedLifeArea;

  final TextEditingController _textEditingController = TextEditingController();
  final PurposeDao _purposeDao = PurposeDao();

  Future<void> _savePurpose() async {
    if (_enteredDescription.isEmpty || _selectedLifeArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final newPurpose = Purpose(
      _enteredDescription,
      _selectedLifeArea!,1
    );

    await _purposeDao.insert(newPurpose);

    // Save and return to display List
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => const ReadPurposes()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cWhiteColor,
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(
          'Criar novo propósito',
          style: tTitle.copyWith(fontWeight: FontWeight.w400),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _textEditingController,
                        onChanged: (value) {
                          setState(() {
                            _enteredDescription = value;
                          });
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        decoration: inputDecoration.copyWith(
                          hintText: 'Descreva o seu propósito...',
                        ),
                      ),
                      DropdownButton<LifeArea>(
                        elevation: 16,
                        style: tNormal,
                        isExpanded: true,
                        hint: const Text('Selecione a área da vida'),
                        value: _selectedLifeArea,
                        items: initialLifeAreas.map((area) {
                          return DropdownMenuItem<LifeArea>(
                            value: area,
                            child: Row(
                              spacing: 4.0,
                              children: [
                                Image.asset(
                                  'assets/icons/${area.iconPath}.png',
                                  width: 24.0,
                                ),
                                Text(area.designation),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (selectedArea) {
                          setState(() {
                            _selectedLifeArea = selectedArea;
                          });
                        },
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _savePurpose,
                        child: const MainButton(buttonText: 'Salvar'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
