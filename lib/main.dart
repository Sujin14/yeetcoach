import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/navigation/app_page_route.dart';
import 'core/routes/app_routes.dart';
import 'core/services/call_accept_handler.dart';
import 'core/services/call_native_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/email_auth_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/coach/data/repositories/coach_repository.dart';
import 'features/coach/domain/repositories/i_coach_repository.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  GoogleFonts.config.allowRuntimeFetching = false;
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authRepository = AuthRepositoryImpl(EmailAuthService());
  final coachRepository = CoachRepository();
  final pushNotifications = Get.put(PushNotificationService(coachRepository), permanent: true);
  await pushNotifications.init();
  CallNativeService.setOnCallAccepted(handleAcceptedCall);
  final initialRoute = await _resolveInitialRoute(authRepository, coachRepository);

  Get.put<AuthController>(AuthController(authRepository, coachRepository, pushNotifications));

  final startsAtHome = initialRoute == AppRoutes.home;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (startsAtHome && uid != null) await pushNotifications.registerCoach(uid);

  // Splash plays first, then continues to the route resolved above.
  // A notification tap only routes for a coach who is already past login and onboarding,
  // and only after splash has left, so it isn't wiped by offAllNamed.
  // Cold-start call accepts are handled in splash (skip animation) and never use afterNavigation.
  Get.put(
    PostSplashRoute(
      initialRoute,
      afterNavigation: () => widgetsBinding.addPostFrameCallback((_) async {
            if (startsAtHome) await pushNotifications.handleLaunchTap();
          }),
    ),
    permanent: true,
  );

  runApp(const MyApp());
}

/// Ends a persisted session whose role is explicitly disallowed; returns true if it signed out.
/// If the role can't be read (e.g. offline), the session is kept and Firestore
/// security rules still guard the data.
Future<bool> _signOutIfDisallowedRole(AuthRepository repository, String uid) async {
  final String? role;
  try {
    role = await repository.getRole(uid);
  } catch (error) {
    logDebug('Startup role check skipped, role unavailable: $error');
    return false;
  }
  if (!AuthController.isDisallowedRole(role)) return false;
  await repository.signOut();
  return true;
}

/// A logged-in coach without a coach profile must finish onboarding before reaching home.
/// If the profile can't be read (e.g. offline), the coach goes home rather than being blocked.
Future<String> _resolveInitialRoute(
  AuthRepository authRepository,
  ICoachRepository coachRepository,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return AppRoutes.login;

  final bool hasCoachProfile;
  try {
    hasCoachProfile = await coachRepository.getCoach(user.uid) != null;
  } catch (error) {
    logDebug('Startup coach profile check skipped: $error');
    return AppRoutes.home;
  }
  if (!hasCoachProfile) return AppRoutes.onboarding;

  return await _signOutIfDisallowedRole(authRepository, user.uid) ? AppRoutes.login : AppRoutes.home;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 873),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.routes,
        theme: AppTheme.light,
        // iOS keeps the native Cupertino slide (and its swipe-back gesture) at GetX's default duration.
        defaultTransition: GetPlatform.isIOS ? Transition.native : null,
        customTransition: GetPlatform.isIOS ? null : AppGetTransition(),
        transitionDuration: GetPlatform.isIOS ? null : AppPageTransition.duration,
      ),
    );
  }
}
