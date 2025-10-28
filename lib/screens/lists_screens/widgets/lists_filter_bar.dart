import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

class ListsFilterBar extends StatelessWidget {
  final int selectedFilter;
  final void Function(int) onFilterSelected;

  const ListsFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      'Todas',
      'Listas de Acção',
      'Listas de Entradas',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedFilter == index;
          return GestureDetector(
            onTap: () => onFilterSelected(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? cSecondaryColor : null,
                borderRadius: BorderRadius.circular(24.0),

              ),
              child: Text(
                filters[index],
                style: tNormal.copyWith(
                  color: isSelected ? cWhiteColor : cBlackColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
