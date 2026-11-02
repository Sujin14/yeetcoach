import 'package:get/get.dart';
import '../../features/auth/presentation/bindings/onboarding_binding.dart';
import '../../features/calls/presentation/bindings/call_binding.dart';
import '../../features/calls/presentation/bindings/call_setup_binding.dart';
import '../../features/calls/presentation/bindings/incoming_call_binding.dart';
import '../../features/calls/presentation/screens/call_screen.dart';
import '../../features/calls/presentation/screens/call_setup_screen.dart';
import '../../features/calls/presentation/screens/incoming_call_screen.dart';
import '../../features/challenges/presentation/bindings/challenge_detail_binding.dart';
import '../../features/challenges/presentation/screens/challenge_detail_screen.dart';
import '../../features/chat/presentation/bindings/chat_binding.dart';
import '../../features/chat/presentation/bindings/chat_inbox_binding.dart';
import '../../features/chat/presentation/screens/chat_inbox_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/clients/presentation/bindings/client_detail_binding.dart';
import '../../features/clients/presentation/screens/client_detail_screen.dart';
import '../../features/home/presentation/bindings/home_shell_binding.dart';
import '../../features/home/presentation/screens/all_clients_screen.dart';
import '../../features/home/presentation/screens/home_shell_screen.dart';
import '../../features/home/presentation/screens/requests_screen.dart';
import '../../features/notifications/presentation/bindings/notifications_binding.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/plan/domain/entities/plan_type.dart';
import '../../features/plan/presentation/bindings/plan_form_binding.dart';
import '../../features/plan/presentation/bindings/plan_list_binding.dart';
import '../../features/plan/presentation/screens/plan_form_screen.dart';
import '../../features/plan/presentation/screens/plan_list_screen.dart';
import '../../features/settings/presentation/bindings/settings_binding.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/terms_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'auth_middleware.dart';
import 'guest_middleware.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const settings = '/settings';
  static const privacyPolicy = '/settings/privacy-policy';
  static const terms = '/settings/terms';
  static const home = '/home';
  static const notifications = '/home/notifications';
  static const requests = '/home/requests';
  static const clients = '/home/clients';
  static const clientDetails = '/home/client-details';
  static const planList = '/home/plan-list';
  static const planForm = '/home/plan-form';
  static const call = '/home/call';
  static const incomingCall = '/home/incoming-call';
  static const callSetup = '/home/call-setup';
  static const chats = '/home/chats';
  static const chat = '/home/chat';
  static const challengeDetails = '/home/challenge-details';

  static const List<String> goals = ['Weight Loss', 'Weight Gain', 'Muscle Building'];
  static const String coachRole = 'admin';

  static String planControllerTag(String uid, PlanType type) => 'plan-$uid-${type.value}';
  static String chatControllerTag(String clientUid) => 'chat-$clientUid';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignUpScreen()),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: terms,
      page: () => const TermsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: home,
      page: () => const HomeShellScreen(),
      binding: HomeShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: requests,
      page: () => const RequestsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: clients,
      page: () => const AllClientsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: clientDetails,
      page: () => const ClientDetailScreen(),
      binding: ClientDetailBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: planList,
      page: () => const PlanListScreen(),
      binding: PlanListBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: planForm,
      page: () => const PlanFormScreen(),
      binding: PlanFormBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: call,
      page: () => const CallScreen(),
      binding: CallBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: incomingCall,
      page: () => const IncomingCallScreen(),
      binding: IncomingCallBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: callSetup,
      page: () => const CallSetupScreen(),
      binding: CallSetupBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: chats,
      page: () => const ChatInboxScreen(),
      binding: ChatInboxBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: chat,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: challengeDetails,
      page: () => const ChallengeDetailScreen(),
      binding: ChallengeDetailBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
