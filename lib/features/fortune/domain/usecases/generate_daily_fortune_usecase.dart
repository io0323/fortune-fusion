import '../entities/daily_fortune.dart';
import '../repositories/fortune_repository.dart';

class GenerateDailyFortuneUsecase {
  const GenerateDailyFortuneUsecase(this._repository);

  final FortuneRepository _repository;

  Future<DailyFortune> call(int profileId, DateTime date) =>
      _repository.getDailyFortune(profileId, date);
}
