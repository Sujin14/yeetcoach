import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 18, decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2,
        ))),
        ?trailing,
      ],
    );
  }
}
