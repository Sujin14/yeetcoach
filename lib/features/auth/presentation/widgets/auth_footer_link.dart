import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

/// "Prompt? Action" link at the bottom of the auth screens; [prompt] may be omitted.
class AuthFooterLink extends StatelessWidget {
  final String? prompt;
  final String action;
  final VoidCallback onPressed;

  const AuthFooterLink({
    super.key,
    this.prompt,
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTheme.light.textTheme.bodyMedium?.copyWith(fontSize: 14.sp, color: Colors.white70);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            if (prompt != null) TextSpan(text: '$prompt '),
            TextSpan(
              text: action,
              style: style?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
