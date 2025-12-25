import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final double opacity;

  const AuthBackground({
    super.key,
    required this.child,
    this.opacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: opacity,
          child: Image.asset(
            'assets/background.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        child,
      ],
    );
  }
}
