import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/onboarding_controller.dart';

class CertForm extends GetView<OnboardingController> {
  const CertForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: const Color(0x0D000000),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.certTitleController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Certificate name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.smd, vertical: AppSpacing.smd),
              ),
            ),
            const SizedBox(height: AppSpacing.smd),
            TextField(
              controller: controller.certIssuerController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Issuing body',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.smd, vertical: AppSpacing.smd),
              ),
            ),
            const SizedBox(height: AppSpacing.smd),
            Obx(() => Row(
                  children: [
                    const Text('Year: ',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.onSurface)),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () => controller.certYear.value--,
                    ),
                    Text('${controller.certYear.value}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.onSurface)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        if (controller.certYear.value <
                            DateTime.now().year) {
                          controller.certYear.value++;
                        }
                      },
                    ),
                  ],
                )),
            const SizedBox(height: AppSpacing.smd),
            Row(
              children: [
                TextButton(
                  onPressed: controller.cancelCertForm,
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.subtle)),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: controller.saveCertification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
