/// Whether a free-text day label written by a coach ("Monday", "Mon / Thu",
/// "Day 1 - Tuesday") refers to [weekday] (DateTime.monday … DateTime.sunday).
bool labelMentionsWeekday(String label, int weekday) {
  final pattern = _weekdayPatterns[weekday];
  return pattern != null && pattern.hasMatch(label);
}

final Map<int, RegExp> _weekdayPatterns = {
  DateTime.monday: _pattern('mon(day)?'),
  DateTime.tuesday: _pattern('tue(s|sday)?'),
  DateTime.wednesday: _pattern('wed(nesday)?'),
  DateTime.thursday: _pattern('thu(r|rs|rsday)?'),
  DateTime.friday: _pattern('fri(day)?'),
  DateTime.saturday: _pattern('sat(urday)?'),
  DateTime.sunday: _pattern('sun(day)?'),
};

RegExp _pattern(String day) => RegExp('\\b$day\\b', caseSensitive: false);
