class CompatibilityResult {
  const CompatibilityResult({
    required this.profileAId,
    required this.profileBId,
    required this.score,
    required this.description,
    required this.shichuScore,
    required this.seizaScore,
    required this.kyuseiScore,
  });

  final int profileAId;
  final int profileBId;
  final int score;
  final String description;
  final int shichuScore;
  final int seizaScore;
  final int kyuseiScore;

  CompatibilityResult copyWith({
    int? profileAId,
    int? profileBId,
    int? score,
    String? description,
    int? shichuScore,
    int? seizaScore,
    int? kyuseiScore,
  }) {
    return CompatibilityResult(
      profileAId: profileAId ?? this.profileAId,
      profileBId: profileBId ?? this.profileBId,
      score: score ?? this.score,
      description: description ?? this.description,
      shichuScore: shichuScore ?? this.shichuScore,
      seizaScore: seizaScore ?? this.seizaScore,
      kyuseiScore: kyuseiScore ?? this.kyuseiScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CompatibilityResult &&
      profileAId == other.profileAId &&
      profileBId == other.profileBId &&
      score == other.score &&
      description == other.description &&
      shichuScore == other.shichuScore &&
      seizaScore == other.seizaScore &&
      kyuseiScore == other.kyuseiScore;

  @override
  int get hashCode => Object.hash(
        profileAId,
        profileBId,
        score,
        description,
        shichuScore,
        seizaScore,
        kyuseiScore,
      );
}
