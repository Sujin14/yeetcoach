import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yeetcoach/core/services/push_notification_service.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/photo_picker_helper.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/auth/presentation/controllers/auth_controller.dart';
import 'package:yeetcoach/features/coach/domain/entities/coach_profile.dart';
import 'package:yeetcoach/features/coach/domain/repositories/i_coach_repository.dart';
import '../../domain/repositories/i_settings_repository.dart';

class SettingsController extends GetxController {
  static const privacyPolicyUrl = 'https://yeetfit.app/privacy';
  static const termsUrl = 'https://yeetfit.app/terms';
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.sujin.yeetcoach';
  static const supportEmailUrl = 'mailto:sujinksureshofcl@gmail.com?subject=YeetCoach%20Support';

  final ICoachRepository _coachRepo;
  final ISettingsRepository _settingsRepo;
  final PushNotificationService _pushNotifications;
  final FirebaseAuth _auth;

  SettingsController(
    this._coachRepo,
    this._settingsRepo,
    this._pushNotifications, {
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final Rx<CoachProfile?> profile = Rx<CoachProfile?>(null);
  final RxBool isLoadingProfile = true.obs;
  final RxBool isUploadingPhoto = false.obs;
  final RxBool isSavingProfile = false.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool callNotificationsEnabled = true.obs;
  final RxString appVersion = ''.obs;
  final RxBool isDeletingAccount = false.obs;

  StreamSubscription<CoachProfile?>? _profileSub;

  String get _uid => _auth.currentUser?.uid ?? '';

  String get email => _auth.currentUser?.email ?? profile.value?.email ?? '';

  /// Google-only accounts have no password to reset.
  bool get canChangePassword =>
      email.isNotEmpty &&
      (_auth.currentUser?.providerData.any((info) => info.providerId == 'password') ?? false);

  @override
  void onInit() {
    super.onInit();
    _loadLocalSettings();
    if (_uid.isEmpty) {
      isLoadingProfile.value = false;
      return;
    }
    _profileSub = _coachRepo.watchCoach(_uid).listen(
      (coach) {
        profile.value = coach;
        isLoadingProfile.value = false;
      },
      onError: (Object e) {
        logDebug('SettingsController: watchCoach error: $e');
        isLoadingProfile.value = false;
      },
    );
  }

  Future<void> _loadLocalSettings() async {
    try {
      notificationsEnabled.value = await _settingsRepo.getNotificationsEnabled();
      callNotificationsEnabled.value = await _settingsRepo.getCallNotificationsEnabled();
    } catch (e) {
      logDebug('SettingsController: reading notifications preferences failed: $e');
    }
    try {
      appVersion.value = await _settingsRepo.getAppVersion();
    } catch (e) {
      logDebug('SettingsController: reading app version failed: $e');
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<void> changePhoto(BuildContext context) async {
    if (_uid.isEmpty || isUploadingPhoto.value) return;
    final file = await pickAndCropProfilePhoto(context);
    if (file == null) return;
    isUploadingPhoto.value = true;
    try {
      final url = await _coachRepo.uploadProfilePhoto(_uid, file);
      await _coachRepo.mergeCoachFields(_uid, {'profileImageUrl': url});
      await _syncAuthProfile(photoUrl: url);
      showSuccessSnackbar('Profile photo updated.');
    } catch (e) {
      logDebug('SettingsController: photo upload failed: $e');
      showErrorSnackbar('Could not update your photo. Please try again.');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<bool> updateName(String name) => _save({'name': name.trim()}, authName: name.trim());

  Future<bool> updateSpecializations(List<String> specializations) =>
      _save({'specializations': specializations});

  Future<bool> saveProfile({
    required String name,
    required String bio,
    required List<String> specializations,
    required int? experienceYears,
    required String phoneNumber,
  }) {
    return _save(
      {
        'name': name.trim(),
        'bio': bio.trim(),
        'specializations': specializations,
        'experience': experienceYears,
        'phoneNumber': phoneNumber.trim(),
      },
      authName: name.trim(),
    );
  }

  /// Returns true when saved, so the sheet can close.
  Future<bool> _save(Map<String, dynamic> fields, {String? authName}) async {
    if (_uid.isEmpty || isSavingProfile.value) return false;
    isSavingProfile.value = true;
    try {
      await _coachRepo.mergeCoachFields(_uid, fields);
      if (authName != null) await _syncAuthProfile(name: authName);
      showSuccessSnackbar('Profile updated.');
      return true;
    } catch (e) {
      logDebug('SettingsController: saving profile failed: $e');
      showErrorSnackbar('Could not save your profile. Please try again.');
      return false;
    } finally {
      isSavingProfile.value = false;
    }
  }

  /// The Firestore profile is already saved, so an Auth profile failure is only logged.
  Future<void> _syncAuthProfile({String? name, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      if (name != null && name != user.displayName) await user.updateDisplayName(name);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);
    } catch (e) {
      logDebug('SettingsController: updating the Auth profile failed: $e');
    }
  }

  // ── Account ───────────────────────────────────────────────────────────────

  Future<void> sendPasswordReset() async {
    final address = email;
    if (address.isEmpty) return;
    if (await Get.find<AuthController>().sendPasswordReset(address)) {
      showSuccessSnackbar('Password reset email sent to $address');
    }
  }

  /// With both toggles off, this device's FCM token is removed from the coach profile so
  /// no pushes arrive at all; turning either back on stores it again.
  Future<void> setNotificationsEnabled(bool enabled) => _setToggle(
        notificationsEnabled,
        enabled,
        enabled ? _pushNotifications.enableNotifications : _pushNotifications.disableNotifications,
      );

  Future<void> setCallNotificationsEnabled(bool enabled) => _setToggle(
        callNotificationsEnabled,
        enabled,
        enabled
            ? _pushNotifications.enableCallNotifications
            : _pushNotifications.disableCallNotifications,
      );

  Future<void> _setToggle(RxBool toggle, bool enabled, Future<void> Function() apply) async {
    toggle.value = enabled;
    try {
      await apply();
    } catch (e) {
      logDebug('SettingsController: saving notification preference failed: $e');
      toggle.value = !enabled;
      showErrorSnackbar('Could not save this setting. Please try again.');
    }
  }

  Future<void> openLink(String url) async {
    try {
      final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('No app can open $url');
    } catch (e) {
      logDebug('SettingsController: opening $url failed: $e');
      showErrorSnackbar(
        url.startsWith('mailto:')
            ? 'No email app found. Write to sujinksureshofcl@gmail.com.'
            : 'Could not open the link. Please try again.',
      );
    }
  }

  // ── Danger zone ───────────────────────────────────────────────────────────

  /// Clears the FCM token and the Google session, then opens login with no back stack.
  Future<void> signOut() => Get.find<AuthController>().logout();

  Future<void> deleteAccount() async {
    if (isDeletingAccount.value) return;
    isDeletingAccount.value = true;
    try {
      await _settingsRepo.deleteAccount();
    } on FirebaseFunctionsException catch (e) {
      logDebug('SettingsController: deleteAccount failed: ${e.code} — ${e.message}');
      isDeletingAccount.value = false;
      showErrorSnackbar(
        e.code == 'unavailable' || e.code == 'deadline-exceeded'
            ? 'Could not reach the server. Check your connection and try again.'
            : 'Could not delete your account. Please try again or contact support.',
      );
      return;
    } catch (e) {
      logDebug('SettingsController: deleteAccount failed: $e');
      isDeletingAccount.value = false;
      showErrorSnackbar('Could not delete your account. Please try again or contact support.');
      return;
    }
    // The Auth user is already gone server-side; this only clears local session state.
    await signOut();
  }

  @override
  void onClose() {
    _profileSub?.cancel();
    super.onClose();
  }
}
