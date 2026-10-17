import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Collapsible card shell shared by training days and meals.
class ExpandableCard extends StatefulWidget {
  final bool initiallyExpanded;
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final String countLabel;
  final String removeTooltip;
  final VoidCallback onRemove;
  final List<Widget> children;

  const ExpandableCard({
    super.key,
    required this.initiallyExpanded,
    this.leading,
    required this.title,
    this.subtitle,
    required this.countLabel,
    required this.removeTooltip,
    required this.onRemove,
    required this.children,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppSpacing.smd),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.smd),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        leading: widget.leading,
        title: widget.title,
        subtitle: widget.subtitle,
        // A custom trailing replaces ExpansionTile's own arrow, so the rotation is done here.
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.countLabel,
              style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
            ),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more, color: AppColors.subtle),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              tooltip: widget.removeTooltip,
              onPressed: widget.onRemove,
            ),
          ],
        ),
        children: widget.children,
      ),
    );
  }
}
