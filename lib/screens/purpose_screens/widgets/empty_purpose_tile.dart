import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/life_area_model.dart';

class EmptyPurposeTile extends StatelessWidget {
  final LifeAreaModel area;

  const EmptyPurposeTile({
    super.key,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration.copyWith(
        color: cCardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// TEXTO
          Expanded(
            child: Text(
              'Sem propósito definido nesta área.',
              style: tNormal.copyWith(
                color: Colors.grey[600],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
