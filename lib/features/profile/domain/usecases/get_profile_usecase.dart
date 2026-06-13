import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUsecase {
  const GetProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<Profile?> call(int id) => _repository.getProfile(id);
}
