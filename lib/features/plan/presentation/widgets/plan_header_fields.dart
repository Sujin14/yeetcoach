import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';

class PlanHeaderFields extends StatelessWidget {
  final RxString title;
  final RxString description;

  const PlanHeaderFields({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: title.value,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Plan title *',
            hintText: 'e.g. 4-Week Strength Block',
          ),
          onChanged: (value) => title.value = value,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          initialValue: description.value,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Goals, notes for this plan…',
            alignLabelWithHint: true,
          ),
          onChanged: (value) => description.value = value,
        ),
      ],
    );
  }
}
