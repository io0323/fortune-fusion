import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/save_profile_usecase.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileLocalDatasource profileLocalDatasource(Ref ref) =>
    ProfileLocalDatasourceImpl(ref.watch(appDatabaseProvider));

@riverpod
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepositoryImpl(ref.watch(profileLocalDatasourceProvider));

@riverpod
Future<Profile?> currentProfile(Ref ref, int id) =>
    ref.watch(profileRepositoryProvider).getProfile(id);

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  AsyncValue<Profile?> build() => const AsyncValue.data(null);

  Future<void> save(Profile profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final id = await SaveProfileUsecase(ref.read(profileRepositoryProvider))
          .call(profile);
      return profile.copyWith(id: id);
    });
  }
}
