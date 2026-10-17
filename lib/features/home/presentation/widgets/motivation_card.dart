import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// A coaching quote that changes with the day of the week.
class MotivationCard extends StatelessWidget {
  const MotivationCard({super.key});

  static const _quotes = [
    ('A good coach can change a game. A great coach can change a life.', 'John Wooden'),
    ('Small daily improvements are the key to staggering long-term results.', 'Unknown'),
    ('Your clients don’t need perfect plans — they need consistent support.', 'YeetCoach'),
    ('The best project you’ll ever work on is someone else’s confidence.', 'Unknown'),
    ('Discipline is choosing between what you want now and what you want most.', 'Abraham Lincoln'),
    ('Celebrate progress, not perfection.', 'Unknown'),
    ('Rest is part of the program. Recovery builds the results.', 'YeetCoach'),
  ];

  @override
  Widget build(BuildContext context) {
    final (quote, author) = _quotes[(DateTime.now().weekday - 1) % _quotes.length];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote,
                    style: _textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '— $author',
                    style: _textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
