import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';

class ListTileItem extends StatelessWidget {
  final ListModel listModel;

  const ListTileItem({super.key, required this.listModel});

  @override
  Widget build(BuildContext context) {
    final isEntrada = listModel.listType == 'Lista de Entradas';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xffEAEFF4),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          spacing: 8,
          children: [
            if (!isEntrada)
              SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  value: 0.4,
                  backgroundColor: cSecondaryColor.withAlpha(50),
                  color: cSecondaryColor,
                  strokeWidth: 4.0,
                ),
              ),
            Expanded(
              child: Text(
                listModel.description,
                style: tNormal.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
