import '../entities/fortune_result.dart';
import '../repositories/fortune_repository.dart';

class GenerateMonthlyFortuneUsecase {
  const GenerateMonthlyFortuneUsecase(this._repository);

  final FortuneRepository _repository;

  Future<List<FortuneResult>> call(int profileId, int year, int month) =>
      _repository.getMonthlyFortune(profileId, year, month);
}
