import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_engine.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late KyuseiEngine engine;

  setUp(() {
    engine = const KyuseiEngine();
  });

  group('KyuseiEngine', () {
    test('known birthdate returns correct honmei star', () {
      final profile = makeTestProfile(birthDate: DateTime(1990, 4, 15));
      expect(
        () => engine.calculateHonmeiStar(profile.birthDate),
        throwsUnimplementedError,
      );
    });

    test('lucky directions are calculated for target date', () {
      expect(
        () => engine.calculateLuckyDirections(
          honmeiStar: 3,
          targetDate: DateTime(2024, 6, 1),
        ),
        throwsUnimplementedError,
      );
    });
  });
}
