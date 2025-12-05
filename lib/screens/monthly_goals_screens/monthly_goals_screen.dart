import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/vision_model.dart';
import 'package:kwanga/models/monthly_goal_model.dart';

import 'package:kwanga/providers/annual_goals_provider.dart';
import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/providers/visions_provider.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/providers/auth_provider.dart';

import 'package:kwanga/widgets/custom_drawer.dart';

import 'package:kwanga/screens/monthly_goals_screens/widgets/monthly_goal_year_dropdown.dart';
import 'package:kwanga/screens/monthly_goals_screens/widgets/monthly_goal_month_dropdown.dart';
import 'package:kwanga/screens/monthly_goals_screens/widgets/monthly_goal_area_section.dart';

import 'create_monthly_goal_screen.dart';

class MonthlyGoalsScreen extends ConsumerStatefulWidget {
  const MonthlyGoalsScreen({super.key});

  @override
  ConsumerState<MonthlyGoalsScreen> createState() => _MonthlyGoalsScreenState();
}

class _MonthlyGoalsScreenState extends ConsumerState<MonthlyGoalsScreen> {
  late int selectedYear;
  late int selectedMonth;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthlyGoals = ref.watch(monthlyGoalsProvider);
    final annualGoals = ref.watch(annualGoalsProvider);
    final visions = ref.watch(visionsProvider);
    final lifeAreas = ref.watch(lifeAreasProvider);
    final auth = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xffF4F1EB),
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text("Objectivos Mensais", style: tTitle),
      ),
      drawer: CustomDrawer(),

      body: monthlyGoals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erro: $e")),
        data: (goalsData) {
          if (annualGoals.isLoading ||
              visions.isLoading ||
              lifeAreas.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (auth == null || auth.id == null) {
            return const Center(child: Text("Usuário inválido."));
          }

          final allAnnualGoals = annualGoals.value ?? [];
          final allVisions = visions.value ?? [];
          final allAreas = lifeAreas.value ?? [];

          final filteredMonthlyGoals =
          goalsData.where((g) => g.month == selectedMonth).toList();

          final Map<LifeAreaModel, List<MonthlyGoalModel>> areaGroups = {
            for (final area in allAreas) area: [],
          };

          for (final goal in filteredMonthlyGoals) {
            final matchingAnnual = allAnnualGoals.firstWhere(
                  (a) => a.id == goal.annualGoalsId && a.year == selectedYear,
              orElse: () => AnnualGoalModel.empty(selectedYear),
            );

            if (matchingAnnual.isEmpty) continue;

            final matchingVision = allVisions.firstWhere(
                  (v) => v.id == matchingAnnual.visionId,
              orElse: () => VisionModel(
                id: "",
                userId: -1,
                lifeAreaId: "",
                conclusion: 0,
                description: "",
                isDeleted: false,
                isSynced: false,
              ),
            );

            final matchingArea = allAreas.firstWhere(
                  (a) => a.id == matchingVision.lifeAreaId,
              orElse: () => LifeAreaModel(
                id: "",
                userId: -1,
                designation: "",
                iconPath: "",
                isSystem: false,
                isDeleted: false,
                isSynced: false,
              ),
            );

            if (areaGroups.containsKey(matchingArea)) {
              areaGroups[matchingArea]!.add(goal);
            }
          }

          return Column(
            children: [
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: MonthlyGoalYearDropdown(
                          selectedYear: selectedYear,
                          onChanged: (y) => setState(() => selectedYear = y),
                        ),
                      ),
                      Expanded(
                        child: MonthlyGoalMonthDropdown(
                          selectedMonth: selectedMonth,
                          onChanged: (m) => setState(() => selectedMonth = m),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final entry in areaGroups.entries)
                      MonthlyGoalAreaSection(
                        area: entry.key,
                        goals: entry.value,
                        allAnnualGoals: allAnnualGoals,
                        visions: allVisions,
                        selectedYear: selectedYear,
                        selectedMonth: selectedMonth,
                        onAdd: (annualGoal) async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateMonthlyGoalScreen(
                                presetMonth: selectedMonth,
                                presetAnnualGoal: annualGoal,
                              ),
                            ),
                          );
                        },
                        onEdit: (goal) async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateMonthlyGoalScreen(
                                goalToEdit: goal,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
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
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Novo Objectivo Mensal",
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateMonthlyGoalScreen(
                    presetMonth: selectedMonth,
                    presetAnnualGoal: null,
                  ),
                ),
              );

              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            },
          ),
        ),
      ),
    );
  }
}
