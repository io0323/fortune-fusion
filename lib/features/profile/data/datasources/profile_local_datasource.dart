import '../../../../shared/database/app_database.dart';
import '../models/profile_model.dart';

abstract interface class ProfileLocalDatasource {
  Future<ProfileModel?> getProfile(int id);
  Future<List<ProfileModel>> getAllProfiles();
  Future<int> saveProfile(ProfileModel model);
  Future<void> deleteProfile(int id);
}

class ProfileLocalDatasourceImpl implements ProfileLocalDatasource {
  const ProfileLocalDatasourceImpl(this.db);

  // ignore: unused_field
  final AppDatabase db;

  @override
  Future<ProfileModel?> getProfile(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ProfileModel>> getAllProfiles() async {
    throw UnimplementedError();
  }

  @override
  Future<int> saveProfile(ProfileModel model) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProfile(int id) async {
    throw UnimplementedError();
  }
}
