import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/daily_fortune.dart';
import '../../domain/entities/integrated_reading.dart';

part 'fortune_provider.g.dart';

@riverpod
Future<DailyFortune> dailyFortune(Ref ref, int profileId, DateTime date) async {
  throw UnimplementedError();
}

@riverpod
Future<IntegratedReading> integratedReading(Ref ref, int profileId) async {
  throw UnimplementedError();
}
