import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';
import 'coach_avatar.dart';
import 'edit_name_sheet.dart';
import 'edit_profile_sheet.dart';
import 'edit_specializations_sheet.dart';
import 'settings_sheet.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

const _cardShadow = [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))];

class ProfileCard extends GetView<SettingsController> {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingProfile.value) return const _ProfileCardShimmer();
      final profile = controller.profile.value;
      final name = profile?.name ?? '';
      final specializations = profile?.specializations ?? const <String>[];

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow,
        ),
        child: Column(
          children: [
            _EditableAvatar(name: name, photoUrl: profile?.profileImageUrl),
            const SizedBox(height: AppSpacing.smd),
            _EditableText(
              text: name.isEmpty ? 'Add your name' : name,
              isPlaceholder: name.isEmpty,
              style: _textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              tooltip: 'Edit name',
              onTap: profile == null
                  ? null
                  : () => SettingsSheet.show(EditNameSheet(initialName: name)),
            ),
            if (controller.email.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                controller.email,
                textAlign: TextAlign.center,
                style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _EditableText(
              text: specializations.isEmpty
                  ? 'Add your specialization'
                  : specializations.join(' · '),
              isPlaceholder: specializations.isEmpty,
              style: _textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              tooltip: 'Edit specializations',
              onTap: profile == null
                  ? null
                  : () => SettingsSheet.show(EditSpecializationsSheet(initial: specializations)),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: profile == null
                    ? null
                    : () => SettingsSheet.show(EditProfileSheet(profile: profile)),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  'Edit Profile',
                  style: _textTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _EditableAvatar extends GetView<SettingsController> {
  final String name;
  final String? photoUrl;

  const _EditableAvatar({required this.name, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isUploading = controller.isUploadingPhoto.value;
      return Semantics(
        button: true,
        label: 'Change profile photo',
        child: GestureDetector(
          onTap: isUploading ? null : () => controller.changePhoto(context),
          child: Stack(
            children: [
              CoachAvatar(url: photoUrl, name: name, radius: 40),
              if (isUploading)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.onSurface.withValues(alpha: 0.45),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 14, color: AppColors.onPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Centered text with a trailing pencil; the whole row is the tap target.
class _EditableText extends StatelessWidget {
  final String text;
  final bool isPlaceholder;
  final TextStyle? style;
  final String tooltip;
  final VoidCallback? onTap;

  const _EditableText({
    required this.text,
    required this.isPlaceholder,
    required this.style,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: isPlaceholder ? style?.copyWith(color: AppColors.subtle) : style,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined, size: 16, color: AppColors.subtle),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCardShimmer extends StatelessWidget {
  const _ProfileCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: const ShimmerBase(
        child: Column(
          children: [
            ShimmerCircle(size: 80),
            SizedBox(height: 14),
            ShimmerBox(width: 160, height: 20, radius: 6),
            SizedBox(height: AppSpacing.sm),
            ShimmerBox(width: 190, height: 14, radius: 6),
            SizedBox(height: 10),
            ShimmerBox(width: 140, height: 13, radius: 6),
            SizedBox(height: 18),
            ShimmerBox(width: double.infinity, height: 44, radius: 24),
          ],
        ),
      ),
    );
  }
}
