import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._datasource);

  final ProfileLocalDatasource _datasource;

  @override
  Future<Profile?> getProfile(int id) async {
    final model = await _datasource.getProfile(id);
    return model?.toEntity();
  }

  @override
  Future<List<Profile>> getAllProfiles() async {
    final models = await _datasource.getAllProfiles();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> saveProfile(Profile profile) async {
    final model = ProfileModel(
      id: profile.id,
      nickname: profile.nickname,
      gender: profile.gender,
      birthDate: profile.birthDate,
      birthTime: profile.birthTime,
      birthPlace: profile.birthPlace,
      birthLat: profile.birthLat,
      birthLng: profile.birthLng,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
    return _datasource.saveProfile(model);
  }

  @override
  Future<void> deleteProfile(int id) => _datasource.deleteProfile(id);
}
