import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/onboarding_controller.dart';
import 'cert_form.dart';

class Step3Certifications extends GetView<OnboardingController> {
  const Step3Certifications({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Certifications',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text('Optional — add any relevant certifications.',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onPrimary.withValues(alpha: 0.8))),
          const SizedBox(height: AppSpacing.md),

          // Existing certifications
          Obx(() {
            final certs = controller.certifications;
            if (certs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
                child: Text('No certifications added yet.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onPrimary.withValues(alpha: 0.8))),
              );
            }
            return Column(
              children: List.generate(certs.length, (i) {
                final c = certs[i];
                return Card(
                  elevation: 1,
                  shadowColor: const Color(0x0D000000),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(c.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.onSurface)),
                    subtitle: Text('${c.issuer} · ${c.year}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.subtle)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 20),
                      onPressed: () =>
                          controller.removeCertification(i),
                    ),
                  ),
                );
              }),
            );
          }),

          const SizedBox(height: AppSpacing.smd),

          // Inline add form
          Obx(() {
            if (!controller.showCertForm.value) {
              return TextButton.icon(
                onPressed: controller.openCertForm,
                icon: const Icon(Icons.add, color: AppColors.onPrimary),
                label: const Text('Add Certification',
                    style: TextStyle(color: AppColors.onPrimary)),
              );
            }
            return const CertForm();
          }),
        ],
      ),
    );
  }
}
