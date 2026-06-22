import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../fortune/presentation/providers/fortune_provider.dart';
import '../../../meishiki/domain/engines/kyusei_board_calculator.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/direction_result.dart';
import '../../domain/usecases/calculate_direction_usecase.dart';

part 'direction_provider.g.dart';

@riverpod
KyuseiBoardCalculator directionBoardCalculator(Ref ref) =>
    KyuseiBoardCalculator(setsuiriData: ref.watch(setsuiriDataProvider));

@riverpod
Future<DirectionResult> direction(
  Ref ref,
  int profileId,
  DateTime targetDate,
) async {
  final profile = await ref.watch(currentProfileProvider(profileId).future);
  if (profile == null) throw StateError('Profile not found');
  return CalculateDirectionUsecase(
    kyuseiEngine: ref.watch(kyuseiEngineProvider),
    boardCalculator: ref.watch(directionBoardCalculatorProvider),
  ).call(profile, targetDate);
}
