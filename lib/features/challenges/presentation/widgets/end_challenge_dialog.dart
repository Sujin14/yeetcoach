import 'package:flutter/material.dart';
import 'package:yeetcoach/core/widgets/confirmation_dialog.dart';
import '../../domain/entities/challenge.dart';

Future<bool> confirmEndChallenge(BuildContext context, Challenge challenge) {
  return showConfirmDialog(
    context,
    title: 'End challenge?',
    message: '"${challenge.title}" will end now and disappear from the YeetFit challenge list. '
        'Participants keep the progress they have made. This cannot be undone.',
    confirmLabel: 'End Challenge',
  );
}
