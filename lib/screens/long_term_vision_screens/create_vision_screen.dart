import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/widgets/kwanga_dropdown_button.dart';

import '../../models/vision_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/visions_provider.dart';
import '../../providers/life_area_provider.dart';
import '../../widgets/buttons/bottom_action_bar.dart';
import '../../widgets/feedback_widget.dart';

class CreateVision extends ConsumerStatefulWidget {
  final String? lifeAreaId;
  final VisionModel? visionToEdit;

  const CreateVision({super.key, this.lifeAreaId, this.visionToEdit});

  @override
  ConsumerState<CreateVision> createState() => _CreateVisionState();
}

class _CreateVisionState extends ConsumerState<CreateVision> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? selectedLifeAreaId;
  String? lifeAreaError;
  late int selectedYear;

  bool get isEditing => widget.visionToEdit != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final v = widget.visionToEdit!;
      _descriptionController.text = v.description;
      selectedYear = v.conclusion;
      selectedLifeAreaId = v.lifeAreaId;
    } else {
      selectedYear = DateTime.now().year + 3;
      selectedLifeAreaId = widget.lifeAreaId;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (selectedLifeAreaId == null) {
      setState(() => lifeAreaError = 'Seleccione a área da vida');
    }

    if (!isValid || selectedLifeAreaId == null) return;

    final user = ref.read(authProvider).value;
    if (user?.id == null) return;

    if (isEditing) {
      final updated = widget.visionToEdit!.copyWith(
        description: _descriptionController.text.trim(),
        conclusion: selectedYear,
      );
      await ref.read(visionsProvider.notifier).editVision(updated);
      showFeedbackScaffoldMessenger(context, "Visão actualizada com sucesso");
    } else {
      await ref.read(visionsProvider.notifier).addVision(
        userId: user!.id!,
        lifeAreaId: selectedLifeAreaId!,
        description: _descriptionController.text.trim(),
        conclusion: selectedYear,
      );
      showFeedbackScaffoldMessenger(context, "Visão adicionada com sucesso");
    }

    ref.invalidate(visionsProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lifeAreasAsync = ref.watch(lifeAreasProvider);

    final years = [
      DateTime.now().year + 3,
      DateTime.now().year + 4,
      DateTime.now().year + 5,
    ];

    return lifeAreasAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text("Erro: $e"))),
      data: (lifeAreas) {
        final hasLifeAreas = lifeAreas.isNotEmpty;

        if (selectedLifeAreaId == null && !isEditing && hasLifeAreas) {
          selectedLifeAreaId = lifeAreas.first.id;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? "Editar Visão" : "Nova Visão"),
            backgroundColor: cMainColor,
            foregroundColor: cWhiteColor,
          ),
          backgroundColor: Colors.white,

          bottomNavigationBar: BottomActionBar(
            buttonText: isEditing ? "Actualizar" : "Salvar",
            onPressed: _save,
          ),

          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: defaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- ÁREA DA VIDA --------
                    if (widget.lifeAreaId == null && !isEditing) ...[
                      Text("Seleccione a área da vida",
                          style: tSmallTitle.copyWith(fontSize: 16)),
                      const SizedBox(height: 12),

                      KwangaDropdownButton<String>(
                        value: selectedLifeAreaId,
                        errorMessage: lifeAreaError,
                        disabledMessage: hasLifeAreas
                            ? null
                            : 'Deve criar uma área da vida primeiro',
                        items: lifeAreas
                            .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.designation),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          selectedLifeAreaId = v;
                          lifeAreaError = null;
                        }),
                        labelText: '',
                        hintText: 'Seleccione a área da vida',
                      ),

                      const SizedBox(height: 32),
                    ],

                    // -------- DESCRIÇÃO --------
                    Text("Descrição da visão",
                        style: tSmallTitle.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 6,
                      decoration: inputDecoration.copyWith(
                        hintText: "Escreva a sua visão de longo prazo",
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "A descrição da visão é obrigatória";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // -------- ANO --------
                    Text("Ano de Conclusão",
                        style: tSmallTitle.copyWith(fontSize: 16)),
                    const SizedBox(height: 16),

                    Row(
                      children: years.map((year) {
                        final isSelected = selectedYear == year;

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedYear = year),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 22),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color:
                                isSelected ? cSecondaryColor : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? cSecondaryColor
                                      : Colors.black26,
                                ),
                              ),
                              child: Text(
                                year.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
