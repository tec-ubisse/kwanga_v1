import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/screens/lists_screens/create_lists_screen.dart';
import 'package:kwanga/screens/lists_screens/widgets/list_tile_item.dart';
import 'package:kwanga/screens/lists_screens/widgets/lists_filter_bar.dart';
import 'package:kwanga/widgets/custom_drawer.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  final ListDao _listDao = ListDao();
  late Future<List<ListModel>> _listsFuture;
  int selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    loadLists();
  }

  void loadLists() {
    setState(() {
      _listsFuture = _listDao.getAll();
    });
  }

  Future<void> deleteList(ListModel list) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Eliminar Tarefa',
          style: tTitle.copyWith(color: cTertiaryColor),
        ),
        content: Text(
          'Tem certeza que deseja eliminar a lista "${list.description}"?',
          style: tNormal,
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _listDao.delete(list.id);
      loadLists();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa eliminada com sucesso.')),
      );
    }
  }

  void selectFilter(int index) {
    setState(() {
      selectedFilter = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: cWhiteColor,
        backgroundColor: cMainColor,
        title: const Text('Listas'),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
            ListsFilterBar(
              selectedFilter: selectedFilter,
              onFilterSelected: selectFilter,
            ),

            Expanded(
              child: FutureBuilder<List<ListModel>>(
                future: _listsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }

                  final lists = snapshot.data ?? [];

                  List<ListModel> filteredLists;
                  if (selectedFilter == 1) {
                    filteredLists = lists
                        .where((l) => l.listType == 'Lista de Acção')
                        .toList();
                  } else if (selectedFilter == 2) {
                    filteredLists = lists
                        .where((l) => l.listType == 'Lista de Entradas')
                        .toList();
                  } else {
                    filteredLists = lists;
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
                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Slidable(
                            endActionPane: ActionPane(
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  backgroundColor: cTertiaryColor,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  onPressed: (_) => deleteList(list),
                                  icon: Icons.delete,
                                ),
                              ],
                            )
                        , child: ListTileItem(listModel: list)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cMainColor,
        child: const Icon(Icons.add, color: cWhiteColor),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const CreateListsScreen()),
          );
        },
      ),
    );
  }
}
