import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

class KwangaDropdownButton<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const KwangaDropdownButton({
    super.key,
    this.value,
    required this.items,
    required this.onChanged,
  });

  BoxDecoration _decoration(BuildContext context) {
    final Color mainColor = Theme.of(context).primaryColor;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: mainColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color dropdownBgColor = Colors.white;
    final TextStyle defaultTextStyle = tNormal;

    return Container(
      decoration: _decoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: const Text('Selecione uma opção'),
          value: value,
          dropdownColor: dropdownBgColor,
          borderRadius: BorderRadius.circular(12.0),
          style: defaultTextStyle,

          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              child: DefaultTextStyle.merge(
                style: defaultTextStyle,
                child: item.child,
              ),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ),
    );
  }
}