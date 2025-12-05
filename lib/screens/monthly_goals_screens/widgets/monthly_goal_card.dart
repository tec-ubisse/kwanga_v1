import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/monthly_goal_model.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../custom_themes/text_style.dart';
import 'package:kwanga/widgets/kwanga_slidable_card.dart';

class MonthlyGoalCard extends ConsumerWidget {
  final MonthlyGoalModel goal;
  final VoidCallback onEdit;

  const MonthlyGoalCard({
    super.key,
    required this.goal,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KwangaSlidableCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      borderRadius: 16,
      showShadow: true,
      actions: [
        KwangaSlidableAction(
          icon: Icons.edit,
          label: "Editar",
          color: cSecondaryColor,
          onTap: onEdit,
        ),
        KwangaSlidableAction(
          icon: Icons.delete,
          label: "Eliminar",
          color: cTertiaryColor,
          onTap: () {
            ref.read(monthlyGoalsProvider.notifier).removeMonthlyGoal(goal.id);
          },
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(goal.description, style: tNormal)),
            Expanded(
              flex: 1,
              child: CircularPercentIndicator(
                radius: 32.0,
                lineWidth: 12.0,
                percent: 0.1,
                center: Text('5%'),
                progressColor: cMainColor,
                backgroundColor: Colors.grey.shade300,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
