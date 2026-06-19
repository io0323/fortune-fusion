import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../fortune/presentation/providers/fortune_provider.dart';
import '../../../meishiki/domain/engines/kyusei_board_calculator.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/compatibility_result.dart';
import '../../domain/usecases/calculate_compatibility_usecase.dart';

part 'compatibility_provider.g.dart';

@riverpod
KyuseiBoardCalculator kyuseiBoardCalculator(Ref ref) =>
    KyuseiBoardCalculator(setsuiriData: ref.watch(setsuiriDataProvider));

@riverpod
Future<CompatibilityResult> compatibility(
  Ref ref,
  int profileAId,
  int profileBId,
) async {
  final profileA = await ref.watch(currentProfileProvider(profileAId).future);
  final profileB = await ref.watch(currentProfileProvider(profileBId).future);
  if (profileA == null || profileB == null) {
    throw StateError('Profile not found');
  }
  return CalculateCompatibilityUsecase(
    shichuEngine: ref.watch(shichuEngineProvider),
    seizaEngine: ref.watch(seizaEngineProvider),
    kyuseiEngine: ref.watch(kyuseiEngineProvider),
  ).call(profileA, profileB);
}
