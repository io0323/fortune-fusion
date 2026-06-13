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
}
