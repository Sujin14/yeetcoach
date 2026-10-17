import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/onboarding_controller.dart';

class Step1BasicInfo extends GetView<OnboardingController> {
  const Step1BasicInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile photo picker
          Center(
            child: Obx(() {
              final img = controller.profileImage.value;
              return GestureDetector(
                onTap: () => controller.pickProfilePhoto(context),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.divider,
                  backgroundImage:
                      img != null ? FileImage(img) : null,
                  child: img == null
                      ? const Icon(Icons.add_a_photo_outlined,
                          size: 32, color: AppColors.subtle)
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text('Add a profile photo',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onPrimary.withValues(alpha: 0.8))),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Your Name',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller.nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Full name',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: 14),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('About You',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller.bioController,
            maxLines: 5,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText:
                  'Tell clients about your background, approach and what makes you different…',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              alignLabelWithHint: true,
              counterStyle: TextStyle(
                  fontSize: 12,
                  color: AppColors.onPrimary.withValues(alpha: 0.8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
