import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/diet_plan.dart';
import '../controllers/diet_plan_controller.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

const _sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
);

Future<void> showFoodSheet(BuildContext context, DietPlanController ctrl, int mealIndex) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: _sheetShape,
    builder: (_) => FoodSheet(onSave: (food) => ctrl.addFood(mealIndex, food)),
  );
}

String? _validatePositiveDecimal(String? value, String label) {
  final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
  return (number == null || number <= 0) ? 'Enter $label.' : null;
}

String? _validateOptionalNonNegativeDecimal(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return null;
  final number = double.tryParse(text.replaceAll(',', '.'));
  return (number == null || number < 0) ? 'Enter a valid number.' : null;
}

double? _parseDecimal(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

class FoodSheet extends StatefulWidget {
  final ValueChanged<FoodItem> onSave;

  const FoodSheet({super.key, required this.onSave});

  @override
  State<FoodSheet> createState() => _FoodSheetState();
}

class _FoodSheetState extends State<FoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController();
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fats = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_name, _quantity, _unit, _calories, _protein, _carbs, _fats, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSave(FoodItem(
      name: _name.text.trim(),
      quantity: _parseDecimal(_quantity.text)!,
      unit: _unit.text.trim(),
      calories: int.parse(_calories.text.trim()),
      protein: _parseDecimal(_protein.text) ?? 0,
      carbs: _parseDecimal(_carbs.text) ?? 0,
      fats: _parseDecimal(_fats.text) ?? 0,
      notes: _notes.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const decimalKeyboard = TextInputType.numberWithOptions(decimal: true);

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
                  'Add Food',
                  style: _textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Food name *'),
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter the food name.' : null,
                ),
                const SizedBox(height: AppSpacing.smd),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantity,
                        keyboardType: decimalKeyboard,
                        decoration: const InputDecoration(labelText: 'Quantity *'),
                        validator: (value) => _validatePositiveDecimal(value, 'a quantity'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smd),
                    Expanded(
                      child: TextFormField(
                        controller: _unit,
                        decoration: const InputDecoration(labelText: 'Unit *', hintText: 'g, ml, pcs'),
                        validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter a unit.' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.smd),
                TextFormField(
                  controller: _calories,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Calories *'),
                  validator: (value) {
                    final number = int.tryParse(value?.trim() ?? '');
                    return (number == null || number < 0) ? 'Enter calories.' : null;
                  },
                ),
                const SizedBox(height: AppSpacing.smd),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _protein,
                        keyboardType: decimalKeyboard,
                        decoration: const InputDecoration(labelText: 'Protein (g)'),
                        validator: _validateOptionalNonNegativeDecimal,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smd),
                    Expanded(
                      child: TextFormField(
                        controller: _carbs,
                        keyboardType: decimalKeyboard,
                        decoration: const InputDecoration(labelText: 'Carbs (g)'),
                        validator: _validateOptionalNonNegativeDecimal,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smd),
                    Expanded(
                      child: TextFormField(
                        controller: _fats,
                        keyboardType: decimalKeyboard,
                        decoration: const InputDecoration(labelText: 'Fat (g)'),
                        validator: _validateOptionalNonNegativeDecimal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.smd),
                TextFormField(
                  controller: _notes,
                  maxLines: 2,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Notes (optional)', alignLabelWithHint: true),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _save, child: const Text('Add Food')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
