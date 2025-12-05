import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/widgets/kwanga_dropdown_button.dart';

class MonthlyGoalYearDropdown extends StatelessWidget {
  final int selectedYear;
  final ValueChanged<int> onChanged;

  const MonthlyGoalYearDropdown({
    super.key,
    required this.selectedYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    final years = List.generate(7, (i) => currentYear - 3 + i);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: KwangaDropdownButton<int>(
          value: selectedYear,
          items: years.map((y) {
            return DropdownMenuItem(
              value: y,
              child: Text("$y", style: tNormal),
            );
          }).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}
