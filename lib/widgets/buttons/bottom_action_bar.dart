import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';

class BottomActionBar extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool showShadow;
  final EdgeInsets padding;
  final double borderRadius;

  const BottomActionBar({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.showShadow = true,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: showShadow
            ? [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ]
            : null,
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cMainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
