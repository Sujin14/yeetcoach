/// Compact relative time: "Just now", "5m ago", "3h ago", "2d ago".
String timeAgo(DateTime dt) {
  final elapsed = DateTime.now().difference(dt);
  // Negative when the device clock is behind the server timestamp.
  if (elapsed.inSeconds < 60) return 'Just now';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
  return '${elapsed.inDays}d ago';
}
