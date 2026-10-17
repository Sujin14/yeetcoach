import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                  TextSpan(text: 'Not professional advice\n', style: heading),
                  const TextSpan(
                    text: 'YeetCoach is a coaching management platform. Fitness, health, and '
                        'nutrition guidance you provide to clients is your professional '
                        'responsibility. YeetCoach provides no medical or dietary advice.\n\n',
                  ),
                  TextSpan(text: 'Account\n', style: heading),
                  const TextSpan(
                    text: 'You are responsible for keeping your login credentials secure and for '
                        'all activity under your account.\n\n',
                  ),
                  TextSpan(text: 'Acceptable use\n', style: heading),
                  const TextSpan(
                    text: 'You agree not to use YeetCoach to harass clients, share inappropriate '
                        'content, or violate applicable laws.\n\n',
                  ),
                  TextSpan(text: 'Intellectual property\n', style: heading),
                  const TextSpan(
                    text: 'The YeetCoach app and its design are owned by the developer. Your '
                        'coaching content remains yours.\n\n',
                  ),
                  TextSpan(text: 'Limitation of liability\n', style: heading),
                  const TextSpan(
                    text: 'YeetCoach is provided as-is. The developer is not liable for any '
                        'indirect or consequential damages.\n\n',
                  ),
                  TextSpan(text: 'Contact\n', style: heading),
                  const TextSpan(text: 'sujinksureshofcl@gmail.com'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
