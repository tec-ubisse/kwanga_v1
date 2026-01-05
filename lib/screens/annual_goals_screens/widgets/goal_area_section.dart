import 'package:flutter/material.dart';
import 'package:kwanga/screens/annual_goals_screens/widgets/goal_widget.dart';
import 'package:kwanga/widgets/cards/kwanga_empty_card.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/life_area_model.dart';
import '../../../models/annual_goal_model.dart';

class GoalAreaSection extends StatelessWidget {
  final LifeAreaModel area;
  final List<AnnualGoalModel> goals;
  final int year;
  final void Function(AnnualGoalModel goal) onGoalTap;

  const GoalAreaSection({
    super.key,
    required this.area,
    required this.goals,
    required this.year,
    required this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                area.isSystem
                    ? Image.asset(
                        "assets/icons/${area.iconPath}.png",
                        width: 22,
                      )
                    : Image.asset(area.iconPath, width: 22),
                const SizedBox(width: 8),
                Text(area.designation, style: tSmallTitle),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: goals.isNotEmpty
                ? Column(
                    children: goals
                        .map(
                          (g) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GoalWidget(
                              goal: g,
                              isCompleted: false,
                              lifeArea: area,
                              progress: 0,
                              onTap: () => onGoalTap(g),
                            ),
                          ),
                        )
                        .toList(),
                  )
                : KwangaEmptyCard(
                    message: 'Sem objectivo definido para este ano.',
                  ),
          ),
        ],
      ),
    );
  }
}
