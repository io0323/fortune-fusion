class DirectionResult {
  const DirectionResult({
    required this.profileId,
    required this.targetDate,
    required this.luckyDirections,
    required this.unluckyDirections,
    required this.description,
  });

  final int profileId;
  final DateTime targetDate;
  final List<String> luckyDirections;
  final List<String> unluckyDirections;
  final String description;

  DirectionResult copyWith({
    int? profileId,
    DateTime? targetDate,
    List<String>? luckyDirections,
    List<String>? unluckyDirections,
    String? description,
  }) {
    return DirectionResult(
      profileId: profileId ?? this.profileId,
      targetDate: targetDate ?? this.targetDate,
      luckyDirections: luckyDirections ?? this.luckyDirections,
      unluckyDirections: unluckyDirections ?? this.unluckyDirections,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DirectionResult &&
      profileId == other.profileId &&
      targetDate == other.targetDate &&
      _listEq(luckyDirections, other.luckyDirections) &&
      _listEq(unluckyDirections, other.unluckyDirections) &&
      description == other.description;

  @override
  int get hashCode => Object.hash(
        profileId,
        targetDate,
        Object.hashAll(luckyDirections),
        Object.hashAll(unluckyDirections),
        description,
      );

  static bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
