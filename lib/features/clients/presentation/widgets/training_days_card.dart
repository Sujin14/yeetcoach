import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/widgets/section_header.dart';
import '../controllers/client_detail_controller.dart';

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Weekday chips for clients/{uid}.trainingDays. A tap saves immediately.
class TrainingDaysCard extends StatefulWidget {
  final List<int> trainingDays;

  const TrainingDaysCard({super.key, required this.trainingDays});

  @override
  State<TrainingDaysCard> createState() => _TrainingDaysCardState();
}

class _TrainingDaysCardState extends State<TrainingDaysCard> {
  late List<int> _days;

  @override
  void initState() {
    super.initState();
    _days = List<int>.from(widget.trainingDays);
  }

  @override
  void didUpdateWidget(TrainingDaysCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.trainingDays, widget.trainingDays)) {
      _days = List<int>.from(widget.trainingDays);
    }
  }

  void _toggle(int day) {
    final next = List<int>.from(_days);
    if (next.contains(day)) {
      next.remove(day);
    } else {
      next.add(day);
    }
    next.sort();
    setState(() => _days = next);
    Get.find<ClientDetailController>().updateTrainingDays(next);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Training Days'),
            const SizedBox(height: AppSpacing.smd),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var index = 0; index < _dayLabels.length; index++)
                  _DayChip(
                    label: _dayLabels[index],
                    selected: _days.contains(index + 1),
                    onSelected: () => _toggle(index + 1),
                  ),
              ],
            ),
            if (_days.isEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text(
                "Tap days to set this client's training schedule",
                style: TextStyle(fontSize: 13, color: AppColors.subtle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _DayChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary,
      side: selected ? BorderSide.none : const BorderSide(color: AppColors.divider),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
