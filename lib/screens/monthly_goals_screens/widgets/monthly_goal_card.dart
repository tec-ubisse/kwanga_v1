import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/monthly_goal_model.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/widgets/dialogs/kwanga_delete_dialog.dart';
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
    const double safeProgress = 0.0;
    const int percent = 0;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [cDefaultShadow], // ✅ SOMBRA REAL
      ),
      child: KwangaSlidableCard(
        borderRadius: 16,
        showShadow: false, // ❗ sombra já está aqui fora
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
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => KwangaDeleteDialog(
                  title: "Eliminar objectivo",
                  message:
                  "Tens certeza que desejas eliminar este objectivo mensal?",
                ),
              );

              if (confirmed == true) {
                ref
                    .read(monthlyGoalsProvider.notifier)
                    .removeMonthlyGoal(goal.id);
              }
            },
          ),
        ],
        child: Container(
          decoration: cardDecoration,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  goal.description,
                  style: tNormal,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              CircularPercentIndicator(
                radius: 32,
                lineWidth: 12,
                percent: safeProgress,
                center: Text(
                  '$percent%',
                  style: tSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                progressColor: cMainColor,
                backgroundColor: Colors.grey.shade300,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
