import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/widgets/kwanga_dropdown_button.dart';

class MonthlyGoalMonthDropdown extends StatelessWidget {
  final int selectedMonth;
  final ValueChanged<int> onChanged;

  const MonthlyGoalMonthDropdown({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const monthNames = [
      "Janeiro","Fevereiro","Março","Abril","Maio","Junho",
      "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: KwangaDropdownButton<int>(
        value: selectedMonth,
        items: List.generate(12, (i) {
          return DropdownMenuItem(
            value: i + 1,
            child: Text(monthNames[i]),
          );
        }),
        onChanged: (v) => onChanged(v!), labelText: '', hintText: '',
      ),
    );
  }
}
