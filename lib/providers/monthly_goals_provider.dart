import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/monthly_goal_model.dart';
import 'package:kwanga/data/database/monthly_goals_dao.dart';
import 'package:uuid/uuid.dart';

import 'auth_provider.dart';

/// Provider para buscar UMA meta mensal pelo ID
final monthlyGoalByIdProvider =
Provider.family<MonthlyGoalModel?, String>((ref, id) {
  final listAsync = ref.watch(monthlyGoalsProvider);

  // Se está a carregar ou tem erro, devolvemos null (o consumidor tratará isto)
  if (listAsync.isLoading || listAsync.hasError) return null;

  final list = listAsync.value ?? [];

  // Evita firstWhere(... orElse: () => null) para não ter conflitos de tipos.
  for (final g in list) {
    if (g.id == id) return g;
  }

  return null; // não encontrado
});


final monthlyGoalsProvider =
AsyncNotifierProvider<MonthlyGoalsNotifier, List<MonthlyGoalModel>>(() {
  return MonthlyGoalsNotifier();
});

class MonthlyGoalsNotifier extends AsyncNotifier<List<MonthlyGoalModel>> {
  final _dao = MonthlyGoalsDao();
  final _uuid = const Uuid();

  @override
  Future<List<MonthlyGoalModel>> build() async {
    final auth = ref.read(authProvider);
    final user = auth.value;

    if (user == null || user.id == null) {
      return [];
    }

    // Carrega metas do usuário automaticamente
    return await _dao.getMonthlyGoalsByUserId(user.id!);
  }

  Future<void> loadByUserId(int userId) async {
    final goals = await _dao.getMonthlyGoalsByUserId(userId);
    state = AsyncData(goals);
  }

  Future<void> loadByAnnualGoal(String annualGoalId) async {
    final goals = await _dao.getMonthlyGoalsByAnnualGoalId(annualGoalId);
    state = AsyncData(goals);
  }

  Future<void> addMonthlyGoal({
    required int userId,
    required String annualGoalsId,
    required String description,
    required int month,
  }) async {
    final newGoal = MonthlyGoalModel(
      id: _uuid.v4(),
      userId: userId,
      annualGoalsId: annualGoalsId,
      description: description.trim(),
      month: month,
      isDeleted: false,
      isSynced: false,
    );

    await _dao.createMonthlyGoal(newGoal);

    final current = state.value ?? [];
    state = AsyncData([...current, newGoal]);
  }

  Future<void> removeMonthlyGoal(String goalId) async {
    await _dao.deleteMonthlyGoal(goalId);

    final current = state.value ?? [];
    state = AsyncData(current.where((g) => g.id != goalId).toList());
  }

  Future<void> editMonthlyGoal(MonthlyGoalModel updatedGoal) async {
    await _dao.updateMonthlyGoal(updatedGoal);

    final current = state.value ?? [];

    state = AsyncData([
      for (final g in current)
        if (g.id == updatedGoal.id) updatedGoal else g,
    ]);
  }
}
