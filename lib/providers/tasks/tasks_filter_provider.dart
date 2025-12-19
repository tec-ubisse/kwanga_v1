import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskFilterProvider =
NotifierProvider<TaskFilterNotifier, int>(TaskFilterNotifier.new);

class TaskFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setFilter(int i) => state = i;
}
