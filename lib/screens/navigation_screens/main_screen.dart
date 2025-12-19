import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: cMainColor,
          foregroundColor: cWhiteColor,
          title: Text(
            'Kwanga',
            style: tTitle.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        drawer: CustomDrawer(),
        body: Center(child: Text('Kwanga'),),
      ),
    );
  }
}
