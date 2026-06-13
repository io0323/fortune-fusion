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
}
