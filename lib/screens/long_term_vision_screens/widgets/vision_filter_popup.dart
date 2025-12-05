import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import '../controllers/vision_filters_controller.dart';

Future<void> showVisionFilterPopup({
  required BuildContext context,
  required VisionFiltersController controller,
  required List<int> years,
  required VoidCallback onChanged,
}) {
  return showMenu(
    context: context,
    position: const RelativeRect.fromLTRB(1000, 80, 12, 0),
    color: cMainColor,
    items: [
      PopupMenuItem(
        enabled: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filtros",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: cWhiteColor,
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(context, controller, "Todas", "all", onChanged),
                _chip(context, controller, "Com visão", "withVision", onChanged),
                _chip(context, controller, "Sem visão", "withoutVision", onChanged),
                _chip(context, controller, "Com objetivos", "withGoals", onChanged),
                _chip(context, controller, "Sem objetivos", "withoutGoals", onChanged),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              "Ano de conclusão",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: cWhiteColor,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _yearChip(context, controller, null, onChanged),
                ...years.map((year) =>
                    _yearChip(context, controller, year, onChanged)),
              ],
            ),
          ],
        ),
      )
    ],
  );
}

Widget _chip(
    BuildContext context,
    VisionFiltersController controller,
    String label,
    String value,
    VoidCallback onChanged,
    ) {
  final selected = controller.activeFilter == value;

  return ChoiceChip(
    checkmarkColor: cWhiteColor,
    label: Text(label),
    selected: selected,
    selectedColor: cSecondaryColor,
    backgroundColor: Colors.grey[200],
    labelStyle: TextStyle(
      color: selected ? cWhiteColor : Colors.black87,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
    ),
    onSelected: (_) {
      controller.setFilter(value);
      onChanged();
      Navigator.pop(context);
    },
  );
}

Widget _yearChip(
    BuildContext context,
    VisionFiltersController controller,
    int? year,
    VoidCallback onChanged,
    ) {
  final selected = controller.selectedYear == year;

  return ChoiceChip(
    checkmarkColor: cWhiteColor,
    label: Text(year?.toString() ?? "Todos"),
    selected: selected,
    selectedColor: cSecondaryColor,
    backgroundColor: Colors.grey[200],
    labelStyle: TextStyle(
      color: selected ? cWhiteColor : Colors.black87,
    ),
    onSelected: (_) {
      controller.setYear(year);
      onChanged();
      Navigator.pop(context);
    },
  );
}
