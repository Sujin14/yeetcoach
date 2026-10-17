import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final body = _textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      height: 1.5,
      color: AppColors.onSurface,
    );
    final heading = _textTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: AppColors.onSurface,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Privacy Policy',
          style: _textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SelectableText.rich(
              TextSpan(
                style: body,
                children: [
                  TextSpan(
                    text: 'Last updated: October 2026\n\n',
                    style: body?.copyWith(color: AppColors.subtle),
                  ),
                  TextSpan(text: 'What we collect\n', style: heading),
                  const TextSpan(
                    text: 'Your name, email, profile photo, coaching bio and specializations, '
                        'certifications, and client communication data (messages, call logs) — '
                        'stored on Firebase (Google Cloud).\n\n',
                  ),
                  TextSpan(text: 'How we use it\n', style: heading),
                  const TextSpan(
                    text: 'To provide the YeetCoach coaching platform, manage your coach profile, '
                        'and facilitate client interactions. Data is not sold to third parties.\n\n',
                  ),
                  TextSpan(text: 'Your clients’ data\n', style: heading),
                  const TextSpan(
                    text: 'Client information you access through YeetCoach is provided by YeetFit '
                        'users who have connected with you. You must handle it responsibly and in '
                        'accordance with applicable laws.\n\n',
                  ),
                  TextSpan(text: 'Data deletion\n', style: heading),
                  const TextSpan(
                    text: 'Delete your account from Settings → Delete Account. This permanently '
                        'removes your coach profile, client relationships, and chat history.\n\n',
                  ),
                  TextSpan(text: 'Contact\n', style: heading),
                  const TextSpan(
                    text: 'For privacy questions email sujinksureshofcl@gmail.com.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
