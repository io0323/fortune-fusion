import 'package:drift/drift.dart';

import '../../../../shared/database/app_database.dart';
import '../models/profile_model.dart';

abstract interface class ProfileLocalDatasource {
  Future<ProfileModel?> getProfile(int id);
  Future<List<ProfileModel>> getAllProfiles();
  Future<int> saveProfile(ProfileModel model);
  Future<void> deleteProfile(int id);
}

class ProfileLocalDatasourceImpl implements ProfileLocalDatasource {
  const ProfileLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<ProfileModel?> getProfile(int id) async {
    final row = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  @override
  Future<List<ProfileModel>> getAllProfiles() async {
    final rows = await _db.select(_db.profiles).get();
    return rows.map(_rowToModel).toList();
  }

  @override
  Future<int> saveProfile(ProfileModel model) async {
    if (model.id == 0) {
      return _db.into(_db.profiles).insert(
            ProfilesCompanion.insert(
              nickname: model.nickname,
              gender: model.gender,
              birthDate: model.birthDate,
              birthTime: Value(model.birthTime),
              birthPlace: model.birthPlace,
              birthLat: model.birthLat,
              birthLng: model.birthLng,
            ),
          );
    } else {
      await (_db.update(_db.profiles)
            ..where((t) => t.id.equals(model.id)))
          .write(ProfilesCompanion(
        nickname: Value(model.nickname),
        gender: Value(model.gender),
        birthDate: Value(model.birthDate),
        birthTime: Value(model.birthTime),
        birthPlace: Value(model.birthPlace),
        birthLat: Value(model.birthLat),
        birthLng: Value(model.birthLng),
        updatedAt: Value(DateTime.now()),
      ));
      return model.id;
    }
  }

  @override
  Future<void> deleteProfile(int id) async {
    await (_db.delete(_db.profiles)..where((t) => t.id.equals(id))).go();
  }

  ProfileModel _rowToModel(Profile row) => ProfileModel(
        id: row.id,
        nickname: row.nickname,
        gender: row.gender,
        birthDate: row.birthDate,
        birthTime: row.birthTime,
        birthPlace: row.birthPlace,
        birthLat: row.birthLat,
        birthLng: row.birthLng,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
