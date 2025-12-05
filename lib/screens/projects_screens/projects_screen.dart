import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/models/project_model.dart';

import 'package:kwanga/providers/projects_provider.dart';
import 'package:kwanga/providers/monthly_goals_provider.dart';
import 'package:kwanga/providers/annual_goals_provider.dart';
import 'package:kwanga/providers/visions_provider.dart';
import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/providers/auth_provider.dart';

import '../../widgets/custom_drawer.dart';

import '../../widgets/dialogs/kwanga_delete_dialog.dart';
import '../monthly_goals_screens/widgets/monthly_goal_year_dropdown.dart';
import '../monthly_goals_screens/widgets/monthly_goal_month_dropdown.dart';

import 'widgets/life_area_section.dart';
import 'project_detail_screen.dart';
import 'create_project_screen.dart';

import '../../data/database/project_actions_dao.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  late int selectedYear;
  late int selectedMonth;
  late final ScrollController _scrollController;

  final ProjectActionsDao _actionsDao = ProjectActionsDao();
  bool _loadingProgress = false;
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
    try {
      _scrollController.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _computeProgress(List<ProjectModel> projects) async {
    _loadingProgress = true;
    if (mounted) setState(() {});

    try {
      final entries = await Future.wait(
        projects.map((p) async {
          final actions = await _actionsDao.getActionsByProjectId(p.id);
          final total = actions.length;
          final done = actions.where((a) => a.isDone).length;
          return MapEntry(p.id, total == 0 ? 0.0 : done / total);
        }),
      );

      _progressMap = {for (var e in entries) e.key: e.value};
    } catch (_) {
      _progressMap = {};
    }

    _loadingProgress = false;
    if (mounted) setState(() {});
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
      MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p,)),
    );
    ref.refresh(projectsProvider);
  }

  Future<void> _editProject(ProjectModel p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateProjectScreen(projectToEdit: p),
      ),
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
        false; // caso feche o diálogo
  }


  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    final monthlyGoalsAsync = ref.watch(monthlyGoalsProvider);
    final annualGoalsAsync = ref.watch(annualGoalsProvider);
    final visionsAsync = ref.watch(visionsProvider);
    final lifeAreasAsync = ref.watch(lifeAreasProvider);

    final auth = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xffF4F1EB),
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
              lifeAreasAsync.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (auth == null || auth.id == null) {
            return const Center(child: Text("Usuário inválido."));
          }

          final monthlyGoals = monthlyGoalsAsync.value ?? [];
          final annualGoals = annualGoalsAsync.value ?? [];
          final visions = visionsAsync.value ?? [];
          final lifeAreas = lifeAreasAsync.value ?? [];

          final Map<String, List<ProjectModel>> projectsByArea = {
            for (final area in lifeAreas) area.id: [],
          };

          for (final project in projects) {
            // Monthly Goal
            final mg = monthlyGoals.firstWhereOrNull((m) => m.id == project.monthlyGoalId);
            if (mg == null || mg.month != selectedMonth) continue;

            // Annual Goal
            final ag = annualGoals.firstWhereOrNull((a) => a.id == mg.annualGoalsId);
            if (ag == null || ag.year != selectedYear) continue;

            // Vision
            final vision = visions.firstWhereOrNull((v) => v.id == ag.visionId);
            if (vision == null) continue;

            // Área
            final area = lifeAreas.firstWhereOrNull((a) => a.id == vision.lifeAreaId);
            if (area == null) continue;

            projectsByArea[area.id]!.add(project);
          }

          // Progress bars
          if (!_loadingProgress) _computeProgress(projects);

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
                        onOpen: (p) => _openProject(p),
                        onEdit: (p) => _editProject(p),
                        onDelete: (p) => _deleteProject(p),
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              )
            ],
          );
        },
      ),

      // BOTÃO INFERIOR
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cMainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _createProject,
            child: const Text(
              "Novo Projecto",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
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
