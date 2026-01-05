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
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vision.conclusion.toString(),
                  style: tSmallTitle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vision.description,
                  style: tNormal.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),
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
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircularPercentIndicator(
            radius: 32,
            lineWidth: 12,
            percent: 0.0,
            center: Text('0%', style: tNormal,),
            progressColor: cMainColor,
            backgroundColor: Colors.grey.shade300,
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }
}

