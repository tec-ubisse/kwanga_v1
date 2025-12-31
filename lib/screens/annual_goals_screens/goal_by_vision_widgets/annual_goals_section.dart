import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/vision_model.dart';

import 'goals_for_year.dart';
import 'header_section.dart';

class AnnualGoalsSection extends StatelessWidget {
  final List<AnnualGoalModel> allGoals;
  final VisionModel vision;
  final LifeAreaModel area;

  const AnnualGoalsSection({
    super.key,
    required this.allGoals,
    required this.vision,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final filteredGoals =
    allGoals.where((g) => g.visionId == vision.id).toList();

    final currentYear = DateTime.now().year;
    final years = [
      for (int y = currentYear; y <= vision.conclusion; y++) y
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER FIXO
        HeaderSection(
          vision: vision,
          area: area,
        ),

        /// CONTEÚDO SCROLLÁVEL
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              /// TÍTULO
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Text(
                  'Objectivos Anuais',
                  style: tSmallTitle.copyWith(fontSize: 18),
                ),
              ),

              /// ANOS + OBJECTIVOS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final year in years) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          year.toString(),
                          style: tSmallTitle.copyWith(
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      GoalsForYear(
                        goals: filteredGoals,
                        year: year,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
