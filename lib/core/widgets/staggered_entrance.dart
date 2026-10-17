import 'dart:async';

import 'package:flutter/material.dart';

/// Fades [child] in while sliding it up into place, once, when it first mounts.
/// Items with a higher [index] start later so a list of cards cascades.
class StaggeredEntrance extends StatefulWidget {
  static const stepDelay = Duration(milliseconds: 80);
  static const duration = Duration(milliseconds: 300);

  final int index;
  final Widget child;

  const StaggeredEntrance({super.key, required this.index, required this.child});

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: StaggeredEntrance.duration);
  late final Animation<double> _progress =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<Offset> _offset =
      Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(_progress);
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    if (WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _controller.value = 1;
      return;
    }
    _startTimer = Timer(StaggeredEntrance.stepDelay * widget.index, _controller.forward);
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _progress,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
