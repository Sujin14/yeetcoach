import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import '../controllers/call_setup_controller.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Guides the coach through Android call permissions and a lock-screen test.
class CallSetupScreen extends StatefulWidget {
  const CallSetupScreen({super.key});

  @override
  State<CallSetupScreen> createState() => _CallSetupScreenState();
}

class _CallSetupScreenState extends State<CallSetupScreen> with WidgetsBindingObserver {
  late final CallSetupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CallSetupController>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.refreshReadiness());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Enable incoming calls',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final readiness = _controller.readiness.value;
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
            children: [
              Text(
                "So your clients' calls ring and show on your lock screen, even when YeetCoach is closed.",
                style: _textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.subtle,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_controller.loading.value)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else ...[
                const _SectionLabel('Required'),
                _ReadinessRow(
                  label: 'Notifications',
                  ok: readiness?.notificationsEnabled ?? false,
                  onFix: () => _controller.fix('notifications'),
                ),
                _ReadinessRow(
                  label: 'Call alerts',
                  ok: readiness?.channelOk ?? false,
                  onFix: () => _controller.fix('channel'),
                ),
                _ReadinessRow(
                  label: 'Full-screen call screen',
                  ok: readiness?.fullScreenOk ?? false,
                  onFix: () => _controller.fix('fullScreen'),
                ),
                _ReadinessRow(
                  label: 'Unrestricted battery',
                  ok: readiness?.batteryOk ?? false,
                  onFix: () => _controller.fix('battery'),
                ),
                if (readiness?.needsOemSetup == true) ...[
                  const _SectionLabel('Phone-specific'),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          readiness!.oemInstructions,
                          style: _textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "These settings can't be checked automatically. Use the test call below to confirm.",
                          style: _textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppColors.subtle,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton(
                          onPressed: () => _controller.fix('oem'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Open phone settings'),
                        ),
                      ],
                    ),
                  ),
                ],
                const _SectionLabel('Test'),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Tap Test call, then lock your phone. In 10 seconds a test call should ring and appear on your lock screen.',
                        style: _textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (_controller.testScheduled.value) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Test call coming in 10s — lock your phone now',
                          style: _textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (_controller.testPassed.value) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Test call worked ✓',
                          style: _textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        onPressed: _controller.scheduleTest,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Test call'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _controller.done,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
                TextButton(
                  onPressed: _controller.skip,
                  style: TextButton.styleFrom(foregroundColor: AppColors.subtle),
                  child: const Text('Skip for now'),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.lg, AppSpacing.xs, AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: _textTheme.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.subtle,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  final String label;
  final bool ok;
  final VoidCallback onFix;

  const _ReadinessRow({
    required this.label,
    required this.ok,
    required this.onFix,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              ok ? Icons.check_circle : Icons.warning_amber_rounded,
              color: ok ? AppColors.success : AppColors.secondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: _textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (!ok)
              TextButton(
                onPressed: onFix,
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Text('Fix'),
              ),
          ],
        ),
      ),
    );
  }
}
