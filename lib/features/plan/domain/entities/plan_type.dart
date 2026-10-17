enum PlanType { workout, diet }

extension PlanTypeExtension on PlanType {
  String get value => name; // 'workout' or 'diet'

  static PlanType fromString(String s) => PlanType.values.firstWhere(
        (e) => e.name == s,
        orElse: () => throw ArgumentError('Unknown plan type: $s'),
      );
}
