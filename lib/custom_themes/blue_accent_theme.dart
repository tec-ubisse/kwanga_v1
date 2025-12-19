import 'package:flutter/material.dart';

var kColorScheme = ColorScheme.fromSeed(seedColor: Color(0xff2C5F8D));

const cMainColor = Color(0xff0072b1);
const cSecondaryColor = Color(0xff3271D1);
const cTertiaryColor = Color(0xffFF8B7B);
const cWhiteColor = Colors.white;
// const cWhiteColor = Color(0xffF8F6F3);
const cBlackColor = Color(0xff475569);
const cCardBackgroundColor = Color(0xffF8F6F3);

const defaultPadding = EdgeInsets.fromLTRB(16, 8, 16, 0);

const cDefaultShadow = BoxShadow(
  color: Color(0x1A000000), // Colors starts with 0x1a to apply opacity of 10%
  offset: Offset(4, 4), // XY translation
  blurRadius: 8, // Gaussian blur
  spreadRadius: 0, // Shadow expansion
);

final cardDecoration = BoxDecoration(
  color: Colors.white,
  boxShadow: const [cDefaultShadow],
  borderRadius: BorderRadius.circular(12.0),
);