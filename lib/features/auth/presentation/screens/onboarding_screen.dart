import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_bottom_bar.dart';
import '../widgets/step1_basic_info.dart';
import '../widgets/step2_specializations.dart';
import '../widgets/step3_certifications.dart';
import '../widgets/step_indicator.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // Let the controller handle going to the previous step instead.
        if (!didPop && controller.currentStep.value > 0) {
          controller.previousStep();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        // The photo sits outside the Scaffold so it doesn't resize when the keyboard opens.
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/onboarding_bg.webp', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.4)),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    const StepIndicator(),
                    Expanded(
                      child: PageView(
                        controller: controller.pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          Step1BasicInfo(),
                          Step2Specializations(),
                          Step3Certifications(),
                        ],
                      ),
                    ),
                    const OnboardingBottomBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
