import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../custom_themes/blue_accent_theme.dart';
import '../../custom_themes/text_style.dart';

class KwangaEmptyCard extends StatelessWidget {
  final String message;

  const KwangaEmptyCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration.copyWith(color: Color(0xffF8F6F3)),
      padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              message,
              style: tNormal.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 1,
            child: CircularPercentIndicator(
              radius: 32.0,
              lineWidth: 12.0,
              percent: 0,
              center: Text('0%'),
              progressColor: cMainColor,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),

        ],
      ),
    );
  }
}