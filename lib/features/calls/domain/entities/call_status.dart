/// Stored as `.name` in calls/{callId}.status; the values allowed by firestore.rules.
enum CallStatus {
  ringing,
  active,
  ended,
  missed,
  declined;

  bool get isFinished => this == ended || this == missed || this == declined;
}
