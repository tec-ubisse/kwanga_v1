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
import '../../widgets/feedback_widget.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  final ProjectModel? projectToEdit;

  const CreateProjectScreen({super.key, this.projectToEdit});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedMonthlyGoalId;
  String? monthlyGoalError;
  int selectedMonth = DateTime.now().month;

  final titleController = TextEditingController();
  final purposeController = TextEditingController();
  final expectedController = TextEditingController();

  bool get isEditing => widget.projectToEdit != null;

  @override
  void initState() {
    super.initState();

    final project = widget.projectToEdit;
    if (project != null) {
      titleController.text = project.title;
      purposeController.text = project.purpose ?? "";
      expectedController.text = project.expectedResult ?? "";
      selectedMonthlyGoalId = project.monthlyGoalId;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    purposeController.dispose();
    expectedController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (selectedMonthlyGoalId == null) {
      setState(() => monthlyGoalError = 'O objectivo mensal é obrigatório');
    }

    if (!isValid || selectedMonthlyGoalId == null) return;

    final auth = ref.read(authProvider).value;
    if (auth?.id == null) return;

    final notifier = ref.read(projectsProvider.notifier);

    if (isEditing) {
      final updated = widget.projectToEdit!.copyWith(
        monthlyGoalId: selectedMonthlyGoalId!,
        title: titleController.text.trim(),
        purpose: purposeController.text.trim(),
        expectedResult: expectedController.text.trim(),
      );
      await notifier.editProject(updated);
      showFeedbackScaffoldMessenger(context, "Projecto actualizado com sucesso");
    } else {
      await notifier.addProject(
        userId: auth!.id!,
        monthlyGoalId: selectedMonthlyGoalId!,
        title: titleController.text.trim(),
        purpose: purposeController.text.trim(),
        expectedResult: expectedController.text.trim(),
      );
      showFeedbackScaffoldMessenger(context, "Projecto adicionado com sucesso");
    }

    if (mounted) Navigator.pop(context, "saved");
  }

  @override
  Widget build(BuildContext context) {
    final monthlyGoalsAsync = ref.watch(monthlyGoalsProvider);

    const monthNames = [
      'Janeiro','Fevereiro','Março','Abril','Maio','Junho',
      'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Projecto' : 'Novo Projecto', style: tTitle),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),

      bottomNavigationBar: BottomActionBar(
        buttonText: isEditing ? "Actualizar" : "Salvar",
        onPressed: _save,
      ),

      body: Padding(
        padding: defaultPadding,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ---------------- MÊS ----------------
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
                    monthlyGoalError = null;
                  });
                },
                labelText: '',
                hintText: '',
              ),

              const SizedBox(height: 12),

              // ----------- OBJECTIVO MENSAL ----------
              Text("Objectivo Mensal", style: tSmallTitle),
              const SizedBox(height: 8),

              monthlyGoalsAsync.when(
                data: (goals) {
                  final filtered =
                  goals.where((g) => g.month == selectedMonth).toList();

                  return KwangaDropdownButton<String>(
                    value: selectedMonthlyGoalId,
                    errorMessage: monthlyGoalError,
                    items: filtered
                        .map(
                          (g) => DropdownMenuItem(
                        value: g.id,
                        child: Text(g.description),
                      ),
                    )
                        .toList(),
                    onChanged: (v) => setState(() {
                      selectedMonthlyGoalId = v;
                      monthlyGoalError = null;
                    }),
                    labelText: '',
                    hintText: 'Seleccione um objectivo mensal',
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text("Erro: $e"),
              ),

              const SizedBox(height: 12),

              // ---------------- TÍTULO ----------------
              Text("Título", style: tSmallTitle),
              const SizedBox(height: 8),

              TextFormField(
                controller: titleController,
                maxLines: 2,
                decoration: inputDecoration,
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'O título é obrigatório' : null,
              ),

              const SizedBox(height: 12),

              // --------------- PROPÓSITO --------------
              Text("Propósito", style: tSmallTitle),
              const SizedBox(height: 8),

              TextFormField(
                controller: purposeController,
                maxLines: 3,
                decoration: inputDecoration,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'O propósito é obrigatório';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ----------- RESULTADO ESPERADO ----------
              Text("Resultado Esperado", style: tSmallTitle),
              const SizedBox(height: 8),

              TextFormField(
                controller: expectedController,
                maxLines: 3,
                decoration: inputDecoration,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'O resultado esperado é obrigatório';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
