import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/monthly_goal_model.dart';
import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/models/vision_model.dart';
import 'package:kwanga/widgets/cards/kwanga_empty_card.dart';

import '../monthly_goal_projects_screen.dart';
import 'monthly_goal_widget.dart';

class MonthlyGoalAreaSection extends StatelessWidget {
  final LifeAreaModel area;
  final List<MonthlyGoalModel> goals;
  final List<AnnualGoalModel> allAnnualGoals;
  final List<VisionModel> visions;
  final int selectedYear;
  final int selectedMonth;

  final void Function(AnnualGoalModel?) onAdd;
  final void Function(MonthlyGoalModel) onEdit;
  final void Function(MonthlyGoalModel) onDelete;

  const MonthlyGoalAreaSection({
    super.key,
    required this.area,
    required this.goals,
    required this.allAnnualGoals,
    required this.visions,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        /// ---- Título da Área ----
        Row(
          children: [
            if (area.iconPath.isNotEmpty)
              area.isSystem
                  ? Image.asset(
                "assets/icons/${area.iconPath}.png",
                width: 24,
              )
                  : Image.asset(area.iconPath, width: 24),
            const SizedBox(width: 8),
            Text(area.designation, style: tSmallTitle),
          ],
        ),

        const SizedBox(height: 8),

        /// ---- Lista de Goals ----
        if (goals.isEmpty)
          KwangaEmptyCard(message: 'Sem objectivo definido para este mês.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: goals.map((g) {
              return MonthlyGoalWidget(
                goal: g,
                onEdit: () => onEdit(g),
                onDelete: () => onDelete(g),
                onOpenProjects: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MonthlyGoalProjectsScreen(
                        monthlyGoal: g,
                        area: area,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  AnnualGoalModel? _findAnnualGoalForArea() {
    for (final annual
    in allAnnualGoals.where((a) => a.year == selectedYear)) {
      final vision = visions.firstWhere(
            (v) => v.id == annual.visionId,
        orElse: () => VisionModel(
          id: "",
          userId: -1,
          lifeAreaId: "",
          conclusion: 0,
          description: "",
          isDeleted: false,
          isSynced: false,
        ),
      );

      if (vision.lifeAreaId == area.id) {
        return annual;
      }
    }
    return null;
  }
}
