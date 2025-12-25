import 'package:flutter/material.dart';
import '../../../../custom_themes/blue_accent_theme.dart';
import '../../../../custom_themes/text_style.dart';

class OTPInput extends StatelessWidget {
  final int length;
  final String value;

  const OTPInput({
    super.key,
    this.length = 6,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final char = index < value.length ? value[index] : '';

        return Container(
          width: MediaQuery.of(context).size.width/8,
          height: MediaQuery.of(context).size.width/8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cWhiteColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(char, style: tNumberText),
        );
      }),
    );
  }
}
