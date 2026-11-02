import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeetcoach/core/constants/legal_constants.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/core/utils/url_utils.dart';
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
            const _TermsAgreement(),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomButton(
                text: 'Sign Up',
                isLoading: authController.isLoading.value,
                onPressed: () async {
                  if (!authController.agreedToTerms.value) {
                    showErrorSnackbar(
                      'Please accept the Terms & Conditions and Privacy Policy to continue.',
                      position: SnackPosition.TOP,
                    );
                    return;
                  }
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

class _TermsAgreement extends StatefulWidget {
  const _TermsAgreement();

  @override
  State<_TermsAgreement> createState() => _TermsAgreementState();
}

class _TermsAgreementState extends State<_TermsAgreement> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  final AuthController _controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = () => _open(kTermsUrl);
    _privacyRecognizer = TapGestureRecognizer()..onTap = () => _open(kPrivacyUrl);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    try {
      await launchUrlExternal(url);
    } catch (e) {
      logDebug('SignUpForm: opening $url failed: $e');
      showErrorSnackbar('Could not open the link. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: AppColors.primary,
      decoration: TextDecoration.underline,
    );
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _controller.agreedToTerms.value,
            onChanged: (value) => _controller.agreedToTerms.value = value ?? false,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: linkStyle,
                      recognizer: _termsRecognizer,
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: linkStyle,
                      recognizer: _privacyRecognizer,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
