import 'fortune_result.dart';

class DailyFortune {
  const DailyFortune({
    required this.date,
    required this.result,
  });

  final DateTime date;
  final FortuneResult result;
}
