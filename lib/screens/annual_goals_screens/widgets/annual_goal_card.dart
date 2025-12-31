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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double safeProgress = 0.0;
    const int percent = 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          key: ValueKey(goal.id),
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
                        visionId: goal.visionId,
                        preselectedYear: goal.year,
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
                backgroundColor: cTertiaryColor,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Eliminar',
              ),
            ],
          ),
          child: InkWell(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    radius: 28,
                    lineWidth: 8,
                    percent: safeProgress,
                    center: Text('0%'),
                    progressColor: cMainColor,
                    backgroundColor: Colors.grey,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

