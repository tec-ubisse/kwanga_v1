// lib/screens/projects_screens/project_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/project_model.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/providers/project_actions_provider.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import 'package:kwanga/utils/date_utils.dart';
import 'widgets/project_header.dart';
import 'widgets/project_info_bar.dart';
import 'widgets/project_actions_list.dart';
import 'package:kwanga/widgets/dialogs/kwanga_dialog.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'cards/no_tasks_project_card.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState
    extends ConsumerState<ProjectDetailScreen> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    ref.read(projectActionsProvider.notifier)
        .loadByProjectId(widget.project.id);
  }

  @override
  Widget build(BuildContext context) {
    final monthlyGoal = ref.watch(
      monthlyGoalByIdProvider(widget.project.monthlyGoalId),
    );

    if (monthlyGoal == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final actionsAsync = ref.watch(projectActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Projecto'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),

      backgroundColor: cWhiteColor,

      bottomNavigationBar: BottomActionBar(
        buttonText: 'Nova Acção',
        onPressed: () async {
          final newDesc = await showKwangaActionDialog(
            context,
            title: "Adicionar tarefa",
            hint: "Escreva a sua tarefa aqui",
          );

          if (newDesc != null && newDesc.trim().isNotEmpty) {
            final user = ref.read(authProvider).value;
            if (user == null || user.id == null) return;

            await ref.read(projectActionsProvider.notifier).addAction(
              projectId: widget.project.id,
              userId: user.id!,
              description: newDesc.trim(),
            );
          }
        },
      ),

      body: actionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Erro: $e")),
        data: (actions) {
          final done = actions.where((a) => a.completed == 1).length;
          final total = actions.length;
          final progress = total == 0 ? 0.0 : done / total;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROJECT HEADER
              Container(
                color: Colors.white,
                padding: defaultPadding,
                child: Column(
                  children: [
                    ProjectHeader(
                      title: widget.project.title,
                      progress: progress,
                      percentText: (progress * 100).round(),
                    ),
                    ProjectInfoBar(
                      monthText: monthName(monthlyGoal.month),
                      doneCount: done,
                      total: total,
                      project: widget.project,
                      showMore: isExpanded,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Acções do projecto',
                  style: tSmallTitle.copyWith(fontSize: 18),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [cDefaultShadow],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: total > 0
                          ? ListView(
                        children: [
                          ProjectActionsList(
                            projectId: widget.project.id,
                            actions: actions,
                          ),
                        ],
                      )
                          : const NoTasksProjectCard(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
