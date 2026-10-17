import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

import '../shimmer_base.dart';

class PlanListShimmer extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const PlanListShimmer({super.key, this.padding = const EdgeInsets.all(AppSpacing.md)});

  static const _itemCount = 4;

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: _itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => const ShimmerBox(width: double.infinity, height: 72, radius: 12),
      ),
    );
  }
}
