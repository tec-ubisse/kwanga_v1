import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/annual_goal_model.dart';
import '../../../models/life_area_model.dart';
import '../../../providers/annual_goals_provider.dart';
import '../../../widgets/dialogs/kwanga_delete_dialog.dart';
import '../create_annual_goal_screen.dart';

class GoalWidget extends ConsumerWidget {
  final AnnualGoalModel goal;
  final LifeAreaModel lifeArea;
  final double progress;
  final bool isCompleted;
  final VoidCallback? onTap;

  const GoalWidget({
    super.key,
    required this.goal,
    required this.lifeArea,
    required this.progress,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeProgress = (progress / 100);
    // .clamp(0.0, 1.0)
    final percent = (safeProgress * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(boxShadow: [cDefaultShadow]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Slidable(
            key: ValueKey(goal.id),

            /// Ações laterais
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.5,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateAnnualGoalScreen(
                          annualGoalToEdit: goal,
                          preselectedYear: goal.year,
                          visionId: goal.visionId,
                        ),
                      ),
                    );
                  },
                  backgroundColor: cSecondaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Editar',
                ),
                SlidableAction(
                  onPressed: (_) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => KwangaDeleteDialog(
                        title: 'Eliminar Objectivo Anual',
                        message:
                        'Tem a certeza que pretende apagar o objectivo '
                            '"${goal.description}"? Esta acção é irreversível.',
                      ),
                    );

                    if (confirm == true) {
                      await ref
                          .read(annualGoalsProvider.notifier)
                          .removeAnnualGoal(goal.id);
                      ref.invalidate(annualGoalsProvider);
                    }
                  },
                  backgroundColor: cTertiaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Eliminar',
                ),
              ],
            ),

            /// Card
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: cardDecoration,
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Texto flexível
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