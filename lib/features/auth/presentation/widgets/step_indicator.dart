import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/onboarding_controller.dart';

class StepIndicator extends GetView<OnboardingController> {
  const StepIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    const labels = ['About You', 'Specializations', 'Certifications'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 20, AppSpacing.lg, AppSpacing.sm),
      child: Obx(() {
        final step = controller.currentStep.value;
        return Row(
          children: List.generate(OnboardingController.totalSteps, (i) {
            final active = i == step;
            final done = i < step;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 4,
                          decoration: BoxDecoration(
                            color: done || active
                                ? AppColors.primary
                                : AppColors.onPrimary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: active || done
                                ? AppColors.onPrimary
                                : AppColors.onPrimary.withValues(alpha: 0.7),
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < OnboardingController.totalSteps - 1)
                    const SizedBox(width: AppSpacing.sm),
                ],
              ),
            );
          }),
        );
      }),
    );
  }
}
