import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';

import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/screens/lists_screens/widgets/list_tile_item.dart';
import 'package:kwanga/screens/lists_screens/widgets/lists_filter_bar.dart';
import 'package:kwanga/screens/task_screens/create_task_screen.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';

import '../task_screens/new_task.dart';

class ListsScreen extends ConsumerWidget {
  final String listType;

  const ListsScreen({super.key, required this.listType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);
    final selectedFilter = ref.watch(listFilterProvider);
    final selectedIds = ref.watch(selectedListsProvider);

    // Texto para UI baseado no tipo
    final String toDo = listType == 'entry' ? 'Entrada' : 'Tarefa';
    final String appBarTitle =
    listType == 'action' ? 'Próximas Acções' : 'Entradas';

    return Scaffold(
      appBar: AppBar(
        foregroundColor: cWhiteColor,
        backgroundColor: cMainColor,
        title: Text(appBarTitle),
      ),
      backgroundColor: cWhiteColor,
      drawer: const CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
            // Filtro (somente quando listType está vazio)
            if (listType.isEmpty)
              ListsFilterBar(
                selectedFilter: selectedFilter,
                onFilterSelected: (index) =>
                    ref.read(listFilterProvider.notifier).setFilter(index),
              ),

            Expanded(
              child: listsAsync.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Erro: $err')),
                data: (lists) {
                  List<ListModel> filteredLists;

                  // CASO 1: tela inicial de listas (tem barra de filtros)
                  if (listType.isEmpty) {
                    if (selectedFilter == 1) {
                      filteredLists = lists
                          .where((l) => l.listType == 'action')
                          .toList();
                    } else if (selectedFilter == 2) {
                      filteredLists = lists
                          .where((l) => l.listType == 'entry')
                          .toList();
                    } else {
                      // ordenar: actions primeiro, depois entries
                      filteredLists = [...lists]
                        ..sort((a, b) {
                          if (a.listType == b.listType) return 0;
                          return a.listType == 'action' ? -1 : 1;
                        });
                    }
                  }
                  // CASO 2: rota veio com um tipo definido (action / entry)
                  else {
                    filteredLists =
                        lists.where((l) => l.listType == listType).toList();
                  }

                  if (filteredLists.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma lista encontrada.',
                        style: tNormal.copyWith(fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredLists.length,
                    itemBuilder: (context, index) {
                      final list = filteredLists[index];
                      final isSelected = selectedIds.contains(list.id);

                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            12.0
                          ),
                          child: Container(
                            color: isSelected
                                ? cTertiaryColor.withAlpha(30)
                                : null,
                            child: ListTileItem(
                              onTap: () {},
                              onLongPress: () {},
                              isSelected: isSelected,
                              isEditable: true,
                              canViewChildren: true,
                              listModel: list,
                              showProgress: true, // ✅ Mostra o círculo de progresso
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: listsAsync.when(
        loading: () =>
            BottomActionBar(buttonText: 'Adicionar $toDo', onPressed: () {}),
        error: (_, __) =>
            BottomActionBar(buttonText: 'Adicionar $toDo', onPressed: () {}),
        data: (lists) {
          final filteredLists =
          lists.where((l) => l.listType == listType).toList();

          if (filteredLists.isEmpty) {
            return BottomActionBar(
              buttonText: 'Adicionar $toDo',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Crie uma lista primeiro antes de adicionar tarefas.',
                    ),
                  ),
                );
              },
            );
          }

          final defaultList = filteredLists.first;

          return BottomActionBar(
            buttonText: 'Adicionar $toDo',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => NewTaskScreen(listModel: defaultList),
                ),
              );
            },
          );
        },
      ),
    );
  }
}