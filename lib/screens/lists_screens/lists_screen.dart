import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';

import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/screens/lists_screens/widgets/list_tile_item.dart';
import 'package:kwanga/screens/lists_screens/widgets/lists_filter_bar.dart';
import 'package:kwanga/screens/task_screens/create_task_screen.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import 'package:kwanga/widgets/custom_drawer.dart';

class ListsScreen extends ConsumerWidget {
  final String listType;

  const ListsScreen({super.key, required this.listType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);
    final selectedFilter = ref.watch(listFilterProvider);
    final selectedIds = ref.watch(selectedListsProvider);

    final normalizedIncomingType = listType;
    final String toDo = normalizedIncomingType == 'entry' ? 'Entrada' : 'Tarefa';

    return Scaffold(
      appBar: AppBar(
        foregroundColor: cWhiteColor,
        backgroundColor: cMainColor,
        title: Text(
          normalizedIncomingType == 'action'
              ? 'Próximas Acções'
              : 'Entradas',
        ),
      ),
      backgroundColor: cWhiteColor,
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Padding(
          padding: defaultPadding,
          child: Column(
            children: [
              // ---------------------------------------------------------
              // FILTRO (somente quando listType não foi definido na rota)
              // ---------------------------------------------------------
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
                  error: (err, stack) =>
                      Center(child: Text('Erro: $err')),

                  // ---------------------------------------------------------
                  // LISTAS CARREGADAS
                  // ---------------------------------------------------------
                  data: (lists) {
                    List<ListModel> filteredLists;

                    // -- CASO 1: tela inicial de listas (tem barra de filtros)
                    if (listType.isEmpty) {
                      if (selectedFilter == 1) {
                        filteredLists = lists
                            .where((l) =>
                        l.listType == 'action')
                            .toList();
                      } else if (selectedFilter == 2) {
                        filteredLists = lists
                            .where((l) =>
                        l.listType == 'entry')
                            .toList();
                      } else {
                        // ordenar: actions primeiro, depois entries
                        filteredLists = [...lists]
                          ..sort((a, b) {
                            final aNorm = a.listType;
                            final bNorm = b.listType;
                            if (aNorm == bNorm) return 0;
                            return aNorm == 'action' ? -1 : 1;
                          });
                      }
                    }

                    // -- CASO 2: rota veio com um tipo definido (action / entry)
                    else {
                      filteredLists = lists
                          .where((l) =>
                      l.listType ==
                          normalizedIncomingType)
                          .toList();
                    }

                    if (filteredLists.isEmpty) {
                      return Center(
                        child: Text(
                          'Nenhuma lista encontrada.',
                          style: tNormal.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
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
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12.0),
                              bottomRight: Radius.circular(12.0),
                            ),
                            child: Container(
                              color: isSelected
                                  ? cTertiaryColor.withAlpha(30)
                                  : null,

                              // 🔥 Passamos SEMPRE o modelo ORIGINAL
                              child: ListTileItem(
                                onTap: () {},
                                onLongPress: () {},
                                isSelected: isSelected,
                                isEditable: true,
                                canViewChildren: true,
                                listModel: list,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // ---------------------------------------------------------
              // BOTÃO "ADICIONAR TAREFA / ENTRADA"
              // ---------------------------------------------------------
              if (normalizedIncomingType.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    final lists = listsAsync.value ?? [];

                    final filtered = lists
                        .where((l) =>
                    l.listType ==
                        normalizedIncomingType)
                        .toList();

                    if (filtered.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Nenhuma lista disponível para adicionar ${toDo}s.'),
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) =>
                            CreateTaskScreen(listModel: filtered.first),
                      ),
                    );
                  },
                  child: MainButton(buttonText: 'Adicionar $toDo'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
