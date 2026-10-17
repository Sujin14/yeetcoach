import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Pops with Navigator rather than Get.back, which closes an open snackbar instead of the route.
Future<void> saveAndClose(BuildContext context, Future<bool> Function() save) async {
  FocusScope.of(context).unfocus();
  // Let the focus change land first so an in-progress label edit is committed before saving.
  await Future<void>(() {});
  final saved = await save();
  if (saved && context.mounted) Navigator.of(context).pop(true);
}

class FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSave;
  final RxBool isSaving;

  const FormAppBar({super.key, required this.title, required this.onSave, required this.isSaving});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.onSurface),
        tooltip: 'Close',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        title,
        style: _textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      actions: [
        Obx(() => isSaving.value
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              )
            : TextButton(
                onPressed: onSave,
                child: Text(
                  'Save',
                  style: _textTheme.labelLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              )),
      ],
    );
  }
}
