class KyuseiResult {
  const KyuseiResult({
    required this.honmeiStar,
    required this.getsumeyStar,
    required this.keishakyu,
    required this.luckyDirections,
    required this.unluckyDirections,
  });

  final int honmeiStar;
  final int getsumeyStar;
  final int keishakyu;
  final List<String> luckyDirections;
  final List<String> unluckyDirections;
}
