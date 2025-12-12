import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/list_model.dart';
import 'task_list_provider.dart';

final cachedTaskListsProvider =
FutureProvider.autoDispose<List<ListModel>>((ref) async {
  final asyncLists = ref.watch(taskListsProvider);

  return asyncLists.maybeWhen(
    data: (lists) => lists,
    orElse: () => ref.watch(taskListsProvider.future),
  );
});
