/// A client's recovery band. Score thresholds match YeetFit's RecoveryLevel.
enum RecoveryLevel {
  excellent(80, 'Excellent'),
  good(60, 'Good'),
  fair(40, 'Fair'),
  needsRest(0, 'Needs Rest');

  const RecoveryLevel(this.minScore, this.label);

  final int minScore;
  final String label;

  /// Accepts a 0–100 score or a level name / label. Returns null when missing or unrecognised.
  static RecoveryLevel? tryParse(Object? value) {
    if (value is num) {
      return values.firstWhere((level) => value >= level.minScore, orElse: () => needsRest);
    }
    if (value is! String) return null;
    final normalised = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    for (final level in values) {
      if (normalised.startsWith(level.name.toLowerCase()) ||
          normalised.startsWith(level.label.toLowerCase().replaceAll(' ', ''))) {
        return level;
      }
    }
    final asNumber = num.tryParse(value.trim());
    return asNumber == null ? null : tryParse(asNumber);
  }
}
