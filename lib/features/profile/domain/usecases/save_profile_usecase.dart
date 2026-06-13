import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfileUsecase {
  const SaveProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<int> call(Profile profile) => _repository.saveProfile(profile);
}
