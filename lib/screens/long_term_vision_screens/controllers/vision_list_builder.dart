import 'package:kwanga/models/vision_model.dart';
import 'package:kwanga/models/life_area_model.dart';

class VisionListBuilder {
  static List<dynamic> build({
    required List<VisionModel> visions,
    required List<LifeAreaModel> areas,
  }) {
    final areasComVisao = visions.map((v) => v.lifeAreaId).toSet();

    final areasSemVisao = areas.where((a) => !areasComVisao.contains(a.id));

    return [
      ...visions,      // VisionModel
      ...areasSemVisao // LifeAreaModel
    ];
  }
}
