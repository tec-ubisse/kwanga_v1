import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/data/database/life_area_dao.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

final lifeAreaDaoProvider = Provider((ref) => LifeAreaDao());

class LifeAreasNotifier extends AsyncNotifier<List<LifeAreaModel>> {
  @override
  Future<List<LifeAreaModel>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null || user.id == null) return [];

    return _load(user.id!);
  }

  Future<List<LifeAreaModel>> _load(int userId) async {
    final dao = ref.read(lifeAreaDaoProvider);

    final userAreas = await dao.getUserLifeAreas(userId);
    final systemAreas = await dao.getSystemLifeAreas();

    return [...systemAreas, ...userAreas];
  }

  Future<void> addLifeArea({
    required String designation,
    required String iconPath,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.id == null) return;

    final newArea = LifeAreaModel(
      id: const Uuid().v4(),
      userId: user.id!,
      designation: designation,
      iconPath: iconPath,
      isSystem: false,
      isDeleted: false,
      isSynced: false,
    );

    await ref.read(lifeAreaDaoProvider).insertLifeArea(newArea);
    ref.invalidateSelf();
  }

  Future<void> updateLifeArea(LifeAreaModel area) async {
    if (area.isSystem) {
      print("⚠ Área de sistema não pode ser atualizada.");
      return;
    }

    await ref.read(lifeAreaDaoProvider).updateLifeArea(area);
    ref.invalidateSelf();
  }

  Future<void> deleteLifeArea(String id) async {
    final area = await ref.read(lifeAreaDaoProvider).getById(id);
    if (area == null) return;

    if (area.isSystem) {
      print("⚠ Área de sistema não pode ser apagada.");
      return;
    }

    await ref.read(lifeAreaDaoProvider).softDeleteLifeArea(id);
    ref.invalidateSelf();
  }

  Future<void> restoreLifeArea(String id) async {
    await ref.read(lifeAreaDaoProvider).restoreLifeArea(id);
    ref.invalidateSelf();

  }

  Future<void> syncPending() async {
    print("🔄 Sincronização de Life Areas pendente...");
    await Future.delayed(const Duration(seconds: 1));
    ref.invalidateSelf();
  }
}

/// Provider exposto para a UI
final lifeAreasProvider =
AsyncNotifierProvider<LifeAreasNotifier, List<LifeAreaModel>>(
  LifeAreasNotifier.new,
);
