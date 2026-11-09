import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Sweeps a highlight across [child] while keeping the underlying content visible.
/// Uses the [shimmer] package; [baseColor] / [highlightColor] should come from the
/// host button so the effect works on both primary and light surfaces.
class ShimmerSweep extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  const ShimmerSweep({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    this.period = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      child: child,
    );
  }
}
