import 'package:flutter/material.dart';
import 'stats_card.dart';

class StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      children: [
        StatsCard(
          icon: Icons.visibility,
          label: 'Visão de longo prazo',
          value: 1,
          progress: 0.25,
        ),
        StatsCard(
          icon: Icons.flag,
          label: 'Objectivos anuais',
          value: 5,
          progress: 0.25,
        ),
        StatsCard(
          icon: Icons.calendar_today,
          label: 'Objectivos mensais',
          value: 24,
          progress: 0.25,
        ),
        StatsCard(
          icon: Icons.work_outline,
          label: 'Projectos',
          value: 3,
          progress: 0.25,
        ),
      ],
    );
  }
}
