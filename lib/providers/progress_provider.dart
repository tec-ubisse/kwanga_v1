import 'package:flutter_riverpod/flutter_riverpod.dart';

final progressByListProvider =
NotifierProvider<ProgressByListNotifier, Map<String, Map<String, int>>>(
  ProgressByListNotifier.new,
);

class ProgressByListNotifier extends Notifier<Map<String, Map<String, int>>> {
  @override
  Map<String, Map<String, int>> build() => {};

  Map<String, int> _empty() => {'total': 0, 'completed': 0};

  /// Substitui o estado de uma lista
  void set(String listId, int total, int completed) {
    state = {
      ...state,
      listId: {'total': total, 'completed': completed},
    };
  }

  /// Substitui todo o mapa (usado na carga inicial)
  void replaceAll(Map<String, Map<String, int>> map) {
    // Garantir cópia defensiva
    state = Map<String, Map<String, int>>.from(map);
  }

  /// Atualiza incremental (ainda útil em certos casos)
  void updateCounts(
      String listId, {
        int? totalDelta,
        int? completedDelta,
      }) {
    final prev = state[listId] ?? _empty();

    final total = (prev['total'] ?? 0) + (totalDelta ?? 0);
    final completed = (prev['completed'] ?? 0) + (completedDelta ?? 0);

    state = {
      ...state,
      listId: {
        'total': total < 0 ? 0 : total,
        'completed': completed < 0 ? 0 : completed,
      },
    };
  }

  /// Remove lista
  void removeList(String listId) {
    final newState = {...state};
    newState.remove(listId);
    state = newState;
  }
}
