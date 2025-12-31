import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../custom_themes/blue_accent_theme.dart';
import '../../custom_themes/text_style.dart';

class KwangaEmptyCard extends StatelessWidget {
  final String message;

  const KwangaEmptyCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration.copyWith(color: cCardBackgroundColor, borderRadius: BorderRadius.circular(18.0)),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              message,
              style: tNormal.copyWith(color: Colors.grey[600]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          _EmptyProgressIndicator(),
        ],
      ),
    );
  }
}

class _EmptyProgressIndicator extends StatelessWidget {
  const _EmptyProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 32,
      lineWidth: 12,
      percent: 0,
      center: Text(
        '0%',
        style: tNormal.copyWith(fontWeight: FontWeight.w600, fontSize: 10.0),
      ),
      progressColor: cMainColor,
      backgroundColor: Colors.grey.shade300,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}
