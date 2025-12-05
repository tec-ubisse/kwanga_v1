import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/widgets/card_container.dart';

class MonthlyGoalAddPlaceholder extends StatelessWidget {
  final VoidCallback onTap;

  const MonthlyGoalAddPlaceholder({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CardContainer(
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Clique para adicionar",
                style: tNormal.copyWith(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ),
            const Icon(Icons.add_circle, color: cMainColor),
          ],
        ),
      ),
    );
  }
}
