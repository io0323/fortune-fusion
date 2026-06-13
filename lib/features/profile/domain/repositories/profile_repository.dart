import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile?> getProfile(int id);
  Future<List<Profile>> getAllProfiles();
  Future<int> saveProfile(Profile profile);
  Future<void> deleteProfile(int id);
}
