import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes//blue_accent_theme.dart';

final tTitle = TextStyle(
  color: cWhiteColor,
  fontFamily: 'Inter',
  fontWeight: FontWeight.w500,
  fontSize: 24,
);

final tNormal = TextStyle(
  color: cBlackColor,
  fontFamily: 'Inter',
  fontWeight: FontWeight.w300,
  fontSize: 15,
);

final tSmallTitle = TextStyle(
  color: cMainColor,
  fontFamily: 'Inter',
  fontWeight: FontWeight.w700,
  fontSize: 15,
);

final tButtonText = TextStyle(
  color: cWhiteColor,
  fontFamily: 'Inter',
  fontWeight: FontWeight.w500,
  fontSize: 18,
);

final inputDecoration = InputDecoration(
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: cBlackColor),
    borderRadius: BorderRadius.circular(12.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: cSecondaryColor, width: 2.0),
    borderRadius: BorderRadius.circular(12.0),
  ),
);
