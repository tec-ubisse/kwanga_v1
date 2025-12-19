import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:kwanga/models/purpose_model.dart';
import 'package:kwanga/data/database/purpose_dao.dart';
import 'package:kwanga/providers/auth_provider.dart';

final purposesProvider =
AsyncNotifierProvider<PurposesNotifier, List<PurposeModel>>(
  PurposesNotifier.new,
);

class PurposesNotifier extends AsyncNotifier<List<PurposeModel>> {
  final _dao = PurposeDao();
  final _uuid = const Uuid();

  @override
  Future<List<PurposeModel>> build() async {
    final auth = ref.watch(authProvider);
    final user = auth.value;

    if (user == null || user.id == null) return [];

    // carrega TODOS os propósitos do utilizador
    return await _dao.getByUser(user.id!);
  }

  // ----------------------------------------------------------
  // LOAD POR ÁREA DA VIDA
  // ----------------------------------------------------------
  Future<void> loadByLifeArea(String lifeAreaId) async {
    final auth = ref.read(authProvider);
    final user = auth.value;
    if (user?.id == null) return;

    final purposes =
    await _dao.getByLifeArea(user!.id!, lifeAreaId);

    state = AsyncData(purposes);
  }

  // ----------------------------------------------------------
  // ADD PURPOSE
  // ----------------------------------------------------------
  Future<void> addPurpose({
    required String lifeAreaId,
    required String description,
  }) async {
    final auth = ref.read(authProvider);
    final user = auth.value;
    if (user?.id == null) return;

    final newPurpose = PurposeModel(
      id: _uuid.v4(),
      userId: user!.id!,
      lifeAreaId: lifeAreaId,
      description: description.trim(),
      isDeleted: false,
      isSynced: false,
    );

    await _dao.insert(newPurpose);

    final current = state.value ?? [];
    state = AsyncData([...current, newPurpose]);
  }

  // ----------------------------------------------------------
  // EDIT PURPOSE
  // ----------------------------------------------------------
  Future<void> editPurpose(PurposeModel updatedPurpose) async {
    await _dao.update(updatedPurpose);

    final current = state.value ?? [];

    state = AsyncData([
      for (final p in current)
        if (p.id == updatedPurpose.id) updatedPurpose else p,
    ]);
  }

  // ----------------------------------------------------------
  // DELETE PURPOSE
  // ----------------------------------------------------------
  Future<void> removePurpose(String purposeId) async {
    await _dao.softDelete(purposeId);

    final current = state.value ?? [];
    state = AsyncData(
      current.where((p) => p.id != purposeId).toList(),
    );
  }
}

final purposeByLifeAreaProvider =
Provider.family<PurposeModel, String>((ref, lifeAreaId) {
  final purposesAsync = ref.watch(purposesProvider);

  return purposesAsync.maybeWhen(
    data: (purposes) {
      try {
        return purposes.firstWhere(
              (p) =>
          p.lifeAreaId == lifeAreaId &&
              !p.isDeleted,
        );
      } catch (_) {
        return PurposeModel.empty();
      }
    },
    orElse: () => PurposeModel.empty(),
  );
});