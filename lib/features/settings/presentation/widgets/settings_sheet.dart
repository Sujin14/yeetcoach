import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Bottom sheet frame for settings forms: drag handle, title, 16px padding, 20px top corners.
/// Lifts above the keyboard and scrolls when the content is taller than the screen.
class SettingsSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsSheet({super.key, required this.title, required this.child});

  static Future<void> show(Widget sheet) {
    return Get.bottomSheet<void>(
      sheet,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, AppSpacing.md + media.padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: _textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final bool autofocus;

  const SettingsTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color),
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
      child: TextFormField(
        controller: controller,
        autofocus: autofocus,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        validator: validator,
        style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          labelStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.subtle),
          hintStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.subtle),
          border: border(AppColors.divider),
          enabledBorder: border(AppColors.divider),
          focusedBorder: border(AppColors.primary),
          errorBorder: border(AppColors.error),
          focusedErrorBorder: border(AppColors.error),
        ),
      ),
    );
  }
}

/// Full-width primary button with an inline spinner while [isBusy].
class SheetSaveButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onPressed;

  const SheetSaveButton({super.key, required this.isBusy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: isBusy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: isBusy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
              )
            : Text(
                'Save',
                style: _textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
