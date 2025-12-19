import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/screens/lists_screens/create_lists_screen.dart';
import 'package:kwanga/screens/lists_screens/widgets/list_tile_item.dart';
import 'package:kwanga/screens/lists_screens/widgets/lists_filter_bar.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';
import 'package:kwanga/widgets/dialogs/kwanga_delete_dialog.dart';

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
                error: (err, _) => Center(child: Text('Erro: $err')),
                data: (lists) {
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

                      void handleTap() {
                        if (isSelectionMode) {
                          selectedListsNotifier.toggle(list.id);
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

                      void handleLongPress() {
                        if (!isSelectionMode) {
                          selectionModeNotifier.enable();
                        }
                        selectedListsNotifier.toggle(list.id);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(12.0),
                          child: Slidable(
                            key: ValueKey(list.id),
                            enabled: !isSelectionMode,
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.45,
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CreateOrEditListScreen(
                                          existingList: list,
                                        ),
                                      ),
                                    );
                                  },
                                  backgroundColor: cSecondaryColor,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Editar',
                                ),
                                SlidableAction(
                                  onPressed: (_) async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return KwangaDeleteDialog(
                                          title: 'Eliminar lista',
                                          message:
                                              'Tem certeza que pretende eliminar a lista ${list.description}? Esta acção é irreversível',
                                        );
                                      },
                                    );

                                    if (confirmed == true) {
                                      listsNotifier.deleteOne(list.id);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Lista eliminada com sucesso.",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: cTertiaryColor,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Eliminar',
                                ),
                              ],
                            ),
                            child: ListTileItem(
                              onTap: handleTap,
                              onLongPress: handleLongPress,
                              canViewChildren: false,
                              isEditable: false,
                              listModel: list,
                              isSelected: isSelected,
                              showProgress: false,
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
      bottomNavigationBar: BottomActionBar(
        buttonText: 'Adicionar Lista',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateOrEditListScreen()),
          );
        },
      ),
    );
  }

  List<ListModel> _applyFilter(List<ListModel> lists, int filter) {
    if (filter == 1) {
      return lists.where((l) => l.listType == 'action').toList();
    } else if (filter == 2) {
      return lists.where((l) => l.listType == 'entry').toList();
    }
    return lists;
  }
}
