import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// A titled block of the client details screen, 20px below the previous one.
class ClientSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const ClientSection({super.key, required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 32,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: _textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

/// White card with the client details radius (16) and a 1dp shadow.
class ClientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ClientCard({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpacing.md)});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: const Color(0x0D000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: padding, child: child),
    );
  }
}
