import '../../domain/entities/daily_fortune.dart';
import '../../domain/entities/fortune_result.dart';
import '../../domain/entities/integrated_reading.dart';
import '../../domain/repositories/fortune_repository.dart';

class FortuneRepositoryImpl implements FortuneRepository {
  const FortuneRepositoryImpl();

  @override
  Future<DailyFortune> getDailyFortune(int profileId, DateTime date) {
    throw UnimplementedError();
  }

  @override
  Future<List<FortuneResult>> getMonthlyFortune(int profileId, int year, int month) {
    throw UnimplementedError();
  }

  @override
  Future<List<FortuneResult>> getYearlyFortune(int profileId, int year) {
    throw UnimplementedError();
  }

  @override
  Future<IntegratedReading> getIntegratedReading(int profileId) {
    throw UnimplementedError();
  }
}
