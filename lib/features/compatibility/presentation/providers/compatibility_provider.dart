import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/compatibility_result.dart';

part 'compatibility_provider.g.dart';

@riverpod
Future<CompatibilityResult> compatibility(
  Ref ref,
  int profileAId,
  int profileBId,
) async {
  throw UnimplementedError();
}
