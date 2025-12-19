import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/life_area_model.dart';
import '../../../providers/purpose_provider.dart';

import 'empty_purpose_tile.dart';
import 'purpose_tile.dart';

class PurposeAreaSection extends ConsumerWidget {
  final LifeAreaModel area;

  const PurposeAreaSection({
    super.key,
    required this.area,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purposesAsync = ref.watch(purposesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              if (area.iconPath.isNotEmpty)
                area.isSystem
                    ? Image.asset(
                  "assets/icons/${area.iconPath}.png",
                  width: 22,
                )
                    : Image.asset(
                  area.iconPath,
                  width: 22,
                ),
              const SizedBox(width: 8),
              Text(
                area.designation,
                style: tSmallTitle,
              ),
            ],
          ),
        ),
        purposesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Erro ao carregar propósitos'),
          ),
          data: (purposes) {
            final areaPurposes =
            purposes.where((p) => p.lifeAreaId == area.id).toList();

            if (areaPurposes.isEmpty) {
              return EmptyPurposeTile(area: area);
            }

            return Column(
              children: [
                for (final purpose in areaPurposes)
                  PurposeTile(
                    purpose: purpose,
                    area: area,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
