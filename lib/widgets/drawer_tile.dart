import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

class DrawerTile extends StatelessWidget {
  final String tileName;
  final String tileImage;
  final Widget navigateTo;
  const DrawerTile({super.key, required this.tileName, required this.tileImage, required this.navigateTo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                navigateTo,
          ),
        );
      },
      child: ListTile(
        title: Text(tileName, style: tNormal,),
        leading: Image.asset(
          'assets/menu/$tileImage.png',
          width: 24.0,
          color: cBlackColor,
        ),
      ),
    );
  }
}
