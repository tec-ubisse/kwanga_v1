import 'package:flutter/material.dart';

import '../../custom_themes/text_style.dart';

class VersionTile extends StatelessWidget {
  final String title;
  final String description;
  const VersionTile({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tSmallTitle,),
        Text(description, style: tNormal,),
        Divider(),
        const SizedBox(height: 4.0,)
      ],
    );
  }
}
