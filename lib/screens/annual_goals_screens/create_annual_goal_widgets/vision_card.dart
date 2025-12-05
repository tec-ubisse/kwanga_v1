import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/vision_model.dart';
import 'package:kwanga/models/life_area_model.dart';

class VisionCard extends StatelessWidget {
  final VisionModel vision;
  final AsyncValue<List<LifeAreaModel>> lifeAreasAsync;

  const VisionCard({
    super.key,
    required this.vision,
    required this.lifeAreasAsync,
  });

  @override
  Widget build(BuildContext context) {
    return lifeAreasAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (areas) {
        // Procurar a área de vida de forma segura
        LifeAreaModel? area;
        try {
          area = areas.firstWhere((a) => a.id == vision.lifeAreaId);
        } catch (_) {
          area = null;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Conteúdo textual sempre mostrado
              Text(vision.description, style: tNormal.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Row(
                spacing: 16.0,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Conclusão:",
                        style: tNormal.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${vision.conclusion}",
                        style: tNormal.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  // Só mostrar coluna da área se existir
                  if (area != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Se a área indicar que é system, usar assets/icons/..., caso contrário usar o path direto
                        Text(
                          "Área da vida:",
                          style: tNormal.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          spacing: 4.0,
                          children: [
                            Builder(
                              builder: (_) {
                                final path = area!.isSystem
                                    ? "assets/icons/${area.iconPath}.png"
                                    : area.iconPath;
                                return Image.asset(path, width: 18);
                              },
                            ),
                            Text(
                              area.designation,
                              style: tNormal.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
