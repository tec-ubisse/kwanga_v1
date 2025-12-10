import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/models/annual_goal_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../annual_goals_screens/create_annual_goal_screen.dart';
import '../../../providers/annual_goals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/dialogs/kwanga_delete_dialog.dart'; // <-- IMPORTANTE

class AnnualGoalCard extends ConsumerWidget {
  final AnnualGoalModel g;

  const AnnualGoalCard({super.key, required this.g});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: cardDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Slidable(
            key: ValueKey(g.id),

            // AÇÕES DO LADO DIREITO
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.50,
              children: [
                // EDITAR
                SlidableAction(
                  onPressed: (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateAnnualGoalScreen(
                          annualGoalToEdit: g,
                          visionId: g.visionId,
                          preselectedYear: g.year,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: "Editar",
                ),

                // Default Delete
                SlidableAction(
                  onPressed: (_) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => KwangaDeleteDialog(
                        title: "Eliminar Objectivo Anual",
                        message:
                            "Tem a certeza que pretende eliminar o objectivo \"${g.description}\"?\nEsta acção é irreversível.",
                      ),
                    );

                    if (confirm == true) {
                      await ref
                          .read(annualGoalsProvider.notifier)
                          .removeAnnualGoal(g.id);

                      ref.invalidate(annualGoalsProvider);
                    }
                  },
                  backgroundColor: cTertiaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: "Eliminar",
                ),
              ],
            ),

            // CARD ORIGINAL
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Row(
                spacing: 4.0,
                children: [
                  Expanded(flex: 3, child: Text(g.description, style: tNormal)),
                  Expanded(
                    flex: 1,
                    child: CircularPercentIndicator(
                      radius: 32.0,
                      lineWidth: 10.0,
                      percent: 0.74,
                      center: Text('72%'),
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
      ),
    );
  }
}
