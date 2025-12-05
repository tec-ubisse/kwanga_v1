import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/vision_model.dart';

class HeaderSection extends StatelessWidget {
  final VisionModel vision;
  final LifeAreaModel area;

  const HeaderSection({
    super.key,
    required this.vision,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                spacing: 2.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vision.conclusion.toString(),
                    style: tSmallTitle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    vision.description,
                    style: tNormal.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      if (area.iconPath.isNotEmpty)
                        area.isSystem
                            ? Image.asset(
                          "assets/icons/${area.iconPath}.png",
                          width: 20,
                        )
                            : Image.asset(
                          area.iconPath,
                          width: 20,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        "Área: ${area.designation}",
                        style: tNormal.copyWith(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: CircularPercentIndicator(
                radius: 32.0,
                lineWidth: 12.0,
                percent: 0.23,
                center: const Text('23%'),
                progressColor: cMainColor,
                backgroundColor: Colors.grey.shade300,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
