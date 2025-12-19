import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskSelectionModeProvider =
NotifierProvider<TaskSelectionModeNotifier, bool>(
    TaskSelectionModeNotifier.new);

class TaskSelectionModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enable() => state = true;
  void disable() => state = false;
}

final selectedTasksProvider =
NotifierProvider<SelectedTasksNotifier, Set<String>>(
    SelectedTasksNotifier.new);

class SelectedTasksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final copy = Set<String>.from(state);
    copy.contains(id) ? copy.remove(id) : copy.add(id);
    state = copy;
  }

  void clear() => state = {};
}
