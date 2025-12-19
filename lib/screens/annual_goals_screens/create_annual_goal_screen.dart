import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/models/vision_model.dart';

import 'package:kwanga/providers/annual_goals_provider.dart';
import 'package:kwanga/providers/visions_provider.dart';
import 'package:kwanga/providers/life_area_provider.dart';

import 'package:kwanga/widgets/feedback_widget.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import '../../widgets/kwanga_dropdown_button.dart';

import 'create_annual_goal_widgets/description_field.dart';
import 'create_annual_goal_widgets/year_dropdown.dart';

import '../../utils/form_validators.dart';

class CreateAnnualGoalScreen extends ConsumerStatefulWidget {
  final String? visionId;
  final AnnualGoalModel? annualGoalToEdit;
  final int? preselectedYear;
  final String? lifeAreaId;
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
  final _description = TextEditingController();

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

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    final visions =
        ref.read(visionsProvider).asData?.value ?? <VisionModel>[];

    final vision =
    visions.firstWhere((v) => v.id == _selectedVisionId);

    final desc = _description.text.trim();

    if (isEditing) {
      final updated = widget.annualGoalToEdit!.copyWith(
        visionId: _selectedVisionId!,
        year: _selectedYear!,
        description: desc,
        isSynced: false,
      );

      await ref
          .read(annualGoalsProvider.notifier)
          .editAnnualGoal(updated);

      showFeedbackScaffoldMessenger(
        context,
        "Objectivo actualizado com sucesso",
      );
    } else {
      await ref
          .read(annualGoalsProvider.notifier)
          .addAnnualGoal(
        userId: vision.userId,
        visionId: _selectedVisionId!,
        description: desc,
        year: _selectedYear!,
      );

      showFeedbackScaffoldMessenger(
        context,
        "Objectivo adicionado com sucesso",
      );
    }

    ref.invalidate(annualGoalsProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final visionsAsync = ref.watch(visionsProvider);
    ref.watch(lifeAreasProvider); // mantém dependência viva

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? "Editar objectivo anual"
              : "Criar objectivo anual",
        ),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),

      bottomNavigationBar: BottomActionBar(
        buttonText:
        isEditing ? "Actualizar" : "Criar objectivo anual",
        onPressed: _save,
      ),

      body: visionsAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text("Erro ao carregar visões: $e")),
        data: (visions) {
          List<VisionModel> filteredVisions;

          if (widget.lifeAreaId != null) {
            filteredVisions = visions
                .where((v) => v.lifeAreaId == widget.lifeAreaId)
                .toList();

            if (_selectedVisionId == null &&
                filteredVisions.length == 1) {
              _selectedVisionId = filteredVisions.first.id;
            }
          } else {
            filteredVisions = visions;
          }

          VisionModel? lockedVision;
          if (_selectedVisionId != null) {
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

                  Text("Visão", style: tSmallTitle),
                  const SizedBox(height: 8),

                  FormField<String>(
                    initialValue: _selectedVisionId,
                    validator: (v) =>
                        FormValidators.requiredSelection(
                          v,
                          message: 'Selecione uma visão',
                        ),
                    builder: (state) {
                      return KwangaDropdownButton<String>(
                        value: _selectedVisionId,
                        items: filteredVisions
                            .map(
                              (v) => DropdownMenuItem<String>(
                            value: v.id,
                            child: Text(v.description),
                          ),
                        )
                            .toList(),
                        onChanged: (v) {
                          setState(() =>
                          _selectedVisionId = v);
                          state.didChange(v);
                        },
                        labelText: '',
                        hintText: 'Selecione uma visão',
                        errorMessage: state.errorText,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Text("Ano", style: tSmallTitle),
                  const SizedBox(height: 8),

                  FormField<int>(
                    initialValue: _selectedYear,
                    validator: (v) =>
                        FormValidators.requiredSelection(
                          v,
                          message: 'Selecione o ano',
                        ),
                    builder: (state) {
                      return YearDropdown(
                        lockedVision: lockedVision,
                        selectedYear: _selectedYear,
                        onChanged: widget.lockYear
                            ? null
                            : (v) {
                          setState(() =>
                          _selectedYear = v);
                          state.didChange(v);
                        },
                        errorMessage: state.errorText,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Descrição do objectivo",
                    style: tSmallTitle,
                  ),
                  const SizedBox(height: 8),

                  DescriptionField(
                    controller: _description,
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
