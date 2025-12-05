import '../../../models/vision_model.dart';
import '../../../models/life_area_model.dart';

class VisionAggregationService {
  static Map<String, dynamic> aggregate({
    required List<VisionModel> visions,
    required List<LifeAreaModel> areas,
  }) {
    // Map para lookup
    final areasMap = {for (var a in areas) a.id: a};

    // Visões válidas
    final validVisions = visions.where((v) => areasMap.containsKey(v.lifeAreaId)).toList();

    // Áreas sem visão
    final areasWithVisions = validVisions.map((v) => v.lifeAreaId).toSet();
    final areasWithoutVision =
    areas.where((a) => !areasWithVisions.contains(a.id)).toList();

    // Ordenar
    validVisions.sort((a, b) =>
        a.description.toLowerCase().compareTo(b.description.toLowerCase()));

    areasWithoutVision.sort((a, b) =>
        a.designation.toLowerCase().compareTo(b.designation.toLowerCase()));

    // Anos disponíveis
    final years = validVisions
        .map((v) => v.conclusion)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();

    return {
      "validVisions": validVisions,
      "areasWithoutVision": areasWithoutVision,
      "areasMap": areasMap,
      "years": years,
    };
  }
}
