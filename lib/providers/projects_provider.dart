// lib/providers/projects_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:kwanga/models/project_model.dart';
import 'package:kwanga/models/list_model.dart';

import 'package:kwanga/data/database/projects_dao.dart';
import 'package:kwanga/data/database/lists_dao.dart';

import 'auth_provider.dart';

final projectsProvider =
AsyncNotifierProvider<ProjectsNotifier, List<ProjectModel>>(
    ProjectsNotifier.new);

class ProjectsNotifier extends AsyncNotifier<List<ProjectModel>> {
  final _dao = ProjectsDao();
  final _listsDao = ListDao();
  final _uuid = const Uuid();

  @override
  Future<List<ProjectModel>> build() async {
    final auth = ref.watch(authProvider);
    final user = auth.value;

    if (user == null || user.id == null) return [];
    return await _dao.getProjectsByUserId(user.id!);
  }

  /// ------------------------------------------------------------
  /// LOAD PROJECTS
  /// ------------------------------------------------------------
  Future<void> loadByUserId(int userId) async {
    final projects = await _dao.getProjectsByUserId(userId);
    state = AsyncData(projects);
  }

  Future<void> loadByMonthlyGoalId(String monthlyGoalId) async {
    final projects = await _dao.getProjectsByMonthlyGoalId(monthlyGoalId);
    state = AsyncData(projects);
  }

  /// ------------------------------------------------------------
  /// ADD PROJECT
  /// ------------------------------------------------------------
  Future<void> addProject({
    required int userId,
    required String monthlyGoalId,
    required String title,
    required String purpose,
    required String expectedResult,
    List<String> brainstormIdeas = const [],
    String? firstAction,
  }) async {
    final newProject = ProjectModel(
      id: _uuid.v4(),
      userId: userId,
      monthlyGoalId: monthlyGoalId,
      title: title.trim(),
      purpose: purpose.trim(),
      expectedResult: expectedResult.trim(),
      brainstormIdeas: brainstormIdeas,
      firstAction: firstAction,
      isDeleted: false,
      isSynced: false,
    );

    // Save project
    await _dao.createProject(newProject);

    // ------------------------------------------------------------
    // CREATE INTERNAL LIST FOR PROJECT ACTIONS
    // ------------------------------------------------------------
    final listId = "project-${newProject.id}";

    final projectList = ListModel(
      id: listId,
      userId: userId,
      listType: "action",
      description: "Ações do projecto: ${newProject.title}",
      isDeleted: false,
      isSynced: false,
      isProject: true, // <-- ESSENCIAL: nunca deve aparecer ao utilizador
    );

    try {
      await _listsDao.insert(projectList);
    } catch (e) {
      // Ignore duplicate errors
    }

    // ------------------------------------------------------------
    // UPDATE STATE
    // ------------------------------------------------------------
    final current = state.value ?? [];
    state = AsyncData([...current, newProject]);
  }

  /// ------------------------------------------------------------
  /// DELETE PROJECT
  /// ------------------------------------------------------------
  Future<void> removeProject(String projectId) async {
    await _dao.deleteProject(projectId);

    final current = state.value ?? [];
    state = AsyncData(
      current.where((p) => p.id != projectId).toList(),
    );

    // Não apagamos a lista interna explicitamente,
    // mas ela NUNCA aparece na UI por causa do "isProject".
  }

  /// ------------------------------------------------------------
  /// EDIT PROJECT
  /// ------------------------------------------------------------
  Future<void> editProject(ProjectModel updatedProject) async {
    await _dao.updateProject(updatedProject);

    final current = state.value ?? [];

    state = AsyncData([
      for (final p in current)
        if (p.id == updatedProject.id) updatedProject else p
    ]);
  }

  final projectsByIdProvider = Provider<Map<String, String>>((ref) {
    final asyncProjects = ref.watch(projectsProvider);

    return asyncProjects.when(
      data: (projects) => {
        for (final p in projects) p.id: p.title,
      },
      loading: () => {},
      error: (_, __) => {},
    );
  });
}
