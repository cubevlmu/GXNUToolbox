import 'package:fin_ui/app_context.dart';
import 'package:flutter/material.dart';

class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 1350),
    this.highlightStrength = 0.18,
  });

  final Widget Function(BuildContext context, SkeletonPalette palette) builder;
  final Duration duration;
  final double highlightStrength;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final baseTone = isLight
        ? Color.lerp(colors.surfaceAlt, colors.border, 0.58)!
        : Color.lerp(colors.surfaceAlt, colors.surfacePressed, 0.28)!;
    final highlightTone = isLight
        ? Color.lerp(colors.surface, colors.surfaceAlt, 0.16)!
        : Color.lerp(colors.surfacePressed, colors.borderStrong, 0.34)!;
    final borderTone = isLight
        ? colors.border.withValues(alpha: 0.54)
        : colors.border.withValues(alpha: 0.34);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return RepaintBoundary(
          child: widget.builder(
            context,
            SkeletonPalette(
              progress: _controller.value,
              baseColor: baseTone,
              highlightColor: highlightTone,
              borderColor: borderTone,
              highlightStrength: widget.highlightStrength,
            ),
          ),
        );
      },
    );
  }
}

class SkeletonPalette {
  const SkeletonPalette({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
    required this.borderColor,
    required this.highlightStrength,
  });

  final double progress;
  final Color baseColor;
  final Color highlightColor;
  final Color borderColor;
  final double highlightStrength;

  BoxDecoration line({double radius = 999}) =>
      _buildDecoration(radius: radius, isCircle: false);

  BoxDecoration block({double radius = 16}) =>
      _buildDecoration(radius: radius, isCircle: false);

  BoxDecoration circle() => _buildDecoration(radius: 999, isCircle: true);

  BoxDecoration _buildDecoration({
    required double radius,
    required bool isCircle,
  }) {
    final sweep = Curves.easeInOut.transform(progress);
    final baseTone = Color.lerp(
      baseColor,
      highlightColor,
      (highlightStrength * 0.16).clamp(0.03, 0.08),
    )!;
    final shimmerTone = Color.lerp(
      baseColor,
      highlightColor,
      (highlightStrength * 1.2).clamp(0.22, 0.42),
    )!;
    final startX = -1.2 + (sweep * 2.4);
    final endX = startX + 0.85;

    return BoxDecoration(
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 0.7),
      gradient: LinearGradient(
        begin: Alignment(startX, 0),
        end: Alignment(endX, 0),
        colors: [baseTone, baseTone, shimmerTone, baseTone],
        stops: const [0.0, 0.38, 0.52, 1.0],
      ),
    );
  }
}

class SkeletonBar extends StatelessWidget {
  const SkeletonBar({
    super.key,
    required this.decoration,
    required this.widthFactor,
    required this.height,
  });

  final Decoration decoration;
  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(height: height, decoration: decoration),
    );
  }
}
