import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/profile.dart';

part 'profile_provider.g.dart';

@riverpod
Future<Profile?> currentProfile(Ref ref, int id) async {
  throw UnimplementedError();
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  AsyncValue<Profile?> build() => const AsyncValue.data(null);

  Future<void> save(Profile profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      throw UnimplementedError();
    });
  }
}
