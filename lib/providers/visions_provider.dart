import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/vision_model.dart';
import 'package:kwanga/data/database/visions_dao.dart';
import 'package:uuid/uuid.dart';

import 'auth_provider.dart';

final visionsProvider =
AsyncNotifierProvider<VisionsNotifier, List<VisionModel>>(() {
  return VisionsNotifier();
});

class VisionsNotifier extends AsyncNotifier<List<VisionModel>> {
  final _dao = VisionsDao();
  final _uuid = const Uuid();

  @override
  Future<List<VisionModel>> build() async {
    final auth = ref.read(authProvider);
    final user = auth.value;

    if (user == null || user.id == null) {
      return [];
    }

    // Carregar automaticamente sempre que entrar no app
    return await _dao.getVisionsByUserId(user.id!);
  }

  Future<void> loadVisions(int userId) async {
    final visions = await _dao.getVisionsByUserId(userId);
    state = AsyncData(visions);
  }

  Future<void> loadVisionsByArea(String lifeAreaId) async {
    final visions = await _dao.getVisionsByLifeAreaId(lifeAreaId);
    state = AsyncData(visions);
  }

  Future<void> addVision({
    required int userId,
    required String lifeAreaId,
    required String description,
    required int conclusion,
  }) async {
    final newVision = VisionModel(
      id: _uuid.v4(),
      userId: userId,
      lifeAreaId: lifeAreaId,
      conclusion: conclusion,
      description: description.trim(),
      isDeleted: false,
      isSynced: false,
    );

    await _dao.createVision(newVision);

    final current = state.value ?? [];
    state = AsyncData([...current, newVision]);
  }

  Future<void> deleteVision(String visionId) async {
    await _dao.deleteVision(visionId);

    final current = state.value ?? [];
    state = AsyncData(current.where((v) => v.id != visionId).toList());
  }

  Future<void> editVision(VisionModel updatedVision) async {
    await _dao.updateVision(updatedVision);

    final current = state.value ?? [];

    state = AsyncData([
      for (final v in current)
        if (v.id == updatedVision.id) updatedVision else v,
    ]);
  }
}
