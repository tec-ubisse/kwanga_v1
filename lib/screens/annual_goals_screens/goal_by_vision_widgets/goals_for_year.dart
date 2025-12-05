import 'package:flutter/material.dart';
import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/screens/annual_goals_screens/widgets/annual_goal_card.dart';
import 'package:kwanga/widgets/cards/kwanga_empty_card.dart';

class GoalsForYear extends StatelessWidget {
  final List<AnnualGoalModel> goals;
  final int year;

  const GoalsForYear({
    super.key,
    required this.goals,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final yearlyGoals = goals.where((g) => g.year == year).toList();

    if (yearlyGoals.isEmpty) {
      return const KwangaEmptyCard(message: 'Sem objectivo anual definido para este ano');
    }

    return Column(
      children: [
        for (final g in yearlyGoals)
          AnnualGoalCard(g: g),
      ],
    );
  }
}
