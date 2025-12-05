import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/models/monthly_goal_model.dart';

import 'package:kwanga/providers/annual_goals_provider.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/providers/auth_provider.dart';

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
  int? selectedMonth;
  AnnualGoalModel? selectedAnnualGoal;

  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.goalToEdit != null) {
      final goal = widget.goalToEdit!;

      descriptionController.text = goal.description;
      selectedMonth = goal.month;

      // Evita crash — só lê annualGoalsProvider se já tiver valor carregado
      final allAnnual = ref.read(annualGoalsProvider).value;
      if (allAnnual != null) {
        final matches = allAnnual.where((a) => a.id == goal.annualGoalsId);
        selectedAnnualGoal = matches.isNotEmpty ? matches.first : null;
      }
    } else {
      // Novo objectivo
      selectedMonth = widget.presetMonth;
      selectedAnnualGoal = widget.presetAnnualGoal;
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider).value;
    final annualGoals = ref.watch(annualGoalsProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF4F1EB),
      appBar: AppBar(
        backgroundColor: cMainColor,
        title: Text(
          widget.goalToEdit == null
              ? "Novo Objectivo Mensal"
              : "Editar Objectivo Mensal",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: annualGoals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erro: $e")),
        data: (annualData) {
          if (auth == null) return const SizedBox();

          final currentYear = DateTime.now().year;
          final availableAnnual =
          annualData.where((a) => a.year == currentYear).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              Text("Objectivo Anual ($currentYear)", style: tNormalBold),
              const SizedBox(height: 8),
              _buildAnnualGoalDropdown(availableAnnual),

              const SizedBox(height: 24),
              Text("Mês", style: tNormalBold),
              const SizedBox(height: 8),
              _buildMonthDropdown(),

              const SizedBox(height: 24),
              Text("Objectivo", style: tNormalBold),
              const SizedBox(height: 8),
              _buildDescriptionInput(),

              const SizedBox(height: 100),
            ],
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cMainColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Salvar", style: TextStyle(color: Colors.white)),
            onPressed: () => _handleSave(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnualGoalDropdown(List<AnnualGoalModel> goals) {
    return DropdownButtonHideUnderline(
      child: KwangaDropdownButton<AnnualGoalModel>(
        value: selectedAnnualGoal,
        items: goals.map((a) {
          return DropdownMenuItem(
            value: a,
            child: Text(a.description, style: tNormal),
          );
        }).toList(),
        onChanged: (v) => setState(() => selectedAnnualGoal = v),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    const months = [
      "Janeiro",
      "Fevereiro",
      "Março",
      "Abril",
      "Maio",
      "Junho",
      "Julho",
      "Agosto",
      "Setembro",
      "Outubro",
      "Novembro",
      "Dezembro",
    ];

    return DropdownButtonHideUnderline(
      child: KwangaDropdownButton<int>(
        value: selectedMonth,
        items: List.generate(12, (i) {
          return DropdownMenuItem(
            value: i + 1,
            child: Text(months[i], style: tNormal),
          );
        }),
        onChanged: (v) => setState(() => selectedMonth = v),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE0DCD5)),
      ),
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: descriptionController,
        maxLines: null,
        style: tNormal,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Digite o objectivo mensal...",
        ),
      ),
    );
  }

  //----------------------------------------------------------------------
  // 🔻 SAVE HANDLER
  //----------------------------------------------------------------------

  Future<void> _handleSave(BuildContext context) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    if (selectedAnnualGoal == null) {
      _notify("Seleccione o objectivo anual.");
      return;
    }

    if (selectedMonth == null) {
      _notify("Seleccione o mês.");
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      _notify("Escreva o objectivo.");
      return;
    }

    final notifier = ref.read(monthlyGoalsProvider.notifier);

    if (widget.goalToEdit == null) {
      // Criar novo
      await notifier.addMonthlyGoal(
        userId: auth.id!,
        annualGoalsId: selectedAnnualGoal!.id,
        description: descriptionController.text,
        month: selectedMonth!,
      );
    } else {
      final updated = widget.goalToEdit!.copyWith(
        description: descriptionController.text,
        month: selectedMonth!,
        annualGoalsId: selectedAnnualGoal!.id,
      );
      await notifier.editMonthlyGoal(updated);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _notify(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  TextStyle get tNormalBold =>
      tNormal.copyWith(fontWeight: FontWeight.bold);
}
