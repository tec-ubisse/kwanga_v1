import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/life_areas.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/purpose_model.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

class EditPurpose extends StatefulWidget {
  final Purpose purpose;

  const EditPurpose({super.key, required this.purpose});

  @override
  State<EditPurpose> createState() => _EditPurposeState();
}

class _EditPurposeState extends State<EditPurpose> {
  late TextEditingController _textEditingController;
  late LifeArea? _lifeArea;
  late String _enteredDescription;

  @override
  void initState() {
    super.initState();
    _enteredDescription = widget.purpose.description;
    _lifeArea = widget.purpose.lifeArea;
    _textEditingController = TextEditingController(text: _enteredDescription);
  }

  void _save() {
    if (_enteredDescription.isNotEmpty && _lifeArea != null) {
      Navigator.pop(context, Purpose(_enteredDescription, _lifeArea!, 1));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A descrição e a área da vida não podem estar vazias'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cWhiteColor,
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(
          'Editar propósito',
          style: tTitle.copyWith(fontWeight: FontWeight.w400),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _textEditingController,
              onChanged: (value) => _enteredDescription = value,
              keyboardType: TextInputType.text,
              maxLines: 5,
              decoration: inputDecoration.copyWith(
                hintText: 'Descreva o propósito...',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<LifeArea>(
              elevation: 16,
              style: tNormal,
              isExpanded: true,
              hint: const Text('Selecione a área da vida'),
              value: _lifeArea,
              items: initialLifeAreas.map((area) {
                return DropdownMenuItem<LifeArea>(
                  value: area,
                  child: Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/${area.iconPath}.png',
                          width: 24.0,
                        ),
                        const SizedBox(width: 6),
                        Text(area.designation),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (selectedArea) {
                setState(() {
                  _lifeArea = selectedArea;
                });
              },
            ),
            const Spacer(),
            GestureDetector(
              onTap: _save,
              child: const MainButton(buttonText: 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
