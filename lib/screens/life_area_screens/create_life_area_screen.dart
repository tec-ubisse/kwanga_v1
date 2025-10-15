import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/data/life_areas.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/screens/life_area_screens/read_life_areas_screen.dart';
import '../../custom_themes/text_style.dart';
import '../../widgets/buttons/main_button.dart';

class CreateLifeAreaScreen extends StatefulWidget {
  const CreateLifeAreaScreen({super.key});

  @override
  State<CreateLifeAreaScreen> createState() => _CreateLifeAreaScreenState();
}

class _CreateLifeAreaScreenState extends State<CreateLifeAreaScreen> {
  TextEditingController? _textEditingController;
  String _enteredDescription = '';
  int? _selectedIconIndex;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: const Text('Nova Área da Vida'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digite a área da vida',
                        style: tTitle.copyWith(color: cMainColor),
                      ),
                      TextFormField(
                        controller: _textEditingController,
                        onChanged: (value) {
                          _enteredDescription = value;
                        },
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration.copyWith(
                          hintText: 'Nova área da vida',
                          hintStyle:
                          tNormal.copyWith(color: cBlackColor.withOpacity(0.5)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selecione o ícone',
                        style: tTitle.copyWith(color: cMainColor),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 480.0,
                        child: GridView.builder(
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: initialLifeAreas.length,
                          itemBuilder: (BuildContext context, int index) {
                            final area = initialLifeAreas[index];
                            final isSelected = _selectedIconIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedIconIndex = index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? cSecondaryColor.withAlpha(40)
                                      : cBlackColor.withAlpha(10),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: isSelected
                                      ? Border.all(color: cSecondaryColor, width: 1)
                                      : null,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/${area.iconPath}.png',
                                    width: 40.0,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (_enteredDescription.isEmpty ||
                              _selectedIconIndex == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Digite a área da vida e selecione um ícone',
                                ),
                              ),
                            );
                            return;
                          }

                          // Criar novo objeto LifeArea
                          final newLifeArea = LifeArea(
                            _enteredDescription,
                            initialLifeAreas[_selectedIconIndex!].iconPath,
                            1
                          );

                          // Add new Life Area
                          initialLifeAreas.add(newLifeArea);

                          // Navigate to LifeAreas page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  ReadLifeAreasScreen(lifeAreas: initialLifeAreas),
                            ),
                          );
                        },
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
