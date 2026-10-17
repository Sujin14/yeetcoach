/// Stored as `.name` in calls/{callId}.type.
enum CallType {
  audio,
  video;

  bool get isVideo => this == CallType.video;
}
