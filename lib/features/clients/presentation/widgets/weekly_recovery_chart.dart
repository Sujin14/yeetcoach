import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/utils/weekday_label.dart';
import 'package:yeetcoach/features/home/domain/entities/recovery_level.dart';
import '../../domain/entities/recovery_day.dart';
import '../controllers/client_detail_controller.dart';
import 'client_detail_section_shimmers.dart';
import 'client_section.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

Color _levelColor(RecoveryLevel? level) => switch (level) {
      RecoveryLevel.excellent || RecoveryLevel.good => AppColors.statusGood,
      RecoveryLevel.fair => AppColors.statusFair,
      RecoveryLevel.needsRest => AppColors.statusPoor,
      null => AppColors.statusNone,
    };

class WeeklyRecoveryChart extends GetView<ClientDetailController> {
  const WeeklyRecoveryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.recoveryRangeLoading.value) {
        return const WeeklyRecoveryShimmer();
      }

      final mode = controller.chartMode.value;
      final (start, end) = controller.chartPeriod;
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final days = _daysInRange(start, end);
      final elapsedDays = days.where((day) => !day.isAfter(today)).length;
      final logged = days
          .where((day) => !day.isAfter(today) && controller.recoveryFor(day)?.score != null)
          .toList();
      final avg = logged.isEmpty
          ? null
          : (logged.map((day) => controller.recoveryFor(day)!.score!).reduce((a, b) => a + b) /
                  logged.length)
              .round();

      return ClientCard(
        padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ChartHeader(controller: controller),
            const SizedBox(height: AppSpacing.smd),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -200) {
                  controller.nextPeriod();
                } else if (velocity > 200) {
                  controller.previousPeriod();
                }
              },
              child: SizedBox(
                height: mode == RecoveryChartMode.week ? 180 : 220,
                child: logged.isEmpty && controller.recoveryRange.isEmpty
                    ? _EmptyPeriod(
                        message: mode == RecoveryChartMode.week
                            ? 'No recovery logged this week'
                            : 'No recovery logged this month',
                      )
                    : mode == RecoveryChartMode.week
                        ? _WeekBars(controller: controller, start: start)
                        : _MonthGrid(controller: controller, start: start, end: end, today: today),
              ),
            ),
            if (logged.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                avg == null
                    ? '${logged.length} of $elapsedDays days logged'
                    : 'Avg $avg · ${logged.length} of $elapsedDays days logged',
                textAlign: TextAlign.center,
                style: _textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.subtle),
              ),
            ],
          ],
        ),
      );
    });
  }

  static List<DateTime> _daysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (var day = start; !day.isAfter(end); day = day.add(const Duration(days: 1))) {
      days.add(day);
    }
    return days;
  }
}

class _ChartHeader extends StatelessWidget {
  final ClientDetailController controller;

  const _ChartHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedButton<RecoveryChartMode>(
          segments: const [
            ButtonSegment(value: RecoveryChartMode.week, label: Text('Week')),
            ButtonSegment(value: RecoveryChartMode.month, label: Text('Month')),
          ],
          selected: {controller.chartMode.value},
          onSelectionChanged: (selected) => controller.setChartMode(selected.first),
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.onPrimary
                  : AppColors.onSurface,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? AppColors.primary : AppColors.surface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            IconButton(
              tooltip: 'Previous',
              onPressed: controller.previousPeriod,
              icon: const Icon(Icons.chevron_left, color: AppColors.onSurface),
            ),
            Expanded(
              child: Text(
                controller.chartPeriodLabel,
                textAlign: TextAlign.center,
                style: _textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next',
              onPressed: controller.canGoNext ? controller.nextPeriod : null,
              icon: Icon(
                Icons.chevron_right,
                color: controller.canGoNext ? AppColors.onSurface : AppColors.statusNone,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyPeriod extends StatelessWidget {
  final String message;

  const _EmptyPeriod({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
      ),
    );
  }
}

class _WeekBars extends StatelessWidget {
  final ClientDetailController controller;
  final DateTime start;

  const _WeekBars({
    required this.controller,
    required this.start,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    final axisStyle = _textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.subtle);

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions) return;
            final index = response?.spot?.touchedBarGroupIndex;
            if (index == null || index < 0 || index >= days.length) return;
            final day = days[index];
            if (controller.recoveryFor(day)?.score == null) return;
            _showDayInfo(context, controller, day);
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 0,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
          ),
        ),
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
                if (index < 0 || index >= shortWeekdayLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(shortWeekdayLabels[index], style: axisStyle),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [_rodFor(days[i])],
            ),
        ],
      ),
    );
  }

  BarChartRodData _rodFor(DateTime day) {
    final entry = controller.recoveryFor(day);
    final score = entry?.score;
    final color = score == null
        ? Colors.transparent
        : _levelColor(entry?.level ?? RecoveryLevel.tryParse(score));
    const radius = BorderRadius.vertical(top: Radius.circular(6));

    return BarChartRodData(
      toY: (score ?? 0).toDouble(),
      color: color,
      width: 18,
      borderRadius: radius,
      backDrawRodData: BackgroundBarChartRodData(
        show: true,
        toY: 100,
        color: AppColors.statusNone.withValues(alpha: 0.25),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final ClientDetailController controller;
  final DateTime start;
  final DateTime end;
  final DateTime today;

  const _MonthGrid({
    required this.controller,
    required this.start,
    required this.end,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final leadingBlanks = start.weekday - DateTime.monday;
    final dayCount = end.day;
    final cells = <Widget>[
      for (final label in shortWeekdayLabels)
        Center(
          child: Text(
            label,
            style: _textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.subtle),
          ),
        ),
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= dayCount; day++)
        _MonthDayCell(
          date: DateTime(start.year, start.month, day),
          today: today,
          entry: controller.recoveryFor(DateTime(start.year, start.month, day)),
          onTap: () => _showDayInfo(context, controller, DateTime(start.year, start.month, day)),
        ),
    ];

    return GridView.count(
      crossAxisCount: 7,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  final DateTime date;
  final DateTime today;
  final RecoveryDay? entry;
  final VoidCallback onTap;

  const _MonthDayCell({
    required this.date,
    required this.today,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final future = date.isAfter(today);
    final isToday = date == today;
    final score = entry?.score;
    final level = entry?.level ?? (score == null ? null : RecoveryLevel.tryParse(score));
    final fill = future
        ? AppColors.statusNone.withValues(alpha: 0.08)
        : score == null
            ? AppColors.divider.withValues(alpha: 0.5)
            : _levelColor(level).withValues(alpha: 0.35);

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isToday
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            '${date.day}',
            style: _textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: future ? AppColors.subtle.withValues(alpha: 0.5) : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

void _showDayInfo(BuildContext context, ClientDetailController controller, DateTime day) {
  final entry = controller.recoveryFor(day);
  final label = DateFormat('EEE d MMM').format(day);
  final levelLabel = entry?.level?.label ??
      (entry?.score == null ? null : RecoveryLevel.tryParse(entry!.score)?.label);
  final text = entry?.score == null
      ? '$label · No recovery logged'
      : '$label · ${entry!.score}${levelLabel == null ? '' : ' · $levelLabel'}';
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
