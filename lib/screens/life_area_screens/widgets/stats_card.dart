import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final double progress;

  const StatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cWhiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Topo: ícone
          Icon(icon, color: Colors.grey),

          // Texto
          Text(
            '$value $label',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tNormal.copyWith(fontSize: 12),
          ),

          // Indicador (tamanho controlado)
          SizedBox(
            height: 52,
            child: CircularPercentIndicator(
              percent: progress.clamp(0.0, 1.0),
              center: Text(
                '$percent%',
                style: tNormal.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 10.0
                ),
              ),
              progressColor: cMainColor,
              backgroundColor: Colors.grey.shade300,
              radius: 24,
              circularStrokeCap: CircularStrokeCap.round,
              lineWidth: 5,
            ),
          ),
        ],
      ),
    );
  }
}

