class FortuneResult {
  const FortuneResult({
    required this.overall,
    required this.love,
    required this.work,
    required this.money,
    required this.health,
    required this.luckyColor,
    required this.luckyNumber,
    required this.luckyDirection,
    required this.advice,
  });

  final int overall;
  final int love;
  final int work;
  final int money;
  final int health;
  final String luckyColor;
  final int luckyNumber;
  final String luckyDirection;
  final String advice;
}
