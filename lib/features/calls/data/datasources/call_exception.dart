/// A call failure with a message that is safe to show the coach.
class CallException implements Exception {
  final String message;

  const CallException(this.message);

  @override
  String toString() => 'CallException: $message';
}
