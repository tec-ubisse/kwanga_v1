import 'package:flutter/material.dart';
import 'package:kwanga/data/life_areas.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/screens/life_area_screens/create_life_area_screen.dart';
import '../../custom_themes/blue_accent_theme.dart';
import '../../custom_themes/text_style.dart';
import '../../widgets/custom_drawer.dart';
import '../main_screen.dart';

class ReadLifeAreasScreen extends StatelessWidget {
  final List<LifeArea> lifeAreas;

  const ReadLifeAreasScreen({super.key, required this.lifeAreas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(
          'Áreas da vida',
          style: tTitle.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 1.0,
          ),
          itemCount: initialLifeAreas.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              decoration: BoxDecoration(
                color: cBlackColor.withAlpha(10),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/${initialLifeAreas[index].iconPath}.png',
                      width: 40.0,
                    ),
                    Text(initialLifeAreas[index].designation),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const CreateLifeAreaScreen()),
          );
        },
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
