import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/long_term_vision_model.dart';

class CreateLongTermVision extends StatefulWidget {
  final LifeArea? initialLifeArea;
  final LongTermVision? existingVision;

  const CreateLongTermVision({
    super.key,
    this.initialLifeArea,
    this.existingVision,
  });

  @override
  State<CreateLongTermVision> createState() => _CreateLongTermVisionState();
}

class _CreateLongTermVisionState extends State<CreateLongTermVision> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: cMainColor, foregroundColor: cWhiteColor,),
    );
  }
}
