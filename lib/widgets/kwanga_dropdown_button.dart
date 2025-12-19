import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

class KwangaDropdownButton<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  final String labelText;
  final String hintText;
  final String? errorMessage;
  final String? disabledMessage;

  const KwangaDropdownButton({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    required this.labelText,
    required this.hintText,
    this.errorMessage,
    this.disabledMessage,
  });

  bool get _isDisabled => disabledMessage != null;

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorMessage != null;
    final Color errorColor = Theme.of(context).colorScheme.error;

    final Color borderColor = hasError
        ? errorColor
        : _isDisabled
        ? Colors.grey.shade400
        : cBlackColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty) Text(labelText, style: tNormal),
        const SizedBox(height: 8),
        Opacity(
          opacity: _isDisabled ? 0.6 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: value,
                onChanged: _isDisabled ? null : onChanged,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                style: tNormal,
                itemHeight: null, // Altura dinâmica
                menuMaxHeight: 400,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _isDisabled ? disabledMessage! : hintText,
                    style: tNormal.copyWith(
                      color: _isDisabled
                          ? Colors.grey
                          : hasError
                          ? errorColor
                          : Colors.grey,
                    ),
                  ),
                ),
                // Define como o item aparece no botão APÓS selecionado (Sem o Divider)
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((item) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: item.child, // Aqui enviamos apenas o conteúdo sem a borda
                    );
                  }).toList();
                },
                // Define como os itens aparecem na LISTA aberta (Com o Divider)
                items: items.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final DropdownMenuItem<T> item = entry.value;

                  return DropdownMenuItem<T>(
                    value: item.value,
                    enabled: item.enabled,
                    onTap: item.onTap,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index < items.length - 1
                                ? Colors.grey.shade200
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: item.child,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: errorColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}