import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/monthly_goal_model.dart';

class MonthlyGoalWidget extends StatelessWidget {
  final MonthlyGoalModel goal;
  final VoidCallback onOpenProjects;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MonthlyGoalWidget({
    super.key,
    required this.goal,
    required this.onOpenProjects,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const double safeProgress = 0.1;
    const int percent = 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(boxShadow: [cDefaultShadow]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Slidable(
            key: ValueKey(goal.id),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.5,
              children: [
                SlidableAction(
                  onPressed: (_) => onEdit(),
                  backgroundColor: cSecondaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Editar',
                ),
                SlidableAction(
                  onPressed: (_) => onDelete(),
                  backgroundColor: cTertiaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Eliminar',
                ),
              ],
            ),
            child: GestureDetector(
              onTap: onOpenProjects,
              child: Container(
                decoration: cardDecoration,
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0,
                ),
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
          ),
        ),
      ),
    );
  }
}
