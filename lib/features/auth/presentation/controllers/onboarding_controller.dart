import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/services/call_native_service.dart';
import 'package:yeetcoach/core/services/push_notification_service.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/photo_picker_helper.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/coach/domain/entities/coach_profile.dart';
import 'auth_controller.dart';

class OnboardingController extends GetxController {
  // ── Navigation ────────────────────────────────────────────────
  final RxInt currentStep = 0.obs;
  static const int totalSteps = 3;

  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    // Pre-fill name from the Firebase Auth account (Google provides this).
    final displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    nameController.text = displayName;
  }

  @override
  void onClose() {
    pageController.dispose();
    nameController.dispose();
    bioController.dispose();
    certTitleController.dispose();
    certIssuerController.dispose();
    super.onClose();
  }

  // ── Step 1 — Basic info ───────────────────────────────────────
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final Rx<File?> profileImage = Rx<File?>(null);

  Future<void> pickProfilePhoto(BuildContext context) async {
    final file = await pickAndCropProfilePhoto(context);
    if (file != null) profileImage.value = file;
  }

  bool get step1Valid =>
      nameController.text.trim().isNotEmpty &&
      bioController.text.trim().length >= 20;

  // ── Step 2 — Specializations ──────────────────────────────────
  static const List<String> allSpecializations = [
    'Fat Loss & Weight Management',
    'Muscle Building & Hypertrophy',
    'Strength & Powerlifting',
    'Bodybuilding & Competition Prep',
    'Sports Performance & Athletic Training',
    'Injury Rehabilitation & Recovery',
    'Functional Fitness & Mobility',
    'Senior & Adaptive Fitness',
    'Yoga & Flexibility',
    'HIIT & Cardio Conditioning',
    'Nutrition & Macro Coaching',
    'Pre/Postnatal Fitness',
  ];

  final RxSet<String> selectedSpecializations = <String>{}.obs;

  void toggleSpecialization(String spec) {
    if (selectedSpecializations.contains(spec)) {
      selectedSpecializations.remove(spec);
    } else {
      selectedSpecializations.add(spec);
    }
  }

  bool get step2Valid => selectedSpecializations.isNotEmpty;

  // ── Step 3 — Certifications ───────────────────────────────────
  final RxList<Certification> certifications = <Certification>[].obs;

  // Inline add-cert form state
  final TextEditingController certTitleController = TextEditingController();
  final TextEditingController certIssuerController = TextEditingController();
  final RxInt certYear = DateTime.now().year.obs;
  final RxBool showCertForm = false.obs;

  void openCertForm() => showCertForm.value = true;

  void cancelCertForm() {
    certTitleController.clear();
    certIssuerController.clear();
    certYear.value = DateTime.now().year;
    showCertForm.value = false;
  }

  void saveCertification() {
    final title = certTitleController.text.trim();
    final issuer = certIssuerController.text.trim();
    if (title.isEmpty || issuer.isEmpty) {
      showErrorSnackbar('Enter both the certificate name and issuing body.');
      return;
    }
    certifications.add(
      Certification(title: title, issuer: issuer, year: certYear.value),
    );
    cancelCertForm();
  }

  void removeCertification(int index) => certifications.removeAt(index);

  // Certifications are optional; step 3 is always valid.
  bool get step3Valid => true;

  // ── Navigation helpers ────────────────────────────────────────
  void goToStep(int step) {
    currentStep.value = step;
    pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void nextStep() {
    if (currentStep.value == 0 && !step1Valid) {
      showErrorSnackbar(
        nameController.text.trim().isEmpty
            ? 'Enter your name.'
            : 'Bio must be at least 20 characters.',
      );
      return;
    }
    if (currentStep.value == 1 && !step2Valid) {
      showErrorSnackbar('Select at least one specialization.');
      return;
    }
    if (currentStep.value < totalSteps - 1) {
      goToStep(currentStep.value + 1);
    }
  }

  void previousStep() {
    if (currentStep.value > 0) goToStep(currentStep.value - 1);
  }

  // ── Submit ────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;

  Future<void> completeOnboarding() async {
    if (!step3Valid) return;
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        logDebug('OnboardingController: no logged-in user');
        showErrorSnackbar('Your session has expired. Please log in again.');
        return;
      }
      final uid = user.uid;
      final name = nameController.text.trim();

      String? photoUrl;
      final image = profileImage.value;
      if (image != null) {
        final ref = FirebaseStorage.instance.ref(
          'coach_profiles/$uid/profile.jpg',
        );
        await ref.putFile(image);
        photoUrl = await ref.getDownloadURL();
      }

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      // isVerified, averageRating and totalClients are set by a Cloud Function trigger.
      batch.set(firestore.collection(FirestoreCollections.coaches).doc(uid), <String, dynamic>{
        'uid': uid,
        'name': name,
        'email': user.email,
        'bio': bioController.text.trim(),
        'profileImageUrl': photoUrl,
        'isActive': true,
        'specializations': selectedSpecializations.toList(),
        'certifications': certifications
            .map(
              (c) => <String, dynamic>{
                'title': c.title,
                'issuer': c.issuer,
                'year': c.year,
              },
            )
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Mirrored so YeetFit can show the coach. A missing photo must not wipe an existing one.
      batch.set(
        firestore.collection(FirestoreCollections.users).doc(uid),
        <String, dynamic>{
          'name': name,
          'profilePicture': ?photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      await batch.commit();

      // The profile is already saved, so a display-name failure must not block the coach.
      try {
        await user.updateDisplayName(name);
      } catch (e) {
        logDebug('OnboardingController: updateDisplayName failed: $e');
      }

      logDebug('OnboardingController: registration complete');
      await Get.find<PushNotificationService>().registerCoach(uid);
      // Without this, AuthMiddleware would bounce /home back to onboarding.
      Get.find<AuthController>().markOnboardingComplete();
      CallNativeService.homeReady = true;
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseException catch (e) {
      logDebug('OnboardingController Firebase error: ${e.plugin}/${e.code} — ${e.message}');
      showErrorSnackbar('Setup failed. Please try again.');
    } catch (e) {
      logDebug('OnboardingController error: $e');
      showErrorSnackbar('Setup failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
