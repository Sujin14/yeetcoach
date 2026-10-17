import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/widgets/count_up_text.dart';

class StatChip extends StatelessWidget {
  final String emoji;

  /// Shown as "—" when null; otherwise counts up from 0 on first appearance.
  final num? value;
  final int fractionDigits;
  final String label;
  final VoidCallback? onTap;

  const StatChip({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    this.fractionDigits = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final value = this.value;
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shadowColor: const Color(0x0D000000),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppSpacing.sm),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              if (value == null)
                Text('—', maxLines: 1, style: textTheme.displayLarge)
              else
                CountUpText(
                  value: value.toDouble(),
                  format: (current) => current.toStringAsFixed(fractionDigits),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.displayLarge,
                ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: AppColors.subtle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
