import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/annual_goal_model.dart';
import '../../../providers/annual_goals_provider.dart';
import '../../../widgets/dialogs/kwanga_delete_dialog.dart';
import '../../annual_goals_screens/create_annual_goal_screen.dart';

class AnnualGoalCard extends ConsumerWidget {
  final AnnualGoalModel goal;

  const AnnualGoalCard({
    super.key,
    required this.goal,
  });

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double safeProgress = 0.0;
    const int percent = 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [cDefaultShadow],
        ),
        child: ClipRRect(
          borderRadius: _radius,
          child: Slidable(
            key: ValueKey(goal.id),

            /// Ações laterais
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.5,
              children: [
                SlidableAction(
                  backgroundColor: cSecondaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Editar',
                  onPressed: (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateAnnualGoalScreen(
                          annualGoalToEdit: goal,
                          visionId: goal.visionId,
                          preselectedYear: goal.year,
                        ),
                      ),
                    );
                  },
                ),
                SlidableAction(
                  backgroundColor: cTertiaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Eliminar',
                  onPressed: (_) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => KwangaDeleteDialog(
                        title: 'Eliminar Objectivo Anual',
                        message:
                        'Tem a certeza que pretende eliminar o objectivo '
                            '"${goal.description}"?\n'
                            'Esta acção é irreversível.',
                      ),
                    );

                    if (confirm == true) {
                      await ref
                          .read(annualGoalsProvider.notifier)
                          .removeAnnualGoal(goal.id);
                      ref.invalidate(annualGoalsProvider);
                    }
                  },
                ),
              ],
            ),

            /// Card
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateAnnualGoalScreen(
                      annualGoalToEdit: goal,
                      visionId: goal.visionId,
                      preselectedYear: goal.year,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: cardDecoration,
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Texto
                    Expanded(
                      child: Text(
                        goal.description,
                        style: tNormal,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Progresso
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


