import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/providers/annual_goals_provider.dart';
import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/providers/visions_provider.dart';

import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';

import 'widgets/goal_area_section.dart';
import 'widgets/year_selector.dart';
import 'create_annual_goal_screen.dart';

class AnnualGoals extends ConsumerStatefulWidget {
  const AnnualGoals({super.key});

  @override
  ConsumerState<AnnualGoals> createState() =>
      _AnnualGoalsScreenState();
}

class _AnnualGoalsScreenState extends ConsumerState<AnnualGoals> {
  int? selectedYear;

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(annualGoalsProvider);
    final visionsAsync = ref.watch(visionsProvider);
    final areasAsync = ref.watch(lifeAreasProvider);

    return Scaffold(
      backgroundColor: cWhiteColor,

      appBar: AppBar(
        title: const Text("Objectivos Anuais"),
        backgroundColor: cMainColor,
        foregroundColor: Colors.white,
      ),

      drawer: const CustomDrawer(),

      bottomNavigationBar: BottomActionBar(
        buttonText: "Adicionar Objectivo Anual",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateAnnualGoalScreen(
                preselectedYear: selectedYear,
              ),
            ),
          );
        },
      ),

      body: SafeArea(
        child: areasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text("Erro ao carregar áreas.")),
          data: (areas) {
            return visionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
              const Center(child: Text("Erro ao carregar visões.")),
              data: (visions) {
                return goalsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                  const Center(child: Text("Erro ao carregar objectivos.")),
                  data: (goals) {
                    final allYears =
                    goals.map((g) => g.year).toSet().toList()..sort();

                    selectedYear ??=
                    allYears.isNotEmpty ? allYears.first : DateTime.now().year;

                    final grouped = areas.map((area) {
                      final areaVisions = visions
                          .where((v) => v.lifeAreaId == area.id.toString())
                          .map((v) => v.id)
                          .toList();

                      final areaGoals = goals
                          .where(
                            (g) =>
                        g.year == selectedYear &&
                            areaVisions.contains(g.visionId),
                      )
                          .toList();

                      return {
                        "area": area,
                        "goals": areaGoals,
                      };
                    }).toList();

                    grouped.sort((a, b) {
                      final aHas = (a["goals"] as List).isNotEmpty;
                      final bHas = (b["goals"] as List).isNotEmpty;
                      if (aHas && !bHas) return -1;
                      if (!aHas && bHas) return 1;
                      return 0;
                    });

                    return Column(
                      children: [
                        Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            child: YearSelector(
                              selectedYear: selectedYear,
                              lockedVision: visions,
                              onChanged: (v) {
                                setState(() => selectedYear = v);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: grouped.length,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            itemBuilder: (_, i) {
                              final area =
                              grouped[i]["area"] as LifeAreaModel;
                              final goals =
                              grouped[i]["goals"] as List<AnnualGoalModel>;

                              if(i<1) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: GoalAreaSection(
                                    area: area,
                                    goals: goals,
                                    year: selectedYear!,
                                  ),
                                );
                              } else {
                                return GoalAreaSection(
                                  area: area,
                                  goals: goals,
                                  year: selectedYear!,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
