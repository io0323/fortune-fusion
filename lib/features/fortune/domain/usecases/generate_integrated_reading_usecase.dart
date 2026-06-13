import '../entities/integrated_reading.dart';
import '../repositories/fortune_repository.dart';

class GenerateIntegratedReadingUsecase {
  const GenerateIntegratedReadingUsecase(this._repository);

  final FortuneRepository _repository;

  Future<IntegratedReading> call(int profileId) =>
      _repository.getIntegratedReading(profileId);
}
