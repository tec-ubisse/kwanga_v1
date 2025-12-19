import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import '../../../../models/life_area_model.dart';
import '../../../../utils/life_area_icon_resolver.dart';

class LifeAreaCard extends StatelessWidget {
  final LifeAreaModel area;
  final VoidCallback onTap;

  const LifeAreaCard({
    super.key,
    required this.area,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cBlackColor.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Conteúdo principal
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    resolveLifeAreaIconPath(area),
                    width: 40,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      area.designation,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: tNormal.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
