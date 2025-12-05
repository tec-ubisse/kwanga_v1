import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/vision_model.dart';
import 'package:kwanga/providers/annual_goals_provider.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';

import 'create_annual_goal_screen.dart';
import 'goal_by_vision_widgets/annual_goals_section.dart';

class GoalsByVision extends ConsumerWidget {
  final VisionModel vision;
  final LifeAreaModel area;

  const GoalsByVision({
    super.key,
    required this.vision,
    required this.area,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(annualGoalsProvider);

    return Scaffold(
      backgroundColor: cWhiteColor,
      appBar: AppBar(
        title: Text("Projecto - ${area.designation}"),
        backgroundColor: cMainColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomActionBar(
        buttonText: "Adicionar Objectivo Anual",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateAnnualGoalScreen(
                visionId: vision.id,
              ),
            ),
          );
        },
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erro: $e")),
        data: (goals) => AnnualGoalsSection(
          allGoals: goals,
          vision: vision,
          area: area,
        ),
      ),
    );
  }
}
