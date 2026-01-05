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

  /// Mensagem opcional exibida quando o campo estiver desabilitado
  /// (mantida por compatibilidade)
  final String? disabledMessage;

  /// Novo: controla explicitamente se o dropdown está desabilitado
  /// Default false → não quebra chamadas existentes
  final bool isDisabled;

  /// Novo: permite customizar como o item selecionado é exibido
  final DropdownButtonBuilder? selectedItemBuilder;

  const KwangaDropdownButton({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    required this.labelText,
    required this.hintText,
    this.errorMessage,
    this.disabledMessage,
    this.isDisabled = false,
    this.selectedItemBuilder,
  });

  /// Dropdown fica desabilitado se:
  /// - isDisabled for true (novo padrão)
  /// - OU disabledMessage existir (compatibilidade)
  bool get _isDisabled => isDisabled || disabledMessage != null;

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
        if (labelText.isNotEmpty) Text(labelText, style: tLabel),
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
                itemHeight: null,
                menuMaxHeight: 400,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _isDisabled && disabledMessage != null
                        ? disabledMessage!
                        : hintText,
                    style: tNormal.copyWith(
                      color: _isDisabled
                          ? Colors.grey
                          : hasError
                          ? errorColor
                          : Colors.grey,
                    ),
                  ),
                ),

                /// Define como o item aparece no botão após selecionado
                /// IMPORTANTE: Pega o child do item ORIGINAL (antes do wrap no Container)
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((item) {
                    // Extrai o child real, removendo o Container wrapper
                    final originalChild = item.child is Container
                        ? (item.child as Container).child
                        : item.child;

                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: originalChild,
                    );
                  }).toList();
                },

                /// Itens com divisor inferior (padrão Kwanga)
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