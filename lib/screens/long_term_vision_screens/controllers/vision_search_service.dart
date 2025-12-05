

import '../../../models/life_area_model.dart';
import '../../../models/vision_model.dart';

class VisionSearchService {
  static bool matchesVision(
      VisionModel vision,
      LifeAreaModel? area,
      String query,
      ) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();

    return vision.description.toLowerCase().contains(q) ||
        (vision.conclusion?.toString().contains(q) ?? false) ||
        (area?.designation.toLowerCase().contains(q) ?? false);
  }

  static bool matchesArea(
      LifeAreaModel area,
      String query,
      ) {
    if (query.isEmpty) return true;
    return area.designation.toLowerCase().contains(query.toLowerCase());
  }
}
