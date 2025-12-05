import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:kwanga/models/project_model.dart';
import 'package:kwanga/data/database/projects_dao.dart';

import 'auth_provider.dart';

final projectsProvider =
AsyncNotifierProvider<ProjectsNotifier, List<ProjectModel>>(() {
  return ProjectsNotifier();
});

class ProjectsNotifier extends AsyncNotifier<List<ProjectModel>> {
  final _dao = ProjectsDao();
  final _uuid = const Uuid();

  @override
  Future<List<ProjectModel>> build() async {
    final auth = ref.read(authProvider);
    final user = auth.value;

    if (user == null || user.id == null) {
      return [];
    }

    /// Carrega automaticamente os projetos do usuário logado
    return await _dao.getProjectsByUserId(user.id!);
  }

  /// --- LOADERS ---

  Future<void> loadByUserId(int userId) async {
    final projects = await _dao.getProjectsByUserId(userId);
    state = AsyncData(projects);
  }

  Future<void> loadByMonthlyGoalId(String monthlyGoalId) async {
    final projects = await _dao.getProjectsByMonthlyGoalId(monthlyGoalId);
    state = AsyncData(projects);
  }

  /// --- CREATE ---

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

    await _dao.createProject(newProject);

    final current = state.value ?? [];
    state = AsyncData([...current, newProject]);
  }

  /// --- DELETE (soft delete) ---

  Future<void> removeProject(String projectId) async {
    await _dao.deleteProject(projectId);

    final current = state.value ?? [];
    state = AsyncData(current.where((p) => p.id != projectId).toList());
  }

  /// --- UPDATE ---

  Future<void> editProject(ProjectModel updatedProject) async {
    await _dao.updateProject(updatedProject);

    final current = state.value ?? [];

    state = AsyncData([
      for (final p in current)
        if (p.id == updatedProject.id) updatedProject else p,
    ]);
  }
}
