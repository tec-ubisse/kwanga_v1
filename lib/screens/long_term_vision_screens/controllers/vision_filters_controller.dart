import '../../../models/vision_model.dart';
import '../../../models/life_area_model.dart';

class VisionFiltersController {
  String activeFilter = "all";
  int? selectedYear;

  void setFilter(String filter) {
    activeFilter = filter;
  }

  void setYear(int? year) {
    selectedYear = year;
  }

  bool passesMainFilters(dynamic item, Map<String, dynamic> data) {
    final goals = data["goals"] as List;
    final areasMap = data["areasMap"] as Map<String, LifeAreaModel>;

    // --- ANO ---
    if (item is VisionModel && selectedYear != null) {
      if (item.conclusion != selectedYear) return false;
    }

    // --- FILTROS PRINCIPAIS ---
    switch (activeFilter) {
      case "withVision":
        if (item is LifeAreaModel) return false;
        break;

      case "withoutVision":
        if (item is VisionModel) return false;
        break;

      case "withGoals":
        if (item is VisionModel) {
          final count = goals.where((g) => g.visionId == item.id).length;
          if (count == 0) return false;
        } else return false;
        break;

      case "withoutGoals":
        if (item is VisionModel) {
          final count = goals.where((g) => g.visionId == item.id).length;
          if (count > 0) return false;
        } else return false;
        break;
    }

    return true;
  }
}
