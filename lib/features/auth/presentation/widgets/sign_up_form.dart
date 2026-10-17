import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import 'auth_text_field.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
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
              controller: nameController,
              labelText: 'Name',
              prefixIcon: Icons.person_outline,
              validator: FormValidators.validateUserName,
            ),
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
              obscureText: !showPassword,
              validator: FormValidators.validatePassword,
              suffixIcon: IconButton(
                icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => showPassword = !showPassword),
              ),
            ),
            AuthTextField(
              controller: confirmPasswordController,
              labelText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              obscureText: !showConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                return null;
              },
              suffixIcon: IconButton(
                icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () =>
                    setState(() => showConfirmPassword = !showConfirmPassword),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomButton(
                text: 'Sign Up',
                isLoading: authController.isLoading.value,
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await authController.signUp(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      confirmPasswordController.text.trim(),
                      nameController.text.trim(),
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
