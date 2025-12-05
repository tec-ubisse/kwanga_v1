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

  const GoalWidget({
    super.key,
    required this.goal,
    required this.lifeArea,
    required this.progress,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(24),
            blurRadius: 8,
            offset: const Offset(4, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(16.0),
        child: Slidable(
          key: ValueKey(goal.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.48,
            children: [
              // EDITAR
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
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: "Editar",
              ),

              // APAGAR
              SlidableAction(
                onPressed: (_) async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => KwangaDeleteDialog(
                      title: "Eliminar Objectivo Anual",
                      message:
                      "Tem a certeza que pretende apagar o objectivo \"${goal.description}\"? Esta acção é irreversível.",
                    ),
                  );

                  if (confirm == true) {
                    await ref
                        .read(annualGoalsProvider.notifier)
                        .removeAnnualGoal(goal.id);
                    ref.invalidate(annualGoalsProvider);
                  }
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: "Apagar",
              ),
            ],
          ),

          // CARD LAYOUT
          child: Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    goal.description,
                    style: tNormal,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CircularPercentIndicator(
                    radius: 32.0,
                    lineWidth: 12.0,
                    percent: 0.1,
                    center: Text('21%'),
                    progressColor: cMainColor,
                    backgroundColor: Colors.grey.shade300,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Suporta emoji ("💼") ou asset ("assets/icons/education.png")
  Widget _buildIcon(String icon) {
    if (icon.contains("/")) {
      return Image.asset(icon, width: 32, height: 32);
    }
    return Text(icon, style: const TextStyle(fontSize: 30));
  }
}
