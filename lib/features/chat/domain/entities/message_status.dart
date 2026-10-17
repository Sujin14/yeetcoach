/// Delivery state of a message, stored as its [name]. YeetFit moves incoming
/// messages to [delivered] when they reach the device and to [read] when opened.
enum MessageStatus {
  sent,
  delivered,
  read;

  bool get isUnread => this != read;
}
