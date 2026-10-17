import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import 'auth_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Form(
        key: formKey,
        child: Column(
          children: [
            AuthTextField(
              controller: emailController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.validateEmail,
            ),
            AuthTextField(
              controller: passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: FormValidators.validatePassword,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: Text(
                  'Forgot password?',
                  style: AppTheme.light.textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomButton(
                text: 'Login',
                isLoading: authController.isLoading.value,
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await authController.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
