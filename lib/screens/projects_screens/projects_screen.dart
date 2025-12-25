import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/models/project_model.dart';
import 'package:kwanga/models/task_model.dart';

import 'package:kwanga/providers/projects_provider.dart';
import 'package:kwanga/providers/tasks/tasks_provider.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/providers/annual_goals_provider.dart';
import 'package:kwanga/providers/visions_provider.dart';
import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/providers/auth_provider.dart';

import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import '../navigation_screens/custom_drawer.dart';
import '../../widgets/dialogs/kwanga_delete_dialog.dart';

import '../monthly_goals_screens/widgets/monthly_goal_year_dropdown.dart';
import '../monthly_goals_screens/widgets/monthly_goal_month_dropdown.dart';

import 'widgets/life_area_section.dart';
import 'project_detail_screen.dart';
import 'create_project_screen.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  late int selectedYear;
  late int selectedMonth;
  late final ScrollController _scrollController;

  Map<String, double> _progressMap = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _computeProgress(List<ProjectModel> projects, List<TaskModel> allTasks) {
    final map = <String, double>{};

    for (final p in projects) {
      final projTasks = allTasks.where((t) => t.projectId == p.id).toList();
      final total = projTasks.length;
      final done = projTasks.where((t) => t.completed == 1).length;
      map[p.id] = total == 0 ? 0.0 : done / total;
    }

    setState(() => _progressMap = map);
  }

  Future<void> _createProject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
    );
    ref.refresh(projectsProvider);
  }

  Future<void> _openProject(ProjectModel p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p)),
    );
    ref.refresh(projectsProvider);
  }

  Future<void> _editProject(ProjectModel p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateProjectScreen(projectToEdit: p)),
    );
    ref.refresh(projectsProvider);
  }

  Future<void> _deleteProject(ProjectModel p) async {
    final confirmed = await _confirmDelete(p);
    if (!confirmed) return;

    await ref.read(projectsProvider.notifier).removeProject(p.id);
    ref.refresh(projectsProvider);
  }

  Future<bool> _confirmDelete(ProjectModel p) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return KwangaDeleteDialog(
          title: "Eliminar Projecto",
          message:
          "Tem a certeza que pretende apagar o projecto \"${p.title}\"? Esta acção é irreversível.",
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final tasksAsync = ref.watch(tasksProvider);

    final monthlyGoalsAsync = ref.watch(monthlyGoalsProvider);
    final annualGoalsAsync = ref.watch(annualGoalsProvider);
    final visionsAsync = ref.watch(visionsProvider);
    final lifeAreasAsync = ref.watch(lifeAreasProvider);

    final auth = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Projectos", style: tTitle),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),
      drawer: const CustomDrawer(),

      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erro: $e")),
        data: (projects) {
          if (monthlyGoalsAsync.isLoading ||
              annualGoalsAsync.isLoading ||
              visionsAsync.isLoading ||
              lifeAreasAsync.isLoading ||
              tasksAsync.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (auth == null || auth.id == null) {
            return const Center(child: Text("Usuário inválido."));
          }

          final tasks = tasksAsync.value ?? [];
          _computeProgress(projects, tasks);

          final monthlyGoals = monthlyGoalsAsync.value ?? [];
          final annualGoals = annualGoalsAsync.value ?? [];
          final visions = visionsAsync.value ?? [];
          final lifeAreas = lifeAreasAsync.value ?? [];

          final Map<String, List<ProjectModel>> projectsByArea = {
            for (final a in lifeAreas) a.id: [],
          };

          for (final p in projects) {
            final mg = monthlyGoals.firstWhereOrNull((m) => m.id == p.monthlyGoalId);
            if (mg == null || mg.month != selectedMonth) continue;

            final ag = annualGoals.firstWhereOrNull((a) => a.id == mg.annualGoalsId);
            if (ag == null || ag.year != selectedYear) continue;

            final vision = visions.firstWhereOrNull((v) => v.id == ag.visionId);
            if (vision == null) continue;

            final area = lifeAreas.firstWhereOrNull((a) => a.id == vision.lifeAreaId);
            if (area == null) continue;

            projectsByArea[area.id]!.add(p);
          }

          final orderedAreas = [
            ...lifeAreas.where((a) => (projectsByArea[a.id]?.isNotEmpty ?? false)),
            ...lifeAreas.where((a) => !(projectsByArea[a.id]?.isNotEmpty ?? false)),
          ];

          return Column(
            children: [
              // filtros
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: MonthlyGoalYearDropdown(
                          selectedYear: selectedYear,
                          onChanged: (y) => setState(() => selectedYear = y),
                        ),
                      ),
                      Expanded(
                        child: MonthlyGoalMonthDropdown(
                          selectedMonth: selectedMonth,
                          onChanged: (m) => setState(() => selectedMonth = m),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final area in orderedAreas)
                      LifeAreaSection(
                        area: area,
                        projects: projectsByArea[area.id] ?? [],
                        progressMap: _progressMap,
                        onAdd: _createProject,
                        onOpen: _openProject,
                        onEdit: _editProject,
                        onDelete: _deleteProject,
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              )
            ],
          );
        },
      ),

      bottomNavigationBar: BottomActionBar(
        buttonText: 'Novo Projecto',
        onPressed: _createProject,
      ),
    );
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final v in this) {
      if (test(v)) return v;
    }
    return null;
  }
}
