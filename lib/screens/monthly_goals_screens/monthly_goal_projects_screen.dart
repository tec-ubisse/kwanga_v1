import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/screens/projects_screens/create_project_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../custom_themes/blue_accent_theme.dart';
import '../../custom_themes/text_style.dart';

import '../../models/life_area_model.dart';
import '../../models/monthly_goal_model.dart';
import '../../models/project_model.dart';

import '../../providers/projects_provider.dart';

import '../../widgets/cards/kwanga_empty_card.dart';
import '../../widgets/buttons/bottom_action_bar.dart';

class MonthlyGoalProjectsScreen extends ConsumerWidget {
  final MonthlyGoalModel monthlyGoal;
  final LifeAreaModel area;

  const MonthlyGoalProjectsScreen({
    super.key,
    required this.monthlyGoal,
    required this.area,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Projectos', style: tTitle),
        backgroundColor: cMainColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: projectsAsync.when(
        data: (projects) {
          final filtered = projects
              .where((p) => p.monthlyGoalId == monthlyGoal.id && !p.isDeleted)
              .toList();

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Objectivo Mensal',
                            style: tSmallTitle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            monthlyGoal.description,
                            style: tNormal.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (area.iconPath.isNotEmpty)
                                area.isSystem
                                    ? Image.asset(
                                        "assets/icons/${area.iconPath}.png",
                                        width: 20,
                                      )
                                    : Image.asset(area.iconPath, width: 20),
                              const SizedBox(width: 6),
                              Text(
                                "Área: ${area.designation}",
                                style: tNormal.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    CircularPercentIndicator(
                      radius: 32,
                      lineWidth: 12,
                      percent: 0.0,
                      center: Text('0%', style: tNormal),
                      progressColor: cMainColor,
                      backgroundColor: Colors.grey.shade300,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xfff5f5f5),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18.0),
                      ),
                    ),
                    child: filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'Ainda não existe nenhum projecto associado a este objectivo mensal.',
                                style: tNormal,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            itemBuilder: (_, index) {
                              final project = filtered[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => CreateProjectScreen(
                                          projectToEdit: project,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [cDefaultShadow.copyWith(color: Color(0x10000000),)]
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(project.title, style: tNormal),
                                        Wrap(
                                          children: [
                                            Row(
                                              spacing: 4.0,
                                              children: [
                                                Icon(
                                                  Icons.flag_outlined,
                                                  size: 16.0,
                                                ),
                                                Text(project.expectedResult),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Erro ao carregar projectos')),
      ),
      bottomNavigationBar: BottomActionBar(
        buttonText: 'Adicionar projecto',
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => CreateProjectScreen()));
        },
      ),
    );
  }
}
