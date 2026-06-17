class IntegratedReading {
  const IntegratedReading({
    required this.profileId,
    required this.generatedAt,
    required this.personality,
    required this.aptitude,
    required this.love,
    required this.money,
    required this.health,
  });

  final int profileId;
  final DateTime generatedAt;
  final List<String> personality;
  final List<String> aptitude;
  final List<String> love;
  final List<String> money;
  final List<String> health;

  IntegratedReading copyWith({
    int? profileId,
    DateTime? generatedAt,
    List<String>? personality,
    List<String>? aptitude,
    List<String>? love,
    List<String>? money,
    List<String>? health,
  }) {
    return IntegratedReading(
      profileId: profileId ?? this.profileId,
      generatedAt: generatedAt ?? this.generatedAt,
      personality: personality ?? this.personality,
      aptitude: aptitude ?? this.aptitude,
      love: love ?? this.love,
      money: money ?? this.money,
      health: health ?? this.health,
    );
  }
}
