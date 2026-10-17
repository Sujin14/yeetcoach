import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Uppercase muted header over a white card of tiles separated by dividers.
class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.lg, AppSpacing.xs, AppSpacing.sm),
          child: Text(
            title.toUpperCase(),
            style: _textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.subtle,
            ),
          ),
        ),
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          color: AppColors.surface,
          surfaceTintColor: AppColors.surface,
          shadowColor: AppColors.cardShadow,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 56, color: AppColors.divider),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Standard settings row. Navigable rows get a chevron unless [trailing] is given.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: _textTheme.bodyLarge?.copyWith(fontSize: 15, color: AppColors.onSurface),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
            ),
      trailing: trailing ??
          (onTap == null ? null : const Icon(Icons.chevron_right, color: AppColors.subtle)),
      onTap: onTap,
    );
  }
}
