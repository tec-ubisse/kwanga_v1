import 'package:flutter/material.dart';

import '../../custom_themes/blue_accent_theme.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets margin;
  final double? height;

  const CardContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: cardDecoration,
      child: child,
    );
  }
}

