class CompatibilityResult {
  const CompatibilityResult({
    required this.loveScore,
    required this.workScore,
    required this.friendScore,
    required this.loveStars,
    required this.workStars,
    required this.friendStars,
    required this.loveComment,
    required this.workComment,
    required this.friendComment,
    required this.isPartnerTimeUncertain,
    required this.shichuScore,
    required this.seizaScore,
    required this.kyuseiScore,
  });

  final int loveScore;
  final int workScore;
  final int friendScore;
  final int loveStars;
  final int workStars;
  final int friendStars;
  final String loveComment;
  final String workComment;
  final String friendComment;
  final bool isPartnerTimeUncertain;
  final int shichuScore;
  final int seizaScore;
  final int kyuseiScore;

  CompatibilityResult copyWith({
    int? loveScore,
    int? workScore,
    int? friendScore,
    int? loveStars,
    int? workStars,
    int? friendStars,
    String? loveComment,
    String? workComment,
    String? friendComment,
    bool? isPartnerTimeUncertain,
    int? shichuScore,
    int? seizaScore,
    int? kyuseiScore,
  }) {
    return CompatibilityResult(
      loveScore: loveScore ?? this.loveScore,
      workScore: workScore ?? this.workScore,
      friendScore: friendScore ?? this.friendScore,
      loveStars: loveStars ?? this.loveStars,
      workStars: workStars ?? this.workStars,
      friendStars: friendStars ?? this.friendStars,
      loveComment: loveComment ?? this.loveComment,
      workComment: workComment ?? this.workComment,
      friendComment: friendComment ?? this.friendComment,
      isPartnerTimeUncertain:
          isPartnerTimeUncertain ?? this.isPartnerTimeUncertain,
      shichuScore: shichuScore ?? this.shichuScore,
      seizaScore: seizaScore ?? this.seizaScore,
      kyuseiScore: kyuseiScore ?? this.kyuseiScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CompatibilityResult &&
      loveScore == other.loveScore &&
      workScore == other.workScore &&
      friendScore == other.friendScore &&
      loveStars == other.loveStars &&
      workStars == other.workStars &&
      friendStars == other.friendStars &&
      loveComment == other.loveComment &&
      workComment == other.workComment &&
      friendComment == other.friendComment &&
      isPartnerTimeUncertain == other.isPartnerTimeUncertain &&
      shichuScore == other.shichuScore &&
      seizaScore == other.seizaScore &&
      kyuseiScore == other.kyuseiScore;

  @override
  int get hashCode => Object.hash(
        loveScore,
        workScore,
        friendScore,
        loveStars,
        workStars,
        friendStars,
        loveComment,
        workComment,
        friendComment,
        isPartnerTimeUncertain,
        shichuScore,
        seizaScore,
        kyuseiScore,
      );
}
