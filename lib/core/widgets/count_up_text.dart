import 'package:flutter/material.dart';

/// Counts [value] up from 0 the first time it appears. Later value changes
/// show immediately instead of replaying the count.
class CountUpText extends StatefulWidget {
  static const duration = Duration(milliseconds: 600);

  final double value;
  final String Function(double value) format;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: CountUpText.duration);
  late final Animation<double> _progress =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    if (WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tabular figures keep the digits a fixed width so the text doesn't jitter while counting.
    final style = (widget.style ?? const TextStyle())
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, _) => Text(
        widget.format(widget.value * _progress.value),
        style: style,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      ),
    );
  }
}
