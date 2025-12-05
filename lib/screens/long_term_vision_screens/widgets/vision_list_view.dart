import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import '../../../models/life_area_model.dart';
import '../../../models/vision_model.dart';
import '../../../screens/annual_goals_screens/goals_by_vision.dart';
import 'vision_widget.dart';
import 'no_vision_widget.dart';

class VisionListView extends StatelessWidget {
  final List<dynamic> items;
  final Map<String, LifeAreaModel> areasMap;
  final List goals;

  const VisionListView({
    super.key,
    required this.items,
    required this.areasMap,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: items.length,
        itemBuilder: (_, index) {
          final item = items[index];

          bool isFirstArea = false;

          if (item is LifeAreaModel) {
            if (index == 0 || items[index - 1] is VisionModel) {
              isFirstArea = true;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFirstArea)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 16),
                  child: Text(
                    "Áreas da vida sem visão",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: cMainColor,
                    ),
                  ),
                ),

              if (item is VisionModel)
                Builder(builder: (_) {
                  final area = areasMap[item.lifeAreaId]!;
                  final goalsCount =
                      goals.where((g) => g.visionId == item.id).length;

                  return VisionWidget(
                    vision: item,
                    area: area,
                    goalsCount: goalsCount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) =>
                              GoalsByVision(area: area, vision: item),
                        ),
                      );
                    },
                  );
                }),

              if (item is LifeAreaModel) NoVisionWidget(areaSemVisao: item),
            ],
          );
        },
      ),
    );
  }
}
