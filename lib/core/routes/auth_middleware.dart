import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final user = FirebaseAuth.instance.currentUser;

    // Not logged in → always send to login
    if (user == null) return const RouteSettings(name: AppRoutes.login);

    // Logged in — guard /home and its children
    if (route != null &&
        (route == AppRoutes.home || route.startsWith('/home/'))) {
      // Check is still running (null) → allow through; _routeAfterAuth
      // will re-route if needed once the check completes.
      final complete = Get.find<AuthController>().isOnboardingComplete.value;
      if (complete == false) {
        return const RouteSettings(name: AppRoutes.onboarding);
      }
    }

    return null; // No redirect
  }
}
