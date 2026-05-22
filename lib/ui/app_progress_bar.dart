import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 6,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final clamped = value.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radiusFull),
      child: LinearProgressIndicator(
        value: clamped,
        minHeight: height,
        backgroundColor: colors.surfaceAlt,
        color: colors.primary,
      ),
    );
  }
}
