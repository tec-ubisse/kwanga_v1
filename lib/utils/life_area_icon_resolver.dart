import '../models/life_area_model.dart';

String resolveLifeAreaIconPath(LifeAreaModel area) {
  if (!area.isSystem) return area.iconPath;

  if (area.iconPath.startsWith('assets/')) {
    return area.iconPath;
  }

  return 'assets/icons/${area.iconPath}.png';
}