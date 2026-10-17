import 'package:flutter/material.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      footer: AuthFooterLink(
        action: 'Back to Login',
        // Navigator rather than Get.back, which closes an open snackbar instead of the route.
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      child: const ForgotPasswordForm(),
    );
  }
}
