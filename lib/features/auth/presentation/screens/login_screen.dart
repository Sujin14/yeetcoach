import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/google_login_button.dart';
import '../widgets/login_form.dart';
import '../widgets/or_divider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      tagline: 'Your coaching companion',
      footer: AuthFooterLink(
        prompt: "Don't have an account?",
        action: 'Sign up',
        onPressed: () => Get.toNamed(AppRoutes.signup),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoginForm(),
          SizedBox(height: AppSpacing.md),
          OrDivider(),
          SizedBox(height: AppSpacing.md),
          GoogleLoginButton(),
        ],
      ),
    );
  }
}
