import '../entities/daily_fortune.dart';
import '../entities/fortune_result.dart';
import '../entities/integrated_reading.dart';

abstract interface class FortuneRepository {
  Future<DailyFortune> getDailyFortune(int profileId, DateTime date);
  Future<List<FortuneResult>> getMonthlyFortune(int profileId, int year, int month);
  Future<List<FortuneResult>> getYearlyFortune(int profileId, int year);
  Future<IntegratedReading> getIntegratedReading(int profileId);
}
