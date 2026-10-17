import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import 'app_routes.dart';

/// Guards routes meant for signed-out users only (e.g. password reset).
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (FirebaseAuth.instance.currentUser == null) return null;

    final complete = Get.find<AuthController>().isOnboardingComplete.value;
    return RouteSettings(name: complete == false ? AppRoutes.onboarding : AppRoutes.home);
  }
}
