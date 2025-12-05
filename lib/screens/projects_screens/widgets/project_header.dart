import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

class ProjectHeader extends StatelessWidget {
  final String title;
  final double progress;
  final int percentText;

  const ProjectHeader({
    super.key,
    required this.title,
    required this.progress,
    required this.percentText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: tNormal.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        CircularPercentIndicator(
          radius: 36,
          lineWidth: 10,
          percent: progress,
          center: Text(
            '$percentText%',
            style: tNormal.copyWith(fontSize: 14),
          ),
          progressColor: cMainColor,
          backgroundColor: Colors.grey.shade200,
          circularStrokeCap: CircularStrokeCap.round,
        ),
      ],
    );
  }
}
