import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/life_area_model.dart';

import '../../../custom_themes/text_style.dart';
import '../create_vision_screen.dart';

class NoVisionWidget extends StatelessWidget {
  const NoVisionWidget({super.key, required this.areaSemVisao});

  final LifeAreaModel areaSemVisao;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 16.0),
      height: 80.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(48),
              blurRadius: 8,
              offset: const Offset(4, 4),
              spreadRadius: -1,
            )
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Clique para adicionar'),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => CreateVision(
                    lifeAreaId: areaSemVisao.id,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: cMainColor,
              child: Icon(Icons.add, color: Colors.white, size: 24),
            ),
          )
        ],
      ),
    );
  }
}
