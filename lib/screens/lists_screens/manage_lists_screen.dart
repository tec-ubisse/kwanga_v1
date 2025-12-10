import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/screens/lists_screens/create_lists_screen.dart';
import 'package:kwanga/screens/lists_screens/widgets/list_tile_item.dart';
import 'package:kwanga/screens/lists_screens/widgets/lists_filter_bar.dart';
import 'package:kwanga/widgets/buttons/floating_button.dart';
import 'package:kwanga/widgets/custom_drawer.dart';
import 'package:kwanga/utils/list_type_utils.dart';

class ViewLists extends ConsumerWidget {
  const ViewLists({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLists = ref.watch(listsProvider);
    final isSelectionMode = ref.watch(listSelectionModeProvider);
    final selectedIds = ref.watch(selectedListsProvider);
    final selectedFilter = ref.watch(listFilterProvider);

    final listsNotifier = ref.read(listsProvider.notifier);
    final selectionModeNotifier = ref.read(listSelectionModeProvider.notifier);
    final selectedListsNotifier = ref.read(selectedListsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: cWhiteColor,
        backgroundColor: isSelectionMode ? cSecondaryColor : cMainColor,
        title: isSelectionMode
            ? Text('${selectedIds.length} selecionada(s)')
            : const Text('Gerir Listas'),
        leading: isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            selectionModeNotifier.disable();
            selectedListsNotifier.clear();
          },
        )
            : null,
        actions: isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar selecionadas',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Confirmar eliminação"),
                    content: const Text(
                      "Tem certeza que pretende eliminar todas as listas selecionadas?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Eliminar"),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                listsNotifier.deleteSelected();
                selectionModeNotifier.disable();
                selectedListsNotifier.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Listas eliminadas com sucesso."),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
        ]
            : null,
      ),
      drawer: isSelectionMode ? null : const CustomDrawer(),
      backgroundColor: cWhiteColor,
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
            if (!isSelectionMode)
              ListsFilterBar(
                selectedFilter: selectedFilter,
                onFilterSelected: (index) =>
                    ref.read(listFilterProvider.notifier).setFilter(index),
              ),

            Expanded(
              child: asyncLists.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Ocorreu um erro: $err')),

                data: (lists) {
                  // Applying filters
                  final filtered = _applyFilter(lists, selectedFilter);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma lista encontrada.',
                        style: tNormal.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final list = filtered[index];
                      final isSelected = selectedIds.contains(list.id);

                      // Tap toggles selection when in selection mode; otherwise opens editor
                      void handleTap() {
                        if (isSelectionMode) {
                          selectedListsNotifier.toggle(list.id);

                          // if no items left selected -> exit selection mode
                          if (ref.read(selectedListsProvider).isEmpty) {
                            selectionModeNotifier.disable();
                          }
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CreateOrEditListScreen(existingList: list),
                            ),
                          );
                        }
                      }

                      // Long press enables selection mode and toggles the item
                      void handleLongPress() {
                        if (!isSelectionMode) {
                          selectionModeNotifier.enable();
                        }
                        selectedListsNotifier.toggle(list.id);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cSecondaryColor
                                : const Color(0xffEAEFF4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListTileItem(
                                  onTap: handleTap,
                                  onLongPress: handleLongPress,
                                  canViewChildren: false,
                                  isEditable: false,
                                  listModel: list.copyWith(
                                    listType: normalizeListType(list.listType),
                                  ),
                                  isSelected: isSelected,
                                ),
                              ),
                              isSelected
                                  ? const Padding(
                                padding: EdgeInsets.only(right: 12.0),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              )
                                  : PopupMenuButton<String>(
                                borderRadius: BorderRadius.circular(24.0),
                                elevation: 0,
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CreateOrEditListScreen(
                                              existingList: list,
                                            ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                            "Confirmar eliminação",
                                          ),
                                          content: Text(
                                            "Tem a certeza que pretende eliminar a lista \"${list.description}\"?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text(
                                                "Cancelar",
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text(
                                                "Eliminar",
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmed == true) {
                                      listsNotifier.deleteOne(list.id);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Lista eliminada com sucesso."),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 18),
                                        SizedBox(width: 8),
                                        Text('Eliminar'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
      floatingActionButton: !isSelectionMode
          ? FloatingButton(navigateTo: const CreateOrEditListScreen())
          : null,
    );
  }

  // filter logic
  List<ListModel> _applyFilter(List<ListModel> lists, int filter) {
    final normalized = lists
        .map((l) => l.copyWith(listType: normalizeListType(l.listType)))
        .toList();

    if (filter == 1) {
      return normalized.where((l) => l.listType == 'action').toList();
    } else if (filter == 2) {
      return normalized.where((l) => l.listType == 'entry').toList();
    } else {
      return normalized;
    }
  }
}
