import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/providers/projects_provider.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/widgets/kwanga_dropdown_button.dart';

import '../../widgets/buttons/bottom_action_bar.dart';
import '../../models/project_model.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  final ProjectModel? projectToEdit;

  const CreateProjectScreen({
    super.key,
    this.projectToEdit,
  });

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  String? selectedMonthlyGoalId;
  int selectedMonth = DateTime.now().month;

  final titleController = TextEditingController();
  final purposeController = TextEditingController();
  final expectedController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final project = widget.projectToEdit;
    if (project != null) {
      titleController.text = project.title;
      purposeController.text = project.purpose ?? "";
      expectedController.text = project.expectedResult ?? "";
      selectedMonthlyGoalId = project.monthlyGoalId;

      // Determinar mês a partir do MonthlyGoal
      final mgList = ref.read(monthlyGoalsProvider).value;
      if (mgList != null) {
        final mg = mgList.firstWhere(
              (m) => m.id == project.monthlyGoalId,
          orElse: () => mgList.first,
        );
        selectedMonth = mg.month;
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    purposeController.dispose();
    expectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthlyGoalsAsync = ref.watch(monthlyGoalsProvider);
    final auth = ref.read(authProvider).value;

    const monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.projectToEdit == null
              ? 'Novo Projecto'
              : 'Editar Projecto',
          style: tTitle,
        ),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),
      backgroundColor: cWhiteColor,

      bottomNavigationBar: BottomActionBar(
        buttonText: "Salvar",
        onPressed: () async {
          if (auth == null || auth.id == null) return;

          if (selectedMonthlyGoalId == null ||
              titleController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Preencha todos os campos se faz favor!"),
              ),
            );
            return;
          }

          final notifier = ref.read(projectsProvider.notifier);

          // --------------------------
          // CRIAR
          // --------------------------
          if (widget.projectToEdit == null) {
            await notifier.addProject(
              userId: auth.id!,
              monthlyGoalId: selectedMonthlyGoalId!,
              title: titleController.text.trim(),
              purpose: purposeController.text.trim(),
              expectedResult: expectedController.text.trim(),
            );
          }

          // --------------------------
          // EDITAR
          // --------------------------
          else {
            final updated = widget.projectToEdit!.copyWith(
              monthlyGoalId: selectedMonthlyGoalId!,
              title: titleController.text.trim(),
              purpose: purposeController.text.trim(),
              expectedResult: expectedController.text.trim(),
            );

            await notifier.editProject(updated);
          }

          Navigator.pop(context, "saved");
        },
      ),

      body: Padding(
        padding: defaultPadding,
        child: ListView(
          children: [
            // -------------------------
            // Selecionar mês
            // -------------------------
            Text("Mês", style: tSmallTitle),
            const SizedBox(height: 8),

            KwangaDropdownButton<int>(
              value: selectedMonth,
              items: List.generate(
                12,
                    (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(monthNames[i]),
                ),
              ),
              onChanged: (m) {
                setState(() {
                  selectedMonth = m!;
                  selectedMonthlyGoalId = null;
                });
              },
            ),

            const SizedBox(height: 12),

            // -------------------------
            // Objectivo Mensal
            // -------------------------
            Text("Objectivo Mensal", style: tSmallTitle),
            const SizedBox(height: 8),

            monthlyGoalsAsync.when(
              data: (monthlyGoals) {
                final goalsForMonth =
                monthlyGoals.where((mg) => mg.month == selectedMonth).toList();

                return KwangaDropdownButton<String>(
                  value: selectedMonthlyGoalId,
                  items: goalsForMonth
                      .map(
                        (mg) => DropdownMenuItem(
                      value: mg.id,
                      child: Text(mg.description),
                    ),
                  )
                      .toList(),
                  onChanged: (val) => setState(() => selectedMonthlyGoalId = val),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text("Erro: $e"),
            ),

            const SizedBox(height: 12),

            // -------------------------
            // Título
            // -------------------------
            Text("Título", style: tSmallTitle),
            const SizedBox(height: 8),

            TextFormField(
              controller: titleController,
              maxLines: 2,
              decoration: inputDecoration,
            ),

            const SizedBox(height: 12),

            // -------------------------
            // Propósito
            // -------------------------
            Text("Propósito", style: tSmallTitle),
            const SizedBox(height: 8),

            TextFormField(
              controller: purposeController,
              maxLines: 3,
              decoration: inputDecoration,
            ),

            const SizedBox(height: 12),

            // -------------------------
            // Resultado Esperado
            // -------------------------
            Text("Resultado Esperado", style: tSmallTitle),
            const SizedBox(height: 8),

            TextFormField(
              controller: expectedController,
              maxLines: 3,
              decoration: inputDecoration,
            ),
          ],
        ),
      ),
    );
  }
}
