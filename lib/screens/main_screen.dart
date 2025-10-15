import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/life_areas.dart';
import 'package:kwanga/screens/life_area_screens/read_life_areas_screen.dart';
import 'package:kwanga/screens/configurations_screen/configurations_screen.dart';
import 'package:kwanga/screens/long_term_vision/read_long_term_visions_screen.dart';
import 'package:kwanga/screens/purpose_screens/read_purposes.dart';
import 'package:kwanga/widgets/drawer_tile.dart';

import '../data/purposes.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(
          'Kwanga',
          style: tTitle.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      // backgroundColor: cWhiteColor,
      drawer: Drawer(
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
                    tileName: 'Áreas da vida',
                    tileImage: 'focus-64',
                    navigateTo: ReadLifeAreasScreen(
                      lifeAreas: initialLifeAreas,
                    ),
                  ),
                  DrawerTile(
                    tileName: 'Propósitos',
                    tileImage: 'focus-64',
                    navigateTo: ReadPurposes(),
                  ),
                  DrawerTile(
                    tileName: 'Visão de Longo Prazo',
                    tileImage: 'focus-64',
                    navigateTo: LongTermVisionsScreen(),
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
      ),
    );
  }
}
