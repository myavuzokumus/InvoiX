import 'package:flutter/material.dart';

class GlowingContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;

  const GlowingContainer({
    super.key,
    required this.child,
    this.glowColor = Colors.blue,
  });

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}