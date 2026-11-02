import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/launch_coordinator.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../coach/domain/repositories/i_coach_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;
  final ICoachRepository _coachRepository;
  final PushNotificationService _pushNotifications;
  final LoginWithEmail loginWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final isLoading = false.obs;

  /// UI gate on the sign-up form. Not written to Firestore.
  final RxBool agreedToTerms = false.obs;

  /// null = coach profile check not run yet, true = profile exists, false = profile missing.
  final Rx<bool?> isOnboardingComplete = Rx<bool?>(null);

  AuthController(
    AuthRepository repository,
    ICoachRepository coachRepository,
    PushNotificationService pushNotifications,
  ) : _repository = repository,
      _coachRepository = coachRepository,
      _pushNotifications = pushNotifications,
      loginWithEmail = LoginWithEmail(repository),
      signUpWithEmail = SignUpWithEmail(repository);

  Future<void> login(String email, String password) async {
    final emailError = FormValidators.validateEmail(email);
    final passwordError = FormValidators.validatePassword(password);
    if (emailError != null || passwordError != null) {
      showErrorSnackbar(emailError ?? passwordError!, position: SnackPosition.TOP);
      return;
    }
    isLoading.value = true;
    try {
      final uid = await loginWithEmail(email, password);
      if (uid == null) {
        showErrorSnackbar('Login failed. Check your email and password.', position: SnackPosition.TOP);
        return;
      }
      await _routeAfterAuth(uid);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final user = await _repository.loginWithGoogle();
      if (user == null) return; // User cancelled the picker
      await _routeAfterAuth(user.uid);
    } catch (e) {
      logDebug('AuthController.loginWithGoogle error: $e');
      await _signOutAfterFailure();
      showErrorSnackbar('Google login failed. Please try again.', position: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password, String confirmPassword, String name) async {
    final emailError = FormValidators.validateEmail(email);
    final passwordError = FormValidators.validatePassword(password);
    final nameError = FormValidators.validateUserName(name);

    if (emailError != null || passwordError != null || nameError != null) {
      showErrorSnackbar(emailError ?? passwordError ?? nameError!, position: SnackPosition.TOP);
      return;
    }

    if (password != confirmPassword) {
      showErrorSnackbar('Passwords do not match', position: SnackPosition.TOP);
      return;
    }

    isLoading.value = true;
    try {
      final uid = await signUpWithEmail(email, password, name);
      if (uid == null) {
        showErrorSnackbar('Signup failed', position: SnackPosition.TOP);
        return;
      }
      await _routeAfterAuth(uid);
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns true when the reset email was sent; errors are shown as a snackbar.
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      logDebug('AuthController.sendPasswordReset error: ${e.code}');
      showErrorSnackbar(_passwordResetErrorMessage(e.code), position: SnackPosition.TOP);
      return false;
    } catch (e) {
      logDebug('AuthController.sendPasswordReset error: $e');
      showErrorSnackbar('Could not send the reset email. Please try again.', position: SnackPosition.TOP);
      return false;
    }
  }

  String _passwordResetErrorMessage(String code) => switch (code) {
        'invalid-email' => 'That email address is not valid.',
        'user-not-found' => 'No account found for that email.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' => 'No internet connection. Please try again.',
        _ => 'Could not send the reset email. Please try again.',
      };

  /// Called once the coach profile has been created, so the /home guard lets the coach through.
  void markOnboardingComplete() => isOnboardingComplete.value = true;

  Future<bool> logout() async {
    isLoading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) await _pushNotifications.clearToken(uid);
      await _repository.signOutGoogle();
      isOnboardingComplete.value = null;
      Get.offAllNamed(AppRoutes.login);
      return true;
    } catch (e) {
      showErrorSnackbar('Failed to log out: $e', position: SnackPosition.TOP);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// The role trigger may not have fired yet, so a missing role or 'user' is still a coach.
  /// Only an explicit other role (e.g. a non-coach account with a coaches doc) is rejected.
  static bool isDisallowedRole(String? role) =>
      role != null && role != AppRoutes.coachRole && role != 'user';

  /// The coach profile is the source of truth: it means home, its absence means onboarding.
  Future<void> _routeAfterAuth(String uid) async {
    final bool hasCoachProfile;
    try {
      hasCoachProfile = await _coachRepository.getCoach(uid) != null;
    } catch (e) {
      logDebug('AuthController: coach profile check failed: $e');
      await _signOutAfterFailure();
      showErrorSnackbar('Could not load your coach profile. Please try again.', position: SnackPosition.TOP);
      return;
    }
    if (hasCoachProfile && isDisallowedRole(await _readRole(uid))) {
      await _signOutAfterFailure();
      showErrorSnackbar('Not an admin account', position: SnackPosition.TOP);
      return;
    }
    logDebug('AuthController: routing $uid, coach profile exists: $hasCoachProfile');
    // fcmToken is stored on coaches/{uid}, so registration waits until the profile exists.
    if (hasCoachProfile) await _pushNotifications.registerCoach(uid);
    isOnboardingComplete.value = hasCoachProfile;
    Get.offAllNamed(hasCoachProfile ? AppRoutes.home : AppRoutes.onboarding);
    if (hasCoachProfile) LaunchCoordinator.instance.markHomeReady();
  }

  /// An unreadable role is treated as unset so a coach with a profile is never blocked by it.
  Future<String?> _readRole(String uid) async {
    try {
      return await _repository.getRole(uid);
    } catch (e) {
      logDebug('AuthController: role check skipped: $e');
      return null;
    }
  }

  /// Leaves no half-logged-in session behind when login can't be completed.
  Future<void> _signOutAfterFailure() async {
    try {
      await _repository.signOutGoogle();
    } catch (e) {
      logDebug('AuthController: sign-out after failed login failed: $e');
    }
  }
}
