// lib/providers/cached_task_lists_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/models/list_model.dart';
import 'task_list_provider.dart'; // ajusta o path se preciso

final cachedTaskListsProvider = FutureProvider.autoDispose<List<ListModel>>((ref) async {
  // Se taskListsProvider já tem dados, devolve-os; caso contrário aguarda o carregamento.
  final asyncLists = ref.watch(taskListsProvider);
  if (asyncLists.isLoading) {
    // espera o futuro para evitar abrir dialog vazio
    final lists = await ref.watch(taskListsProvider.future);
    return lists;
  }
  return asyncLists.value ?? <ListModel>[];
});
