import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import 'package:yeetcoach/features/coach/domain/entities/coach_profile.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';
import 'edit_name_sheet.dart';
import 'settings_sheet.dart';
import 'specialization_chips.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class EditProfileSheet extends StatefulWidget {
  final CoachProfile profile;

  const EditProfileSheet({super.key, required this.profile});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final SettingsController _controller = Get.find<SettingsController>();
  late final TextEditingController _name = TextEditingController(text: widget.profile.name);
  late final TextEditingController _bio = TextEditingController(text: widget.profile.bio);
  late final TextEditingController _experience =
      TextEditingController(text: widget.profile.experienceYears?.toString() ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.profile.phoneNumber ?? '');
  late final Set<String> _specializations = {...widget.profile.specializations};

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _experience.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _toggle(String option) {
    setState(() => _specializations.contains(option)
        ? _specializations.remove(option)
        : _specializations.add(option));
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_specializations.isEmpty) {
      showErrorSnackbar('Select at least one specialization.');
      return;
    }
    final saved = await _controller.saveProfile(
      name: _name.text,
      bio: _bio.text,
      specializations: _specializations.toList(),
      experienceYears: int.tryParse(_experience.text.trim()),
      phoneNumber: _phone.text,
    );
    if (saved && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSheet(
      title: 'Edit profile',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsTextField(
              controller: _name,
              label: 'Full name',
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              validator: validateCoachName,
            ),
            SettingsTextField(
              controller: _bio,
              label: 'Bio',
              hint: 'Your coaching style, background and who you help',
              minLines: 3,
              maxLines: 6,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            SettingsTextField(
              controller: _experience,
              label: 'Experience (years)',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
            SettingsTextField(
              controller: _phone,
              label: 'Phone number',
              hint: '+91 98765 43210',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                LengthLimitingTextInputFormatter(20),
              ],
              validator: _validatePhone,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Specializations',
              style: _textTheme.labelLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SpecializationChips(selected: _specializations, onToggle: _toggle),
            const SizedBox(height: 20),
            Obx(() => SheetSaveButton(
                  isBusy: _controller.isSavingProfile.value,
                  onPressed: _save,
                )),
          ],
        ),
      ),
    );
  }

  static String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return digits.length < 7 || digits.length > 15 ? 'Enter a valid phone number' : null;
  }
}
