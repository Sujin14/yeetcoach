import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import '../controllers/session_controller.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

class CreateSessionSheet extends StatefulWidget {
  const CreateSessionSheet({super.key});

  @override
  State<CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<CreateSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _meetLink = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _scheduledAt;
  int _durationMinutes = 60;
  String? _dateError;

  @override
  void dispose() {
    _title.dispose();
    _meetLink.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt ?? now),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateError = null;
    });
  }

  String? _validateMeetLink(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a Google Meet link.';
    if (!text.toLowerCase().contains('meet.google.com')) {
      return 'Link must contain meet.google.com.';
    }
    return null;
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final scheduledAt = _scheduledAt;
    String? dateError;
    if (scheduledAt == null) {
      dateError = 'Choose a date and time.';
    } else if (!scheduledAt.isAfter(DateTime.now())) {
      dateError = 'Choose a future date and time.';
    }
    if (dateError != null) setState(() => _dateError = dateError);
    if (!formValid || dateError != null || scheduledAt == null) return;

    final saved = await Get.find<SessionController>().createSession(
      title: _title.text,
      meetLink: _meetLink.text,
      scheduledAt: scheduledAt,
      durationMinutes: _durationMinutes,
      description: _notes.text,
    );
    if (saved && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheduledAt = _scheduledAt;
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Schedule session',
                  style: _textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _title,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: 'Title *', focusedBorder: focusedBorder),
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter a title.' : null,
                ),
                const SizedBox(height: AppSpacing.smd),
                TextFormField(
                  controller: _meetLink,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'Google Meet link *',
                    hintText: 'https://meet.google.com/...',
                    focusedBorder: focusedBorder,
                  ),
                  validator: _validateMeetLink,
                ),
                const SizedBox(height: AppSpacing.smd),
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date & Time *',
                      errorText: _dateError,
                      focusedBorder: focusedBorder,
                    ),
                    child: Text(
                      scheduledAt == null
                          ? 'Select date and time'
                          : DateFormat('EEE, d MMM · h:mm a').format(scheduledAt),
                      style: _textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: scheduledAt == null ? AppColors.subtle : AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.smd),
                Wrap(
                  spacing: 8,
                  children: [30, 45, 60, 90].map((mins) {
                    final selected = _durationMinutes == mins;
                    return ChoiceChip(
                      label: Text('$mins min'),
                      selected: selected,
                      onSelected: (_) => setState(() => _durationMinutes = mins),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.onPrimary : AppColors.onSurface,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.smd),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    alignLabelWithHint: true,
                    focusedBorder: focusedBorder,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final saving = Get.find<SessionController>().isSaving.value;
                  return ElevatedButton(
                    onPressed: saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                          )
                        : const Text('Save'),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
