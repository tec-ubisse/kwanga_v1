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
import 'package:kwanga/utils/list_type_utils.dart'; // <-- IMPORTANTE

class ListsScreen extends ConsumerWidget {
  final String listType;

  const ListsScreen({super.key, required this.listType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);
    final selectedFilter = ref.watch(listFilterProvider);
    final selectedIds = ref.watch(selectedListsProvider);

    final normalizedIncomingType = normalizeListType(listType);
    final String toDo =
    normalizedIncomingType == 'entry' ? 'Entrada' : 'Tarefa';

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
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
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
                data: (lists) {
                  List<ListModel> filteredLists;

                  /// ---- LIST TYPE EMPTY → Using Filter bar
                  if (listType.isEmpty) {
                    final normalized = lists
                        .map((l) => l.copyWith(
                        listType: normalizeListType(l.listType)))
                        .toList();

                    if (selectedFilter == 1) {
                      filteredLists = normalized
                          .where((l) => l.listType == 'action')
                          .toList();
                    } else if (selectedFilter == 2) {
                      filteredLists = normalized
                          .where((l) => l.listType == 'entry')
                          .toList();
                    } else {
                      filteredLists = List.from(normalized)
                        ..sort((a, b) {
                          if (a.listType == b.listType) return 0;
                          if (a.listType == 'action') return -1;
                          return 1;
                        });
                    }
                  }

                  /// ---- LIST TYPE PROVIDED IN ROUTE
                  else {
                    filteredLists = lists
                        .where((l) =>
                    normalizeListType(l.listType) ==
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
                            child: ListTileItem(
                              onTap: () {},
                              onLongPress: () {},
                              isSelected: false,
                              isEditable: true,
                              canViewChildren: true,
                              listModel: list.copyWith(
                                listType:
                                normalizeListType(list.listType),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            if (normalizedIncomingType.isNotEmpty)
              GestureDetector(
                onTap: () {
                  final lists = listsAsync.value ?? [];
                  final filtered = lists
                      .where((l) =>
                  normalizeListType(l.listType) ==
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
    );
  }
}
