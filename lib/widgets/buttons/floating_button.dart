import 'package:flutter/material.dart';

import '../../custom_themes/blue_accent_theme.dart';

class FloatingButton extends StatelessWidget {
  final Widget navigateTo;
  const FloatingButton({super.key, required this.navigateTo});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: cMainColor,
      child: const Icon(Icons.add, color: cWhiteColor),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => navigateTo),
        );
      },
    );
  }
}
