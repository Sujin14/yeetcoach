import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Translucent text field for the auth screens, which sit directly on the darkened photo.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    // Every border state is set explicitly: the app theme's light-mode borders would otherwise apply.
    final idleBorder = _border(Colors.white.withValues(alpha: 0.3));

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white70),
          floatingLabelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.12),
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          prefixIconColor: Colors.white70,
          suffixIcon: suffixIcon,
          suffixIconColor: Colors.white70,
          border: idleBorder,
          enabledBorder: idleBorder,
          focusedBorder: _border(Colors.white),
          errorBorder: _border(AppColors.error),
          focusedErrorBorder: _border(AppColors.error),
        ),
      ),
    );
  }
}
