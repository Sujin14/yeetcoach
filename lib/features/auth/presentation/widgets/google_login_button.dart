import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/shared/widgets/shimmer_sweep.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Obx(() {
        final busy = controller.isBusy;
        final shimmering = controller.isGoogleLoading;
        final content = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/google_logo.png', width: 24, height: 24),
            const SizedBox(width: AppSpacing.smd),
            Text(
              'Continue with Google',
              style: AppTheme.light.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: AppColors.onSurface,
              ),
            ),
          ],
        );

        return OutlinedButton(
          // Empty callback while busy keeps the normal enabled look (no grey-out).
          onPressed: busy ? () {} : controller.loginWithGoogle,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.onSurface,
            side: const BorderSide(color: AppColors.divider),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: shimmering
              ? ShimmerSweep(
                  baseColor: AppColors.onSurface.withValues(alpha: 0.35),
                  highlightColor: AppColors.onSurface.withValues(alpha: 0.85),
                  child: content,
                )
              : content,
        );
      }),
    );
  }
}
