import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

import '../../../../core/theme/app_theme.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white38)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd),
          child: Text(
            'or',
            style: AppTheme.light.textTheme.bodySmall?.copyWith(fontSize: 13, color: Colors.white38),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white38)),
      ],
    );
  }
}
