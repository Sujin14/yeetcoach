import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// 0–100 score as a teal arc over a grey track, on a white disc so it reads on the hero gradient.
class RecoveryRing extends StatelessWidget {
  final int? score;
  final double size;

  const RecoveryRing({super.key, required this.score, this.size = 120});

  @override
  Widget build(BuildContext context) {
    final score = this.score;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        painter: _RingPainter(progress: (score ?? 0) / 100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score == null ? '—' : '$score%',
                style: _textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: score == null ? AppColors.statusNone : AppColors.onSurface,
                ),
              ),
              Text(
                'Recovery',
                style: _textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.subtle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  static const _strokeWidth = 10.0;

  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(_strokeWidth / 2);
    final track = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    final clamped = progress.clamp(0.0, 1.0);
    if (clamped == 0) return;
    final fill = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _strokeWidth;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * clamped, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}
