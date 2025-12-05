import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/models/vision_model.dart';
import 'package:kwanga/providers/annual_goals_provider.dart';
import 'package:kwanga/providers/visions_provider.dart';
import 'package:kwanga/providers/life_area_provider.dart';

import 'create_annual_goal_widgets/description_field.dart';
import 'create_annual_goal_widgets/vision_card.dart';
import 'create_annual_goal_widgets/year_dropdown.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';

import '../annual_goals_screens/widgets/vision_selector.dart';

class CreateAnnualGoalScreen extends ConsumerStatefulWidget {
  final String? visionId;
  final AnnualGoalModel? annualGoalToEdit;
  final int? preselectedYear;
  final String? lifeAreaId;

  /// Novo parâmetro para bloquear o ano
  final bool lockYear;

  const CreateAnnualGoalScreen({
    super.key,
    this.visionId,
    this.preselectedYear,
    this.annualGoalToEdit,
    this.lifeAreaId,
    this.lockYear = false,
  });

  @override
  ConsumerState<CreateAnnualGoalScreen> createState() =>
      _CreateAnnualGoalScreenState();
}

class _CreateAnnualGoalScreenState
    extends ConsumerState<CreateAnnualGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _description = TextEditingController();

  String? _selectedVisionId;
  int? _selectedYear;

  bool get isEditing => widget.annualGoalToEdit != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final g = widget.annualGoalToEdit!;
      _selectedVisionId = g.visionId;
      _selectedYear = g.year;
      _description.text = g.description;
    } else {
      _selectedVisionId = widget.visionId;
      _selectedYear = widget.preselectedYear;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVisionId == null) return _snack("Selecione uma visão");
    if (_selectedYear == null) return _snack("Selecione o ano");

    final visions =
        ref.read(visionsProvider).asData?.value ?? <VisionModel>[];

    final vision = visions.firstWhere(
          (v) => v.id == _selectedVisionId,
      orElse: () => throw ("Visão não encontrada."),
    );

    if (vision.userId == null) return _snack("Utilizador não encontrado.");

    final desc = _description.text.trim();

    if (isEditing) {
      final updated = widget.annualGoalToEdit!.copyWith(
        visionId: _selectedVisionId!,
        year: _selectedYear!,
        description: desc,
        isSynced: false,
      );

      await ref.read(annualGoalsProvider.notifier).editAnnualGoal(updated);
    } else {
      await ref.read(annualGoalsProvider.notifier).addAnnualGoal(
        userId: vision.userId!,
        visionId: _selectedVisionId!,
        description: desc,
        year: _selectedYear!,
      );
    }

    ref.invalidate(annualGoalsProvider);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final visionsAsync = ref.watch(visionsProvider);
    final lifeAreasAsync = ref.watch(lifeAreasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? "Editar objectivo anual" : "Criar objectivo anual",
        ),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),

      bottomNavigationBar: BottomActionBar(
        buttonText: isEditing ? "Guardar alterações" : "Criar objectivo anual",
        onPressed: _save,
      ),

      body: visionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erro ao carregar visões: $e")),
        data: (visions) {
          // Filtrar quando lifeAreaId vier preenchido
          List<VisionModel> filteredVisions;

          if (widget.lifeAreaId != null) {
            filteredVisions = visions
                .where((v) => v.lifeAreaId == widget.lifeAreaId)
                .toList();

            if (_selectedVisionId == null && filteredVisions.length == 1) {
              _selectedVisionId = filteredVisions.first.id;
            }
          } else {
            filteredVisions = visions;
          }

          // Visão bloqueada (edição ou pré-selecionada via NoGoalCard)
          VisionModel? lockedVision;
          if (_selectedVisionId != null && filteredVisions.isNotEmpty) {
            lockedVision = filteredVisions
                .where((v) => v.id == _selectedVisionId)
                .firstOrNull;
          }

          return Padding(
            padding: defaultPadding,
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  Text("Visão", style: tNormal),
                  const SizedBox(height: 8),

                  /// 🔥 Se a visão está bloqueada → mostrar cartão fixo
                  if (lockedVision != null) ...[
                    VisionCard(
                      vision: lockedVision,
                      lifeAreasAsync: lifeAreasAsync,
                    ),
                  ]
                  /// 🔥 Caso contrário → deixar o usuário escolher a visão
                  else ...[
                    VisionSelector(
                      visions: filteredVisions,
                      selectedVisionId: _selectedVisionId,
                      onChanged: (v) => setState(() => _selectedVisionId = v),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Text("Ano", style: tNormal),
                  const SizedBox(height: 6),

                  YearDropdown(
                    lockedVision: lockedVision,
                    selectedYear: _selectedYear,
                    onChanged: widget.lockYear
                        ? null
                        : (v) => setState(() => _selectedYear = v),
                  ),

                  const SizedBox(height: 20),
                  Text("Descrição do objectivo", style: tNormal),
                  const SizedBox(height: 6),

                  DescriptionField(controller: _description),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
