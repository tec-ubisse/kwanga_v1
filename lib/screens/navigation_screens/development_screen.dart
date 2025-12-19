import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';

class DevelopmentScreen extends StatelessWidget {
  final String pageName;

  const DevelopmentScreen({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(pageName),
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                'Página ainda em Desenvolvimento',
                textAlign: TextAlign.center,
                style: tNormal.copyWith(fontSize: 24.0),
              ),
            ),
            Transform.scale(scale:1.6, child: Image.asset('assets/Programmer.gif', height: 480.0)),
          ],
        ),
      ),
    );
  }
}
