import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/data/database/annual_goals_dao.dart';
import 'package:uuid/uuid.dart';

import 'auth_provider.dart';

final annualGoalsProvider =
AsyncNotifierProvider<AnnualGoalsNotifier, List<AnnualGoalModel>>(() {
  return AnnualGoalsNotifier();
});

class AnnualGoalsNotifier extends AsyncNotifier<List<AnnualGoalModel>> {
  final _dao = AnnualGoalsDao();
  final _uuid = const Uuid();

  @override
  Future<List<AnnualGoalModel>> build() async {
    final auth = ref.read(authProvider);
    final user = auth.value;

    if (user == null || user.id == null) {
      return [];
    }

    // Carrega automaticamente as metas anuais do usuário
    return await _dao.getAnnualGoalsByUserId(user.id!);
  }

  Future<void> loadByUserId(int userId) async {
    final goals = await _dao.getAnnualGoalsByUserId(userId);
    state = AsyncData(goals);
  }

  Future<void> loadByVision(String visionId) async {
    final goals = await _dao.getAnnualGoalsByVisionId(visionId);
    state = AsyncData(goals);
  }

  Future<void> addAnnualGoal({
    required int userId,
    required String visionId,
    required String description,
    required int year,
  }) async {
    final newGoal = AnnualGoalModel(
      id: _uuid.v4(),
      userId: userId,
      visionId: visionId,
      description: description.trim(),
      year: year,
      isDeleted: false,
      isSynced: false,
    );

    await _dao.createAnnualGoal(newGoal);

    final current = state.value ?? [];
    state = AsyncData([...current, newGoal]);
  }

  Future<void> removeAnnualGoal(String goalId) async {
    await _dao.deleteAnnualGoal(goalId);

    final current = state.value ?? [];
    state = AsyncData(current.where((g) => g.id != goalId).toList());
  }

  Future<void> editAnnualGoal(AnnualGoalModel updatedGoal) async {
    await _dao.updateAnnualGoal(updatedGoal);

    final current = state.value ?? [];

    state = AsyncData([
      for (final g in current)
        if (g.id == updatedGoal.id) updatedGoal else g,
    ]);
  }
}
