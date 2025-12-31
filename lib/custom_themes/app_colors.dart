import 'package:flutter/material.dart';

class AppColors {
  // Cores Base (não usar direto nos widgets)
  static const _blueMain = Color(0xff0072b1);
  static const _blueLight = Color(0xff3271D1);
  static const _salmon = Color(0xffFF8B7B);
  static const _slate = Color(0xff475569);
  static const _ivory = Color(0xffFFFFFF);
  static const _darkBackground = Color(0xff121212);

  // LIGHT MODE
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,

    primary: _blueMain,
    onPrimary: Colors.white,

    secondary: _blueLight,
    onSecondary: Colors.white,

    tertiary: _salmon,
    onTertiary: Colors.white,

    background: _ivory,
    onBackground: _slate,

    surface: _ivory,
    onSurface: _slate,

    error: Colors.red,
    onError: Colors.white,
  );

  // DARK MODE
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,

    primary: _blueLight,
    onPrimary: Colors.black,

    secondary: _blueMain,
    onSecondary: Colors.white,

    tertiary: _salmon,
    onTertiary: Colors.black,

    background: _darkBackground,
    onBackground: Colors.white,

    surface: Color(0xff1E1E1E),
    onSurface: Colors.white,

    error: Colors.redAccent,
    onError: Colors.black,
  );
}
