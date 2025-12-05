import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';

class ExpandButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const ExpandButton({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: cMainColor,
        radius: 16.0,
        child: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.white,
        ),
      ),
    );
  }
}
