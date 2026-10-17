import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

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
        final isLoading = controller.isLoading.value;
        return OutlinedButton(
          onPressed: isLoading ? null : controller.loginWithGoogle,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            disabledBackgroundColor: AppColors.surface,
            foregroundColor: AppColors.onSurface,
            side: const BorderSide(color: AppColors.divider),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                    )
                  : Image.asset('assets/images/google_logo.png', width: 24, height: 24),
              const SizedBox(width: AppSpacing.smd),
              Text(
                'Continue with Google',
                style: AppTheme.light.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
