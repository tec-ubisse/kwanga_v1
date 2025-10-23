import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/screens/lists_screens/create_lists_screen.dart';
import 'package:kwanga/widgets/custom_drawer.dart';

import '../../data/database/list_dao.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  final ListDao _listDao = ListDao();
  late Future<List<ListModel>> _listsFuture;

  void loadLists() {
    setState(() {
      _listsFuture = _listDao.getAll();
    });
  }

  @override
  void initState() {
    super.initState();
    loadLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: cWhiteColor,
        backgroundColor: cMainColor,
        title: Text('Listas'),
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // TODAS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 24.0,
                    ),
                    decoration: BoxDecoration(
                      color: cSecondaryColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'Todas',
                      style: tNormal.copyWith(color: cWhiteColor),
                    ),
                  ),
                  // ACCAO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 24.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text('Listas de Acção', style: tNormal),
                  ),
                  // ENTRADAS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 24.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text('Listas de Entradas', style: tNormal),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 19,
              child: FutureBuilder(
                future: _listsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final lists = snapshot.data!;

                  return ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xffEAEFF4),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  spacing: 8,
                                  children: [
                                    if (lists[index].listType !=
                                        'Lista de Entradas')
                                      SizedBox(
                                        height: 24.0,
                                        width: 24.0,
                                        child: CircularProgressIndicator(
                                          value: 0.4,
                                          backgroundColor: cSecondaryColor
                                              .withAlpha(50),
                                          color: cSecondaryColor,
                                          strokeWidth: 4.0,
                                        ),
                                      ),
                                    Text(lists[index].description),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
        child: Icon(Icons.add, color: cWhiteColor),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => CreateListsScreen()));
        },
      ),
    );
  }
}
