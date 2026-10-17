import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/person_avatar.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/challenge.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// "Assigned to" with up to [maxVisible] overlapping avatars and "+N more".
class AssignedAvatarsRow extends StatelessWidget {
  static const double _size = 28;
  static const double _overlap = 8;

  final List<String> uids;
  final Map<String, ChallengeMember> members;
  final int maxVisible;

  const AssignedAvatarsRow({
    super.key,
    required this.uids,
    required this.members,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle);
    if (uids.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.public, size: 16, color: AppColors.subtle),
          const SizedBox(width: 6),
          Text('Open to all YeetFit users', style: labelStyle),
        ],
      );
    }

    final visible = uids.take(maxVisible).toList();
    final extra = uids.length - visible.length;
    return Row(
      children: [
        Text('Assigned to', style: labelStyle),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: _size + (visible.length - 1) * (_size - _overlap),
          height: _size,
          child: Stack(
            children: [
              for (var i = 0; i < visible.length; i++)
                Positioned(
                  left: i * (_size - _overlap),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: PersonAvatar(
                      name: members[visible[i]]?.name ?? '',
                      photoUrl: members[visible[i]]?.photoUrl ?? '',
                      size: _size - 4,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (extra > 0) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            '+$extra more',
            style: labelStyle?.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
        ],
      ],
    );
  }
}
