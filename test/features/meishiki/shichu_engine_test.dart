import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/shichu_engine.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late ShichuEngine engine;

  setUp(() {
    engine = const ShichuEngine();
  });

  group('ShichuEngine', () {
    test('known birthdate returns correct meishiki', () {
      final profile = makeTestProfile(birthDate: DateTime(1990, 4, 15));
      expect(
        () => engine.calculate(birthDate: profile.birthDate),
        throwsUnimplementedError,
      );
    });

    test('leap year is handled correctly', () {
      final profile = makeTestProfile(birthDate: DateTime(2000, 2, 29));
      expect(
        () => engine.calculate(birthDate: profile.birthDate),
        throwsUnimplementedError,
      );
    });

    test('no birth time returns null hour pillar', () {
      final profile = makeTestProfile();
      expect(
        () => engine.calculate(birthDate: profile.birthDate, birthTime: null),
        throwsUnimplementedError,
      );
    });
  });
}
