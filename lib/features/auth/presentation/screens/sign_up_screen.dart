import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/google_login_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      tagline: 'Your coaching companion',
      footer: AuthFooterLink(
        prompt: 'Already have an account?',
        action: 'Login',
        onPressed: () => Get.back(),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SignUpForm(),
          SizedBox(height: AppSpacing.md),
          OrDivider(),
          SizedBox(height: AppSpacing.md),
          GoogleLoginButton(),
        ],
      ),
    );
  }
}
