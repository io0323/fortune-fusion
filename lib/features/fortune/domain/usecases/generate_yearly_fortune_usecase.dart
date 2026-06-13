import '../entities/fortune_result.dart';
import '../repositories/fortune_repository.dart';

class GenerateYearlyFortuneUsecase {
  const GenerateYearlyFortuneUsecase(this._repository);

  final FortuneRepository _repository;

  Future<List<FortuneResult>> call(int profileId, int year) =>
      _repository.getYearlyFortune(profileId, year);
}
