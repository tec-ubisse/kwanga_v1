import 'package:flutter/material.dart';
import 'package:kwanga/screens/lists_screens/lists_screen.dart';
import 'package:kwanga/screens/task_screens/task_screen.dart';

import '../custom_themes/blue_accent_theme.dart';
import '../custom_themes/text_style.dart';
import '../data/life_areas.dart';
import '../screens/configurations_screen/configurations_screen.dart';
import '../screens/life_area_screens/read_life_areas_screen.dart';
import '../screens/purpose_screens/read_purposes.dart';
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
              color: cMainColor,
              child: Center(child: Text('Visão Geral', style: tTitle)),
            ),
          ),

          // Tiles
          Expanded(
            flex: 3,
            child: ListView(
              children: [
                DrawerTile(
                  tileName: 'Tarefas',
                  tileImage: 'focus-64',
                  navigateTo: TaskScreen(),
                ),
                DrawerTile(
                  tileName: 'Listas',
                  tileImage: 'focus-64',
                  navigateTo: ListsScreen(),
                ),
                DrawerTile(
                  tileName: 'Propósitos',
                  tileImage: 'focus-64',
                  navigateTo: ReadPurposes(),
                ),
                DrawerTile(
                  tileName: 'Áreas da Vida',
                  tileImage: 'focus-64',
                  navigateTo: ReadLifeAreasScreen(),
                ),
              ],
            ),
          ),

          // Log Out
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
