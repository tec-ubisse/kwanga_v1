import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/life_area_model.dart';
import '../../../models/purpose_model.dart';
import '../../../providers/purpose_provider.dart';

class PurposeWidget extends ConsumerWidget {
  final LifeAreaModel area;

  const PurposeWidget({
    super.key,
    required this.area,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PurposeModel purpose =
    ref.watch(purposeByLifeAreaProvider(area.id));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Propósito',
          style: tNormal.copyWith(
            fontWeight: FontWeight.w600,
            color: cMainColor,
          ),
        ),
        const SizedBox(height: 4),

        if (purpose.isNotEmpty)
          Text(
            purpose.description,
            textAlign: TextAlign.center,
            style: tNormal.copyWith(fontSize: 12.0),
          )
        else
          Text(
            'Nenhum propósito definido para esta área.',
            textAlign: TextAlign.center,
            style: tNormal.copyWith(
              fontSize: 12.0,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}
