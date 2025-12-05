import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: cBlackColor.withAlpha(10),
      ),
      validator: (v) =>
      v == null || v.trim().isEmpty ? "Escreva algo" : null,
    );
  }
}
