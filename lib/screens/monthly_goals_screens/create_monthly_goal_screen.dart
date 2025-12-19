import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/models/monthly_goal_model.dart';

import 'package:kwanga/providers/annual_goals_provider.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';

import '../../widgets/feedback_widget.dart';
import '../../widgets/kwanga_dropdown_button.dart';

class CreateMonthlyGoalScreen extends ConsumerStatefulWidget {
  final int? presetMonth;
  final AnnualGoalModel? presetAnnualGoal;
  final MonthlyGoalModel? goalToEdit;

  const CreateMonthlyGoalScreen({
    super.key,
    this.presetMonth,
    this.presetAnnualGoal,
    this.goalToEdit,
  });

  @override
  ConsumerState<CreateMonthlyGoalScreen> createState() =>
      _CreateMonthlyGoalScreenState();
}

class _CreateMonthlyGoalScreenState
    extends ConsumerState<CreateMonthlyGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  int? selectedMonth;
  AnnualGoalModel? selectedAnnualGoal;

  String? annualGoalError;
  String? monthError;

  final descriptionController = TextEditingController();

  bool _isInitialized = false;
  bool get isEditing => widget.goalToEdit != null;

  @override
  void initState() {
    super.initState();

    if (widget.goalToEdit != null) {
      final goal = widget.goalToEdit!;
      descriptionController.text = goal.description;
      selectedMonth = goal.month;
    } else {
      selectedMonth = widget.presetMonth;
      selectedAnnualGoal = widget.presetAnnualGoal;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider).value;
    final annualGoals = ref.watch(annualGoalsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: cMainColor,
        title: Text(
          isEditing ? "Editar Objectivo Mensal" : "Novo Objectivo Mensal",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: annualGoals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erro: $e")),
        data: (annualData) {
          if (auth == null) return const SizedBox();

          if (!_isInitialized && widget.goalToEdit != null) {
            final goal = widget.goalToEdit!;
            selectedAnnualGoal = annualData
                .where((a) => a.id == goal.annualGoalsId)
                .firstOrNull;
            _isInitialized = true;
          }

          final currentYear = DateTime.now().year;
          final availableAnnual =
          annualData.where((a) => a.year == currentYear).toList();

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text("Objectivo Anual ($currentYear)", style: tNormalBold),
                const SizedBox(height: 8),

                KwangaDropdownButton<AnnualGoalModel>(
                  value: selectedAnnualGoal,
                  errorMessage: annualGoalError,
                  items: availableAnnual
                      .map(
                        (a) => DropdownMenuItem(
                      value: a,
                      child: Text(a.description, style: tNormal),
                    ),
                  )
                      .toList(),
                  onChanged: (v) => setState(() {
                    selectedAnnualGoal = v;
                    annualGoalError = null;
                  }),
                  labelText: '',
                  hintText: 'Seleccione o objectivo anual',
                ),

                const SizedBox(height: 24),
                Text("Mês", style: tNormalBold),
                const SizedBox(height: 8),

                KwangaDropdownButton<int>(
                  value: selectedMonth,
                  errorMessage: monthError,
                  items: List.generate(
                    12,
                        (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(_months[i], style: tNormal),
                    ),
                  ),
                  onChanged: (v) => setState(() {
                    selectedMonth = v;
                    monthError = null;
                  }),
                  labelText: '',
                  hintText: 'Seleccione o mês',
                ),

                const SizedBox(height: 24),
                Text("Objectivo", style: tNormalBold),
                const SizedBox(height: 8),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: inputDecoration.copyWith(
                    hintText: "Digite o objectivo mensal...",
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'O objectivo é obrigatório';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: BottomActionBar(
        buttonText: isEditing ? 'Actualizar' : 'Salvar',
        onPressed: _handleSave,
      ),
    );
  }

  // ------------------------------------------------------------------

  Future<void> _handleSave() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (selectedAnnualGoal == null) {
      setState(() => annualGoalError = 'Seleccione o objectivo anual');
    }

    if (selectedMonth == null) {
      setState(() => monthError = 'Seleccione o mês');
    }

    if (!isValid ||
        selectedAnnualGoal == null ||
        selectedMonth == null) {
      return;
    }

    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    final notifier = ref.read(monthlyGoalsProvider.notifier);

    if (isEditing) {
      final updated = widget.goalToEdit!.copyWith(
        description: descriptionController.text.trim(),
        month: selectedMonth!,
        annualGoalsId: selectedAnnualGoal!.id,
      );
      await notifier.editMonthlyGoal(updated);
      showFeedbackScaffoldMessenger(context, "Objectivo actualizado com sucesso");
    } else {
      await notifier.addMonthlyGoal(
        userId: auth.id!,
        annualGoalsId: selectedAnnualGoal!.id,
        description: descriptionController.text.trim(),
        month: selectedMonth!,
      );
      showFeedbackScaffoldMessenger(context, "Objectivo adicionado com sucesso");
    }

    if (mounted) Navigator.pop(context);
  }

  TextStyle get tNormalBold =>
      tNormal.copyWith(fontWeight: FontWeight.bold);
}

const _months = [
  "Janeiro","Fevereiro","Março","Abril","Maio","Junho",
  "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"
];
