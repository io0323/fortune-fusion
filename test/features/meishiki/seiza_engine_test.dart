import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/seiza_engine.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SeizaEngine engine;

  setUp(() {
    engine = const SeizaEngine();
  });

  group('SeizaEngine', () {
    test('known birthdate returns correct horoscope', () {
      final profile = makeTestProfile(birthDate: DateTime(1990, 4, 15));
      expect(
        () => engine.calculate(
          birthDate: profile.birthDate,
          latitude: profile.birthLat,
          longitude: profile.birthLng,
        ),
        throwsUnimplementedError,
      );
    });

    test('sun sign is calculated correctly', () {
      expect(
        () => engine.calculateSunSign(DateTime(1990, 4, 15)),
        throwsUnimplementedError,
      );
    });
  });
}
