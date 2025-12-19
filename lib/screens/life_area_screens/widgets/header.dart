import 'package:flutter/material.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/life_area_model.dart';
import '../../../utils/life_area_icon_resolver.dart';

class Header extends StatelessWidget {
  final LifeAreaModel area;

  const Header({super.key, required this.area});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          resolveLifeAreaIconPath(area),
          width: 72,
        ),
        Text(
          'Área da Vida: ${area.designation}',
          style: tTitle.copyWith(
            color: cBlackColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
