import 'dart:ui';
import 'package:flutter/material.dart';

class WeatherBackground extends StatelessWidget {
  final Widget child;
  const WeatherBackground({super.key, required this.child});

  Widget _floatingBubble({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    double opacity = 0.12,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((opacity * 255).round()),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        _floatingBubble(top: -50, left: -40, size: 160, opacity: 0.12),
        _floatingBubble(top: 120, right: -60, size: 200, opacity: 0.15),
        _floatingBubble(bottom: 150, left: -30, size: 140, opacity: 0.1),
        _floatingBubble(bottom: 60, right: 40, size: 90, opacity: 0.12),
        child,
      ],
    );
  }
}
