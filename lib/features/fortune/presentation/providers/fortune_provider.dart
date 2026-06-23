import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../../meishiki/domain/engines/kyusei_engine.dart';
import '../../../meishiki/domain/engines/seiza_engine.dart';
import '../../../meishiki/domain/engines/shichu_engine.dart';
import '../../../meishiki/domain/engines/setsuiri_data.dart';
import '../../data/repositories/fortune_repository_impl.dart';
import '../../domain/entities/daily_fortune.dart';
import '../../domain/entities/fortune_result.dart';
import '../../domain/entities/integrated_reading.dart';
import '../../domain/repositories/fortune_repository.dart';
import '../../domain/usecases/generate_daily_fortune_usecase.dart';
import '../../domain/usecases/generate_monthly_fortune_usecase.dart';
import '../../domain/usecases/generate_yearly_fortune_usecase.dart';

part 'fortune_provider.g.dart';

@riverpod
SetsuiriData setsuiriData(Ref ref) => SetsuiriData();

@riverpod
ShichuEngine shichuEngine(Ref ref) =>
    ShichuEngine(setsuiriData: ref.watch(setsuiriDataProvider));

@riverpod
SeizaEngine seizaEngine(Ref ref) => const SeizaEngine();

@riverpod
KyuseiEngine kyuseiEngine(Ref ref) =>
    KyuseiEngine(setsuiriData: ref.watch(setsuiriDataProvider));

@riverpod
FortuneRepository fortuneRepository(Ref ref) => FortuneRepositoryImpl(
      db: ref.watch(appDatabaseProvider),
      shichuEngine: ref.watch(shichuEngineProvider),
      seizaEngine: ref.watch(seizaEngineProvider),
      kyuseiEngine: ref.watch(kyuseiEngineProvider),
    );

@riverpod
Future<DailyFortune> dailyFortune(Ref ref, int profileId, DateTime date) =>
    GenerateDailyFortuneUsecase(ref.watch(fortuneRepositoryProvider))
        .call(profileId, date);

@riverpod
Future<List<FortuneResult>> monthlyFortune(
        Ref ref, int profileId, int year, int month) =>
    GenerateMonthlyFortuneUsecase(ref.watch(fortuneRepositoryProvider))
        .call(profileId, year, month);

@riverpod
Future<List<FortuneResult>> yearlyFortune(Ref ref, int profileId, int year) =>
    GenerateYearlyFortuneUsecase(ref.watch(fortuneRepositoryProvider))
        .call(profileId, year);

@riverpod
Future<IntegratedReading> integratedReading(Ref ref, int profileId) async {
  throw UnimplementedError();
}
