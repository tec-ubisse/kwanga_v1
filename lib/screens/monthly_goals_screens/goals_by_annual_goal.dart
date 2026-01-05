import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../custom_themes/text_style.dart';
import 'create_monthly_goal_screen.dart';
import 'monthly_goals_section.dart';

class GoalsByAnnualGoal extends ConsumerWidget {
  final AnnualGoalModel annualGoal;
  final LifeAreaModel area;

  const GoalsByAnnualGoal({
    super.key,
    required this.annualGoal,
    required this.area,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyGoalsAsync = ref.watch(monthlyGoalsProvider);

    return Scaffold(
      backgroundColor: cWhiteColor,
      appBar: AppBar(
        title: Text(
          'Objectivo Anual',
        ),
        backgroundColor: cMainColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomActionBar(
        buttonText: 'Adicionar Objectivo Mensal',
        onPressed: () {
          final currentMonth = DateTime.now().month;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateMonthlyGoalScreen(
                presetAnnualGoal: annualGoal,
                presetMonth: currentMonth,
              ),
            ),
          );
        },
      ),
      body: monthlyGoalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (goals) {
          return Column(
            children: [
              // ================= HEADER ELEGANTE =================
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cWhiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// TEXTO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            annualGoal.year.toString(),
                            style: tSmallTitle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Objectivo anual
                          Text(
                            annualGoal.description,
                            style: tNormal.copyWith(fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (area.iconPath.isNotEmpty)
                                area.isSystem
                                    ? Image.asset(
                                  "assets/icons/${area.iconPath}.png",
                                  width: 20,
                                )
                                    : Image.asset(
                                  area.iconPath,
                                  width: 20,
                                ),
                              const SizedBox(width: 6),
                              Text(
                                "Área: ${area.designation}",
                                style: tNormal.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// PROGRESSO
                    CircularPercentIndicator(
                      radius: 36,
                      lineWidth: 12,
                      percent: 0.0,
                      center: Text(
                        '0%', style: tNormal,
                      ),
                      progressColor: cMainColor,
                      backgroundColor: Colors.grey.shade300,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ],
                ),
              ),

              // ================= LISTA DE MESES =================
              Expanded(
                child: MonthlyGoalsSection(
                  annualGoal: annualGoal,
                  area: area,
                  goals: goals,
                ),
              ),
            ],
          );

        },
      ),

    );
  }
}
