import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/widgets/kwanga_dropdown_button.dart';
import '../../models/vision_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/visions_provider.dart';
import '../../providers/life_area_provider.dart';

class CreateVision extends ConsumerStatefulWidget {
  final String? lifeAreaId;          // 🔥 Agora opcional
  final VisionModel? visionToEdit;

  const CreateVision({super.key, this.lifeAreaId, this.visionToEdit});

  @override
  ConsumerState<CreateVision> createState() => _CreateVisionState();
}

class _CreateVisionState extends ConsumerState<CreateVision> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  late int selectedYear;
  String? selectedLifeAreaId;

  @override
  void initState() {
    super.initState();

    if (widget.visionToEdit != null) {
      _descriptionController.text = widget.visionToEdit!.description;
      selectedYear = widget.visionToEdit!.conclusion;
      selectedLifeAreaId = widget.visionToEdit!.lifeAreaId;
    } else {
      selectedYear = DateTime.now().year + 3;
      selectedLifeAreaId = widget.lifeAreaId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lifeAreasAsync = ref.watch(lifeAreasProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;

    final years = [
      DateTime.now().year + 3,
      DateTime.now().year + 4,
      DateTime.now().year + 5,
    ];

    return lifeAreasAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(body: Center(child: Text("Erro: $e"))),

      data: (lifeAreas) {
        if (selectedLifeAreaId == null && widget.visionToEdit == null) {
          selectedLifeAreaId = lifeAreas.first.id;
        }

        final selectedArea = lifeAreas.firstWhere(
              (a) => a.id == selectedLifeAreaId,
          orElse: () => lifeAreas.first,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.visionToEdit == null ? "Nova Visão" : "Editar Visão",
            ),
            backgroundColor: cMainColor,
            foregroundColor: cWhiteColor,
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: defaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.lifeAreaId == null && widget.visionToEdit == null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Seleccione a área da vida",
                              style: tSmallTitle.copyWith(fontSize: 16)),

                          const SizedBox(height: 12),

                          KwangaDropdownButton<String>(
                            value: selectedLifeAreaId!,
                            items: lifeAreas
                                .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.designation),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => selectedLifeAreaId = value);
                            },
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),

                    Text(
                      "Descrição da visão",
                      style: tSmallTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black26),
                      ),
                      height: 140,
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 6,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Por favor escreva a visão.";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: "Escreva a sua visão de longo prazo",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      "Ano de Conclusão",
                      style: tSmallTitle.copyWith(fontSize: 16),
                    ),
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
                                color: isSelected ? cSecondaryColor : Colors.white,
                                border: Border.all(
                                  color:
                                  isSelected ? cSecondaryColor : Colors.black26,
                                ),
                              ),
                              child: Text(
                                year.toString(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
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

          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFEFEFEF),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (user == null || user.id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Erro: nenhum utilizador autenticado.")),
                    );
                    return;
                  }

                  if (selectedLifeAreaId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Seleccione uma área da vida.")),
                    );
                    return;
                  }

                  if (_formKey.currentState!.validate()) {
                    if (widget.visionToEdit == null) {
                      // NOVA VISÃO
                      await ref.read(visionsProvider.notifier).addVision(
                        userId: user.id!,
                        lifeAreaId: selectedLifeAreaId!,
                        description: _descriptionController.text.trim(),
                        conclusion: selectedYear,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Visão adicionada com sucesso!")),
                      );
                    } else {
                      // EDITAR VISÃO
                      final updated = widget.visionToEdit!.copyWith(
                        description: _descriptionController.text.trim(),
                        conclusion: selectedYear,
                      );

                      await ref.read(visionsProvider.notifier).editVision(updated);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Visão actualizada com sucesso!")),
                      );
                    }

                    ref.invalidate(visionsProvider);
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Salvar",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

