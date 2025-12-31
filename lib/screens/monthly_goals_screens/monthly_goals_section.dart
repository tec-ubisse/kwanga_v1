import 'package:flutter/material.dart';

import 'package:kwanga/screens/monthly_goals_screens/widgets/monthly_goal_card.dart';
import 'package:kwanga/screens/monthly_goals_screens/create_monthly_goal_screen.dart';

import '../../../custom_themes/text_style.dart';
import '../../../models/annual_goal_model.dart';
import '../../../models/life_area_model.dart';
import '../../../models/monthly_goal_model.dart';
import '../../../widgets/cards/kwanga_empty_card.dart';

class MonthlyGoalsSection extends StatelessWidget {
  final AnnualGoalModel annualGoal;
  final LifeAreaModel area;
  final List<MonthlyGoalModel> goals;

  const MonthlyGoalsSection({
    super.key,
    required this.annualGoal,
    required this.area,
    required this.goals,
  });

  static const List<String> _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        96, // espaço para BottomActionBar
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;

        final monthGoals = goals
            .where(
              (g) =>
          g.annualGoalsId == annualGoal.id &&
              g.month == month,
        )
            .toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- MÊS ----------------
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  _monthNames[index],
                  style: tSmallTitle,
                ),
              ),

              // ---------------- OBJECTIVOS ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: monthGoals.isNotEmpty
                    ? Column(
                  children: monthGoals
                      .map(
                        (goal) => Padding(
                      padding:
                      const EdgeInsets.only(bottom: 12.0),
                      child: MonthlyGoalCard(
                        goal: goal,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CreateMonthlyGoalScreen(
                                    goalToEdit: goal,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                      .toList(),
                )
                    : const KwangaEmptyCard(
                  message:
                  'Sem objectivo definido para este mês.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
