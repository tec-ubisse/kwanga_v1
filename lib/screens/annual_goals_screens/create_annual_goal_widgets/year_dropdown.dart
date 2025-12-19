import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/vision_model.dart';
import '../../../widgets/kwanga_dropdown_button.dart';

class YearDropdown extends StatelessWidget {
  final VisionModel? lockedVision;
  final int? selectedYear;

  /// null → dropdown desabilitado
  final ValueChanged<int?>? onChanged;

  /// erro vindo do FormField
  final String? errorMessage;

  const YearDropdown({
    super.key,
    required this.lockedVision,
    required this.selectedYear,
    this.onChanged,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // 🔒 Sem visão → desabilitado
    if (lockedVision == null) {
      return KwangaDropdownButton<int>(
        value: null,
        items: const [],
        onChanged: null,
        labelText: 'Ano',
        hintText: 'Selecione o ano',
        disabledMessage: 'Defina uma visão primeiro',
        errorMessage: errorMessage,
      );
    }

    final currentYear = DateTime.now().year;
    final maxYear = lockedVision!.conclusion;
    final count = (maxYear - currentYear + 1).clamp(0, 20);

    final years = count <= 0
        ? [maxYear]
        : List.generate(count, (i) => currentYear + i);

    return KwangaDropdownButton<int>(
      value: selectedYear,
      labelText: '',
      hintText: 'Selecione o ano',
      errorMessage: errorMessage,
      onChanged: onChanged,
      items: years
          .map(
            (y) => DropdownMenuItem<int>(
          value: y,
          child: Text('$y', style: tNormal),
        ),
      )
          .toList(),
    );
  }
}
