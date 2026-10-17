import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import '../../domain/entities/diet_plan.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

String _formatNumber(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);

class FoodItemCard extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onDelete;

  const FoodItemCard({super.key, required this.food, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    overflow: TextOverflow.ellipsis,
                    style: _textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '${_formatNumber(food.quantity)} ${food.unit} · ${food.calories} kcal',
                    style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
                  ),
                  if (food.protein > 0 || food.carbs > 0 || food.fats > 0)
                    Text(
                      'P ${_formatNumber(food.protein)}g · C ${_formatNumber(food.carbs)}g · F ${_formatNumber(food.fats)}g',
                      style: _textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.subtle),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              tooltip: 'Remove food',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
