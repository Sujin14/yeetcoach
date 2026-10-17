import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/form_validators.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/workout_plan.dart';
import '../controllers/workout_plan_controller.dart';
import '../screens/youtube_preview_screen.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

const _sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
);

Future<void> showExerciseSheet(
  BuildContext context,
  WorkoutPlanController ctrl, {
  required int dayIndex,
  int? exIndex,
  ExerciseEntry? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: _sheetShape,
    builder: (_) => ExerciseSheet(
      existing: existing,
      onSave: (entry) => exIndex == null
          ? ctrl.addExercise(dayIndex, entry)
          : ctrl.updateExercise(dayIndex, exIndex, entry),
    ),
  );
}

String? _validatePositiveInt(String? value, String label) {
  final number = int.tryParse(value?.trim() ?? '');
  return (number == null || number <= 0) ? 'Enter $label.' : null;
}

/// Owns its TextEditingControllers so they are disposed after the sheet's closing animation.
class ExerciseSheet extends StatefulWidget {
  final ExerciseEntry? existing;
  final ValueChanged<ExerciseEntry> onSave;

  const ExerciseSheet({super.key, this.existing, required this.onSave});

  @override
  State<ExerciseSheet> createState() => _ExerciseSheetState();
}

class _ExerciseSheetState extends State<ExerciseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sets;
  late final TextEditingController _reps;
  late final TextEditingController _duration;
  late final TextEditingController _rest;
  late final TextEditingController _notes;
  late final TextEditingController _youtube;
  late bool _useReps;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _sets = TextEditingController(text: '${existing?.sets ?? 3}');
    _reps = TextEditingController(text: existing?.reps?.toString() ?? '');
    _duration = TextEditingController(text: existing?.durationMinutes?.toString() ?? '');
    _rest = TextEditingController(text: '${existing?.restSeconds ?? 60}');
    _notes = TextEditingController(text: existing?.notes ?? '');
    _youtube = TextEditingController(text: existing?.youtubeUrl ?? '')..addListener(_onYouTubeChanged);
    _useReps = existing == null || existing.reps != null || existing.durationMinutes == null;
  }

  @override
  void dispose() {
    _youtube.removeListener(_onYouTubeChanged);
    for (final controller in [_name, _sets, _reps, _duration, _rest, _notes, _youtube]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onYouTubeChanged() => setState(() {});

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSave(ExerciseEntry(
      name: _name.text.trim(),
      sets: int.parse(_sets.text.trim()),
      reps: _useReps ? int.parse(_reps.text.trim()) : null,
      durationMinutes: _useReps ? null : int.parse(_duration.text.trim()),
      restSeconds: int.tryParse(_rest.text.trim()) ?? 0,
      notes: _notes.text.trim(),
      youtubeUrl: _youtube.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final youtubeUrl = _youtube.text.trim();
    final youtubeValid = youtubeUrl.isNotEmpty && FormValidators.validateYouTubeUrl(youtubeUrl) == null;
    final videoId = youtubeValid ? (YoutubePlayerController.convertUrlToId(youtubeUrl) ?? '') : '';

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
                  widget.existing == null ? 'Add Exercise' : 'Edit Exercise',
                  style: _textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _name,
                  autofocus: widget.existing == null,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Exercise name *'),
                  validator: (value) => FormValidators.validateName(value?.trim(), 'exercise'),
                ),
                const SizedBox(height: AppSpacing.smd),
                TextFormField(
                  controller: _sets,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sets *'),
                  validator: (value) => _validatePositiveInt(value, 'the number of sets'),
                ),
                const SizedBox(height: AppSpacing.xs),
                RadioGroup<bool>(
                  groupValue: _useReps,
                  onChanged: (value) => setState(() => _useReps = value ?? true),
                  child: const Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          value: true,
                          title: Text('Reps'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          value: false,
                          title: Text('Duration (min)'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_useReps)
                  TextFormField(
                    key: const ValueKey('reps'),
                    controller: _reps,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps *'),
                    validator: (value) => _validatePositiveInt(value, 'reps'),
                  )
                else
                  TextFormField(
                    key: const ValueKey('duration'),
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duration (min) *'),
                    validator: (value) => _validatePositiveInt(value, 'the duration'),
                  ),
                const SizedBox(height: AppSpacing.smd),
                TextFormField(
                  controller: _rest,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Rest (seconds)'),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final number = int.tryParse(text);
                    return (number == null || number < 0) ? 'Enter valid seconds.' : null;
                  },
                ),
                const SizedBox(height: AppSpacing.smd),
                TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Notes (optional)', alignLabelWithHint: true),
                ),
                const SizedBox(height: AppSpacing.smd),
                TextFormField(
                  controller: _youtube,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'YouTube URL (optional)',
                  ),
                  validator: (value) => FormValidators.validateYouTubeUrl(value?.trim()),
                ),
                if (youtubeValid && videoId.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => Get.to(() => YoutubePreviewScreen(url: youtubeUrl)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 180,
                              color: AppColors.subtle.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.videocam_off_outlined,
                                color: AppColors.subtle,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Tap to preview',
                                style: TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(widget.existing == null ? 'Add Exercise' : 'Save Exercise'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
