import 'package:flutter/material.dart';
import '../controllers/call_controller.dart';
import 'call_duration_timer.dart';

/// "Calling…", "Connecting…", the running duration, or the final status.
class CallStatusText extends StatelessWidget {
  final CallPhase phase;
  final DateTime? connectedAt;
  final String? finishedMessage;
  final TextStyle? style;

  const CallStatusText({
    super.key,
    required this.phase,
    required this.connectedAt,
    required this.finishedMessage,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final startedAt = connectedAt;
    if (phase == CallPhase.connected && startedAt != null) {
      return CallDurationTimer(startedAt: startedAt, style: style);
    }
    final text = switch (phase) {
      CallPhase.incoming => 'Incoming call',
      CallPhase.ringing => 'Calling…',
      CallPhase.connecting || CallPhase.connected => 'Connecting…',
      CallPhase.reconnecting => 'Reconnecting…',
      CallPhase.finished => finishedMessage ?? 'Call ended',
    };
    return Text(text, style: style);
  }
}
