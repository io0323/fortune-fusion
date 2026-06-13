import 'fortune_result.dart';

class IntegratedReading {
  const IntegratedReading({
    required this.profileId,
    required this.generatedAt,
    required this.shichu,
    required this.seiza,
    required this.kyusei,
    required this.integrated,
    required this.personalityDescription,
    required this.careerDescription,
  });

  final int profileId;
  final DateTime generatedAt;
  final FortuneResult shichu;
  final FortuneResult seiza;
  final FortuneResult kyusei;
  final FortuneResult integrated;
  final String personalityDescription;
  final String careerDescription;
}
