import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingBottomBar extends GetView<OnboardingController> {
  const OnboardingBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.currentStep.value;
      final loading = controller.isLoading.value;
      final isLast = step == OnboardingController.totalSteps - 1;

      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
        child: Row(
          children: [
            if (step > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: loading ? null : controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppColors.onPrimary.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Back',
                      style: TextStyle(color: AppColors.onPrimary)),
                ),
              ),
            if (step > 0) const SizedBox(width: AppSpacing.smd),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : (isLast
                        ? controller.completeOnboarding
                        : controller.nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(isLast ? 'Complete Setup' : 'Next'),
              ),
            ),
          ],
        ),
      );
    });
  }
}
