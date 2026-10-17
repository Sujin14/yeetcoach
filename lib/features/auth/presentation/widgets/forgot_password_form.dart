import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import 'auth_text_field.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();
  final emailController = TextEditingController();
  bool isSending = false;
  bool isSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => isSending = true);
    final sent = await authController.sendPasswordReset(emailController.text.trim());
    if (!mounted) return;
    setState(() {
      isSending = false;
      isSent = sent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = AppTheme.light.textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Forgot your password?',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Enter your account email and we'll send you a link to reset it.",
            style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp, color: Colors.white70),
          ),
          SizedBox(height: 12.h),
          AuthTextField(
            controller: emailController,
            labelText: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.validateEmail,
          ),
          if (isSent) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Check your email for a reset link',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          SizedBox(
            height: 48,
            child: CustomButton(
              text: 'Send Reset Link',
              isLoading: isSending,
              onPressed: isSent ? null : _sendResetLink,
            ),
          ),
        ],
      ),
    );
  }
}
