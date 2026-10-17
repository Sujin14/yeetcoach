import 'package:flutter/material.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

class ClientTileShimmer extends StatelessWidget {
  const ClientTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      child: Row(
        children: [
          ShimmerCircle(size: 48),
          SizedBox(width: AppSpacing.smd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 140, height: 14, radius: 6),
              SizedBox(height: 6),
              ShimmerBox(width: 100, height: 12, radius: 6),
            ],
          ),
        ],
      ),
    );
  }
}
