import 'package:flutter/material.dart';
import 'package:kwanga/screens/configurations_screen/version_screen.dart';
import 'package:kwanga/screens/development_screen.dart';
import 'package:kwanga/screens/lists_screens/lists_screen.dart';
import 'package:kwanga/screens/task_screens/task_screen.dart';
import '../custom_themes/blue_accent_theme.dart';
import '../custom_themes/text_style.dart';
import '../screens/configurations_screen/configurations_screen.dart';
import '../screens/lists_screens/view_lists.dart';
import 'drawer_tile.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Expanded(
            child: Container(
              width: double.infinity,
              color: cMainColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Visão Geral', style: tTitle.copyWith(fontSize: 32)),
                  Row(
                    spacing: 4.0,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ' Kwanga Versão 1.9',
                        style: tNormal.copyWith(
                          color: cWhiteColor,
                          fontSize: 12.0,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: cWhiteColor,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    VersionScreen(currentVersion: "1.5.0"),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: cMainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tiles
          Expanded(
            flex: 3,
            child: ListView(
              children: [
                DrawerTile(
                  tileName: 'Tarefas',
                  tileImage: 'task',
                  navigateTo: TaskScreen(),
                ),
                DrawerTile(
                  tileName: 'Entradas',
                  tileImage: 'entry',
                  navigateTo: ListsScreen(listType: 'entry'),
                ),
                DrawerTile(
                  tileName: 'Proximas acções',
                  tileImage: 'project',
                  navigateTo: ListsScreen(listType: 'action',),
                ),
                DrawerTile(
                  tileName: 'Objectivos Anuais',
                  tileImage: 'yearly_goals',
                  navigateTo: DevelopmentScreen(pageName: 'Objectivos Anuais'),
                ),
                DrawerTile(
                  tileName: 'Objectivos Mensais',
                  tileImage: 'tasklist',
                  navigateTo: DevelopmentScreen(pageName: 'Objectivos Mensais'),
                ),
                DrawerTile(
                  tileName: 'Gerir Projectos',
                  tileImage: 'projects',
                  navigateTo: DevelopmentScreen(pageName: 'Gerir Projectos'),
                ),
                DrawerTile(
                  tileName: 'Áreas da Vida',
                  tileImage: 'life_area',
                  navigateTo: DevelopmentScreen(pageName: 'Áreas da Vida'),
                ),
                DrawerTile(
                  tileName: 'Gerir Listas',
                  tileImage: 'to-do',
                  navigateTo: ViewLists(),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const ConfigurationsScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 20.0),
              child: Row(
                spacing: 8.0,
                children: [
                  Icon(Icons.settings, color: cBlackColor),
                  Text(
                    'Configurações',
                    style: tNormal.copyWith(
                      color: cBlackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
