import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/vision_model.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/annual_goal_model.dart';
import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/providers/visions_provider.dart';
import 'package:kwanga/providers/annual_goals_provider.dart';

class VisionsAggregatedData {
  final List<VisionModel> visions;
  final List<LifeAreaModel> areas;
  final List<AnnualGoalModel> goals;

  VisionsAggregatedData({
    required this.visions,
    required this.areas,
    required this.goals,
  });
}

final visionsAggregatedProvider =
Provider<AsyncValue<VisionsAggregatedData>>((ref) {
  final visions = ref.watch(visionsProvider);
  final areas = ref.watch(lifeAreasProvider);
  final goals = ref.watch(annualGoalsProvider);

  if (visions is AsyncLoading ||
      areas is AsyncLoading ||
      goals is AsyncLoading) {
    return const AsyncValue.loading();
  }

  if (visions is AsyncError) {
    return AsyncValue.error(
      visions.error!,
      visions.stackTrace ?? StackTrace.current,
    );
  }

  if (areas is AsyncError) {
    return AsyncValue.error(
      areas.error!,
      areas.stackTrace ?? StackTrace.current,
    );
  }

  if (goals is AsyncError) {
    return AsyncValue.error(
      goals.error!,
      goals.stackTrace ?? StackTrace.current,
    );
  }


  return AsyncValue.data(
    VisionsAggregatedData(
      visions: visions.value!,
      areas: areas.value!,
      goals: goals.value!,
    ),
  );
});
