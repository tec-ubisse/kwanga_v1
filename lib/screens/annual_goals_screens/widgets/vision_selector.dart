import 'package:flutter/material.dart';
import 'package:kwanga/models/vision_model.dart';

class VisionSelector extends StatelessWidget {
  final List<VisionModel> visions;
  final String? selectedVisionId;
  final void Function(String?) onChanged;

  const VisionSelector({
    super.key,
    required this.visions,
    required this.selectedVisionId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedVisionId,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.black12,
      ),
      hint: const Text("Selecione uma visão"),
      items: visions
          .map(
            (v) => DropdownMenuItem(
          value: v.id,
          child: Text(v.description),
        ),
      )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Selecione uma visão" : null,
    );
  }
}
