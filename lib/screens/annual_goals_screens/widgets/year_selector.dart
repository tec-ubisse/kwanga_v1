import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import '../../../widgets/kwanga_dropdown_button.dart';

class YearSelector extends StatelessWidget {
  final int? selectedYear;

  final void Function(int?)? onChanged;

  final dynamic lockedVision;

  const YearSelector({
    super.key,
    required this.selectedYear,
    this.onChanged,
    this.lockedVision,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(6, (i) => currentYear + i);

    final isDisabled = onChanged == null;

    return KwangaDropdownButton<int>(
      value: selectedYear!,
      onChanged: onChanged!,
      items: years
          .map(
            (year) => DropdownMenuItem(
          value: year,
          child: Text(
            "$year",
            style: tNormal.copyWith(
              color:
              isDisabled ? Colors.grey.shade500 : Colors.black87,
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}
