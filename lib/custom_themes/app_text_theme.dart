import 'package:flutter/material.dart';

class AppTextTheme {
  // =====================
  // DISPLAY (títulos grandes)
  // =====================
  static TextStyle displayLarge(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: c.onSurface,
    );
  }

  static TextStyle displayMedium(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: c.onSurface,
    );
  }

  static TextStyle displaySmall(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: c.onSurface,
    );
  }

  // =====================
  // HEADLINE (seções)
  // =====================
  static TextStyle headlineLarge(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: c.onSurface,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: c.onSurface,
    );
  }

  static TextStyle headlineSmall(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: c.onSurface,
    );
  }

  // =====================
  // BODY (texto comum)
  // =====================
  static TextStyle bodyLarge(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: c.onSurface,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: c.onSurface.withOpacity(0.85),
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w300,
      color: c.onSurface.withOpacity(0.65),
    );
  }

  // =====================
  // LABELS / BUTTONS
  // =====================
  static TextStyle labelLarge(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: c.primary,
    );
  }

  static TextStyle labelMedium(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: c.primary,
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: c.onSurface.withOpacity(0.6),
    );
  }

  // =====================
  // NÚMEROS / DESTAQUES
  // =====================
  static TextStyle number(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: c.onSurface,
    );
  }
}
