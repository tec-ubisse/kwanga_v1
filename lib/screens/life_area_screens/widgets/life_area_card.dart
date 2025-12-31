import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import '../../../../models/life_area_model.dart';
import '../../../../utils/life_area_icon_resolver.dart';

class LifeAreaCard extends StatelessWidget {
  final LifeAreaModel area;
  final VoidCallback? onTap;

  /// 👇 quando true, mostra handle de drag e desativa tap
  final bool showDragHandle;

  const LifeAreaCard({
    super.key,
    required this.area,
    this.onTap,
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showDragHandle ? null : onTap,
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

            // Drag handle (modo reorder)
            if (showDragHandle)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.drag_handle,
                  size: 18,
                  color: cMainColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
