import 'package:flutter/material.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/life_area_model.dart';

class EmptyPurposeTile extends StatelessWidget {
  final LifeAreaModel area;

  const EmptyPurposeTile({super.key, required this.area});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cBlackColor.withAlpha(5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Sem propósito definido\nnesta área.',
        style: tNormal.copyWith(
          color: cBlackColor.withAlpha(70),
        ),
      ),
    );
  }
}
