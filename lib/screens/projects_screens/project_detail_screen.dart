import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/project_model.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/providers/project_actions_provider.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/screens/projects_screens/widgets/no_tasks_project_card.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import 'package:kwanga/utils/date_utils.dart';
import 'widgets/project_header.dart';
import 'widgets/project_info_bar.dart';
import 'widgets/project_actions_list.dart';
import 'package:kwanga/widgets/dialogs/kwanga_dialog.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    ref
        .read(projectActionsProvider.notifier)
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
          setState(() {
            isExpanded = false;
          });
          final newDesc = await showKwangaActionDialog(
            context,
            title: "Adicionar tarefa",
            hint: "Escreva a sua tarefa aqui",
          );

          if (newDesc != null && newDesc.trim().isNotEmpty) {
            await ref
                .read(projectActionsProvider.notifier)
                .addAction(
              projectId: widget.project.id,
              description: newDesc.trim(),
            );
          }
        },
      ),
      body: actionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
        data: (actions) {
          final doneCount = actions.where((a) => a.isDone).length;
          final total = actions.length;
          final progress = total == 0 ? 0.0 : doneCount / total;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24.0,
            children: [
              // HEADER
              Container(
                color: Colors.white,
                child: Padding(
                  padding: defaultPadding,
                  child: Column(
                    spacing: 12.0,
                    children: [
                      ProjectHeader(
                        title: widget.project.title,
                        progress: progress,
                        percentText: (progress * 100).round(),
                      ),
                      ProjectInfoBar(
                        monthText: monthName(monthlyGoal.month),
                        doneCount: doneCount,
                        total: total,
                        project: widget.project,
                        showMore: isExpanded,
                      ),
                    ],
                  ),
                ),
              ),

              // TÍTULO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Acções do projecto',
                  style: tSmallTitle.copyWith(fontSize: 18),
                ),
              ),

              // LISTA OU EMPTY
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [cDefaultShadow],
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: total > 0
                          ? ListView(
                        children: [
                          ProjectActionsList(actions: actions),
                        ],
                      )
                          : LayoutBuilder(
                        builder: (context, constraints) {
                          final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

                          return SingleChildScrollView(
                            reverse: true,
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: const NoTasksProjectCard(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

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
