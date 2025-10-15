import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';

class CustomIconButton extends StatelessWidget {
  final String iconName;
  const CustomIconButton({super.key, required this.iconName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: cBlackColor,
          style: BorderStyle.solid,
          width: 1.0,
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset('assets/icons/$iconName.png', width: 24.0,),
      ),
    );
  }
}
