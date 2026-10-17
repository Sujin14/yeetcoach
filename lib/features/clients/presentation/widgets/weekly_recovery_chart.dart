import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/recovery_day.dart';
import '../controllers/client_detail_controller.dart';
import 'client_detail_section_shimmers.dart';
import 'client_section.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

Color _barColor(int? score) => switch (score) {
      null => AppColors.statusNone,
      >= 60 => AppColors.statusGood,
      >= 40 => AppColors.statusFair,
      _ => AppColors.statusPoor,
    };

class WeeklyRecoveryChart extends GetView<ClientDetailController> {
  const WeeklyRecoveryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSectionLoading(ClientDetailSection.recovery)) {
        return const WeeklyRecoveryShimmer();
      }
      final days = controller.weeklyRecovery;
      if (days.every((day) => day.score == null)) {
        return ClientCard(
          child: Row(
            children: [
              const Icon(Icons.insights_outlined, color: AppColors.statusNone, size: 22),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Text(
                  'Recovery data will appear here as the client logs their health',
                  style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
                ),
              ),
            ],
          ),
        );
      }
      return ClientCard(
        padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 20, AppSpacing.md, AppSpacing.sm),
        child: SizedBox(height: 180, child: _RecoveryBarChart(days: days)),
      );
    });
  }
}

class _RecoveryBarChart extends StatelessWidget {
  final List<RecoveryDay> days;

  const _RecoveryBarChart({required this.days});

  @override
  Widget build(BuildContext context) {
    final axisStyle = _textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.subtle);
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 32,
              getTitlesWidget: (value, _) => Text('${value.toInt()}', style: axisStyle),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat.E().format(days[index].date), style: axisStyle),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (days[i].score ?? 0).toDouble(),
                  color: _barColor(days[i].score),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: AppColors.statusNone.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
