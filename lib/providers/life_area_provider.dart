import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/data/database/life_area_dao.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

final lifeAreaDaoProvider = Provider<LifeAreaDao>(
      (ref) => LifeAreaDao(),
);

class LifeAreasNotifier extends AsyncNotifier<List<LifeAreaModel>> {
  // ----------------------------------------------------------
  // BUILD — reage corretamente ao authProvider
  // ----------------------------------------------------------
  @override
  Future<List<LifeAreaModel>> build() async {
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      data: (user) async {
        if (user == null || user.id == null) {
          return [];
        }

        return _load(user.id!);
      },
      loading: () async => [],
      error: (_, __) async => [],
    );
  }

  // ----------------------------------------------------------
  // LOAD — system + user (ordenado no DAO)
  // ----------------------------------------------------------
  Future<List<LifeAreaModel>> _load(int userId) async {
    final dao = ref.read(lifeAreaDaoProvider);
    return dao.getLifeAreasForUser(userId);
  }

  // ----------------------------------------------------------
  // ADD — entra no FINAL da lista
  // ----------------------------------------------------------
  Future<void> addLifeArea({
    required String designation,
    required String iconPath,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.id == null) return;

    final current = state.value ?? [];
    final nextOrder = current.length;

    final newArea = LifeAreaModel(
      id: const Uuid().v4(),
      userId: user.id!,
      designation: designation,
      iconPath: iconPath,
      isSystem: false,
      isDeleted: false,
      isSynced: false,
      order: nextOrder,
    );

    await ref.read(lifeAreaDaoProvider).insertLifeArea(newArea);

    // força reload (system + user)
    ref.invalidateSelf();
  }

  // ----------------------------------------------------------
  // UPDATE — dados básicos (user only)
  // ----------------------------------------------------------
  Future<void> updateLifeArea(LifeAreaModel area) async {
    if (area.isSystem) {
      return;
    }

    await ref.read(lifeAreaDaoProvider).updateLifeArea(area);
    ref.invalidateSelf();
  }

  // ----------------------------------------------------------
  // DELETE — soft delete (user only)
  // ----------------------------------------------------------
  Future<void> deleteLifeArea(String id) async {
    final area = await ref.read(lifeAreaDaoProvider).getById(id);
    if (area == null) return;

    if (area.isSystem) {
      return;
    }

    await ref.read(lifeAreaDaoProvider).softDeleteLifeArea(id);
    ref.invalidateSelf();
  }

  // ----------------------------------------------------------
  // RESTORE
  // ----------------------------------------------------------
  Future<void> restoreLifeArea(String id) async {
    await ref.read(lifeAreaDaoProvider).restoreLifeArea(id);
    ref.invalidateSelf();
  }

  // ----------------------------------------------------------
  // REORDER — UX otimista + persistência
  // ----------------------------------------------------------
  Future<void> reorder(int oldIndex, int newIndex) async {
    final List<LifeAreaModel> current =
    List<LifeAreaModel>.from(state.value ?? []);

    if (oldIndex < 0 || newIndex < 0) return;
    if (oldIndex >= current.length || newIndex >= current.length) return;

    final moved = current.removeAt(oldIndex);
    current.insert(newIndex, moved);

    // UI imediata
    state = AsyncData(current);

    // persistência
    await ref.read(lifeAreaDaoProvider).updateOrder(current);
  }

  // ----------------------------------------------------------
  // SYNC (placeholder)
  // ----------------------------------------------------------
  Future<void> syncPending() async {
    await Future.delayed(const Duration(seconds: 1));
    ref.invalidateSelf();
  }
}

// ----------------------------------------------------------
// PROVIDER EXPOSO PARA A UI
// ----------------------------------------------------------
final lifeAreasProvider =
AsyncNotifierProvider<LifeAreasNotifier, List<LifeAreaModel>>(
  LifeAreasNotifier.new,
);
