import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/widgets/person_avatar.dart';
import 'package:yeetcoach/core/widgets/shimmer_base.dart';
import 'package:yeetcoach/features/clients/domain/entities/client_profile.dart';
import 'package:yeetcoach/features/home/presentation/controllers/coach_dashboard_controller.dart';
import 'package:yeetcoach/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/challenge_type.dart';
import '../controllers/challenges_controller.dart';
import 'challenge_format.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Pops with `true` once the challenge is saved.
class CreateChallengeSheet extends StatefulWidget {
  const CreateChallengeSheet({super.key});

  static Future<bool> show() async {
    final created = await Get.bottomSheet<bool>(
      const CreateChallengeSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
    return created ?? false;
  }

  @override
  State<CreateChallengeSheet> createState() => _CreateChallengeSheetState();
}

class _CreateChallengeSheetState extends State<CreateChallengeSheet> {
  final _formKey = GlobalKey<FormState>();
  final ChallengesController _controller = Get.find<ChallengesController>();
  final CoachDashboardController _dashboard = Get.find<CoachDashboardController>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  late final _target = TextEditingController(text: '${_type.defaultTarget}');

  ChallengeType _type = ChallengeType.firstAvailable;
  int _durationDays = challengeDurations.first;
  late DateTime _startDay = _today;
  final Set<String> _assigned = {};

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _target.dispose();
    super.dispose();
  }

  void _selectType(ChallengeType type) {
    if (!type.isAvailable) return;
    setState(() {
      _type = type;
      _target.text = '${type.defaultTarget}';
    });
  }

  String? _validateTarget(String? value) {
    final target = int.tryParse(value?.trim() ?? '');
    if (target == null || target <= 0) return 'Enter a target greater than 0';
    if (target > _type.maxTarget) {
      return 'Keep it at or below ${NumberFormat.decimalPattern().format(_type.maxTarget)} ${_type.unit}';
    }
    return null;
  }

  Future<void> _pickStartDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDay,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Challenge start date',
    );
    if (picked != null) setState(() => _startDay = picked);
  }

  Future<void> _create() async {
    if (!_type.isAvailable) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Drops clients who stopped training with this coach while the sheet was open.
    final activeUids = _dashboard.activeClients.map((client) => client.uid).toSet();
    final created = await _controller.createChallenge(NewChallenge(
      title: _title.text.trim(),
      description: _description.text.trim(),
      type: _type,
      targetValue: int.parse(_target.text.trim()),
      durationDays: _durationDays,
      // Today if the sheet stayed open past midnight.
      startDay: _startDay.isBefore(_today) ? _today : _startDay,
      assignedTo: _assigned.where(activeUids.contains).toList(),
    ));
    if (created && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final endDay = DateTime(_startDay.year, _startDay.month, _startDay.day + _durationDays);
    return SettingsSheet(
      title: 'New Challenge',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsTextField(
              controller: _title,
              label: 'Title',
              hint: 'e.g. 10K Steps Week',
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                final title = value?.trim() ?? '';
                if (title.isEmpty) return 'Enter a title';
                if (title.length < 3) return 'Title is too short';
                return null;
              },
            ),
            SettingsTextField(
              controller: _description,
              label: 'Description (optional)',
              hint: 'What participants should do and why',
              minLines: 2,
              maxLines: 4,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
            ),
            const _FieldLabel('Challenge type'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final type in ChallengeType.values)
                  _SelectChip(
                    label: type.isAvailable ? type.label : '${type.label} (coming soon)',
                    icon: challengeTypeIcon(type),
                    selected: type == _type,
                    onTap: type.isAvailable ? () => _selectType(type) : null,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SettingsTextField(
              controller: _target,
              label: 'Target (${_type.unit}${_type.period})',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: _validateTarget,
            ),
            const _FieldLabel('Duration'),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final days in challengeDurations)
                  _SelectChip(
                    label: '$days days',
                    selected: days == _durationDays,
                    onTap: () => setState(() => _durationDays = days),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const _FieldLabel('Start date'),
            _StartDateField(
              startDay: _startDay,
              endDay: endDay,
              onTap: _pickStartDate,
            ),
            const SizedBox(height: AppSpacing.md),
            _ClientPicker(
              dashboard: _dashboard,
              selected: _assigned,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 20),
            Obx(() => _CreateButton(
                  isBusy: _controller.isCreating.value,
                  onPressed: _type.isAvailable ? _create : null,
                )),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: _textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

/// Disabled (greyed out, not tappable) when [onTap] is null.
class _SelectChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  const _SelectChip({required this.label, this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final foreground = !enabled
        ? AppColors.subtle
        : selected
            ? AppColors.onPrimary
            : AppColors.onSurface;
    return ChoiceChip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 16, color: foreground),
      selected: selected,
      onSelected: enabled ? (_) => onTap!() : null,
      disabledColor: AppColors.background,
      showCheckmark: false,
      labelStyle: _textTheme.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}

class _StartDateField extends StatelessWidget {
  final DateTime startDay;
  final DateTime endDay;
  final VoidCallback onTap;

  const _StartDateField({required this.startDay, required this.endDay, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                formatChallengeDate(startDay),
                style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.onSurface),
              ),
            ),
            Text(
              'Ends ${formatChallengeDate(endDay)}',
              style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Optional: challenges are visible to every YeetFit user; assigning highlights them to your clients.
class _ClientPicker extends StatelessWidget {
  final CoachDashboardController dashboard;
  final Set<String> selected;
  final VoidCallback onChanged;

  const _ClientPicker({required this.dashboard, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final clients = dashboard.activeClients.toList();
      final allSelected =
          clients.isNotEmpty && clients.every((client) => selected.contains(client.uid));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: _FieldLabel('Assign to clients (optional)')),
              if (clients.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: TextButton(
                    onPressed: () {
                      allSelected
                          ? selected.clear()
                          : selected.addAll(clients.map((client) => client.uid));
                      onChanged();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(allSelected ? 'Clear all' : 'Select all'),
                  ),
                ),
            ],
          ),
          if (dashboard.isLoadingClients.value)
            const _ClientOptionsShimmer()
          else if (clients.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                'No active clients',
                textAlign: TextAlign.center,
                style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
              ),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < clients.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppColors.divider),
                    _ClientOption(
                      client: clients[i],
                      selected: selected.contains(clients[i].uid),
                      onChanged: (checked) {
                        checked ? selected.add(clients[i].uid) : selected.remove(clients[i].uid);
                        onChanged();
                      },
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            'Every YeetFit user can see and join this challenge.',
            style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
          ),
        ],
      );
    });
  }
}

class _ClientOption extends StatelessWidget {
  final ClientProfile client;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _ClientOption({required this.client, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final name = client.name.trim().isEmpty ? 'Client' : client.name.trim();
    return CheckboxListTile(
      value: selected,
      onChanged: (value) => onChanged(value ?? false),
      activeColor: AppColors.primary,
      checkColor: AppColors.onPrimary,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd),
      secondary: PersonAvatar(name: name, photoUrl: client.profileImageUrl ?? '', size: 36),
      title: Text(
        name,
        style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.onSurface),
      ),
    );
  }
}

/// Mirrors the bordered client list: avatar, name line and checkbox per row.
class _ClientOptionsShimmer extends StatelessWidget {
  static const _rowCount = 3;

  const _ClientOptionsShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: ShimmerBase(
        child: Column(
          children: [
            for (var i = 0; i < _rowCount; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.divider),
              const SizedBox(
                height: 48,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.smd),
                  child: Row(
                    children: [
                      ShimmerCircle(size: 36),
                      SizedBox(width: AppSpacing.md),
                      ShimmerBox(width: 140, height: 14, radius: 6),
                      Spacer(),
                      ShimmerBox(width: 18, height: 18, radius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback? onPressed;

  const _CreateButton({required this.isBusy, required this.onPressed});

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
                'Create Challenge',
                style: _textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
