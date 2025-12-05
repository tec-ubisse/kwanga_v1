import 'package:flutter/material.dart';
import 'package:kwanga/models/vision_model.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';

class YearDropdown extends StatelessWidget {
  final VisionModel? lockedVision;
  final int? selectedYear;

  /// 👇 Agora é opcional (NULLABLE)
  final ValueChanged<int?>? onChanged;

  const YearDropdown({
    super.key,
    required this.lockedVision,
    required this.selectedYear,
    this.onChanged, // 👈 Não é mais required
  });

  @override
  Widget build(BuildContext context) {
    if (lockedVision == null) {
      return DropdownButtonFormField<int>(
        decoration: _input(),
        items: const [],
        hint: const Text("Deve definir uma visão primeiro"),
        onChanged: null, // 👈 Desabilita corretamente
      );
    }

    final current = DateTime.now().year;
    final maxYear = lockedVision!.conclusion;
    final count = (maxYear - current + 1).clamp(0, 20);

    final List<int> years = count <= 0
        ? [maxYear]
        : List.generate(count, (i) => current + i);

    return DropdownButtonFormField<int>(
      value: selectedYear,
      decoration: _input(),
      items: years
          .map((y) => DropdownMenuItem(value: y, child: Text("$y")))
          .toList(),
      hint: const Text("Selecione o ano"),

      /// 👇 Agora aceita null — dropdown fica desabilitado se onChanged == null
      onChanged: onChanged,

      validator: (v) => v == null ? "Selecione o ano" : null,
    );
  }

  InputDecoration _input() => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: cBlackColor.withAlpha(10),
  );
}
