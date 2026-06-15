import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/shichu_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/setsuiri_data.dart';
import 'package:fortune_fusion/features/meishiki/domain/entities/shichu_meishiki.dart';

void main() {
  late ShichuEngine engine;
  const stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

  setUp(() {
    engine = ShichuEngine(setsuiriData: SetsuiriData());
  });

  group('ShichuEngine', () {
    // Test 1: Golden test — 1990年6月15日 12:00 → 年柱 庚午
    test('1990-06-15 year pillar is 庚午', () {
      final result = engine.calculate(birthDate: DateTime(1990, 6, 15, 12, 0));
      expect(result.nenchu.stem, equals('庚'));
      expect(result.nenchu.branch, equals('午'));
    });

    // Test 2: Risshun boundary — 1984年2月4日 前後で年柱分岐
    // Default SetsuiriData: risshun = Feb 4 12:00
    test('risshun boundary splits year pillar', () {
      final before = engine.calculate(birthDate: DateTime(1984, 2, 4, 11, 59));
      expect(before.nenchu.stem, equals('癸'));
      expect(before.nenchu.branch, equals('亥'));

      final after = engine.calculate(birthDate: DateTime(1984, 2, 4, 12, 0));
      expect(after.nenchu.stem, equals('甲'));
      expect(after.nenchu.branch, equals('子'));
    });

    // Test 3: Day continuity — 連続する日は干支インデックスが+1
    test('consecutive days increment day pillar by 1', () {
      final d1 = engine.calculate(birthDate: DateTime(2024, 3, 15));
      final d2 = engine.calculate(birthDate: DateTime(2024, 3, 16));
      final stemDiff =
          (stems.indexOf(d2.nicchu.stem) - stems.indexOf(d1.nicchu.stem) + 10) % 10;
      final branchDiff =
          (branches.indexOf(d2.nicchu.branch) - branches.indexOf(d1.nicchu.branch) + 12) % 12;
      expect(stemDiff, equals(1));
      expect(branchDiff, equals(1));
    });

    // Test 4: 23:30 夜子時 → 時支=子、日干はそのまま
    test('23:30 night zi-shi has branch 子', () {
      // 1900-01-01: dayIdx60=10, 10%10=0→甲, 10%12=10→戌
      final result = engine.calculate(
        birthDate: DateTime(1900, 1, 1),
        birthTime: DateTime(1900, 1, 1, 23, 30),
      );
      expect(result.jichu, isNotNull);
      expect(result.jichu!.branch, equals('子'));
      // 甲己日 → 子時: goratonBase[0%5=0]=0, hourBranchIdx=0 → stemIdx=(0+0)%10=0 → 甲
      expect(result.jichu!.stem, equals('甲'));
    });

    // Test 5: null birthTime → 時柱 null
    test('null birth time gives null hour pillar', () {
      final result = engine.calculate(birthDate: DateTime(1990, 6, 15));
      expect(result.jichu, isNull);
    });

    // Test 6: 通変星 — 甲辰日の蔵干で乙=劫財を検証
    // 1900-01-31: days=30, dayIdx=(10+30)%60=40, 40%10=0→甲, 40%12=4→辰
    test('tsuhen: 甲日干 vs 乙=劫財, via zokan of 辰 branch', () {
      final result = engine.calculate(birthDate: DateTime(1900, 1, 31));
      expect(result.nicchu.stem, equals('甲'));
      expect(result.nicchu.branch, equals('辰'));
      final zokan = result.nicchu.zokan;
      final etu = zokan.firstWhere((e) => e.stem == '乙');
      expect(etu.tsuhen, equals(TsuhenStar.kokuzai)); // 乙=劫財
      // 日主の通変星はnull
      expect(result.nicchu.tsuhen, isNull);
    });

    // Test 7: 通変星 — 甲寅日の蔵干で丙=食神を検証
    // 1900-02-10: days=40, dayIdx=(10+40)%60=50, 50%10=0→甲, 50%12=2→寅
    test('tsuhen: 甲 vs 丙 = 食神 via zokan of 寅 branch', () {
      final result = engine.calculate(birthDate: DateTime(1900, 2, 10));
      expect(result.nicchu.stem, equals('甲'));
      expect(result.nicchu.branch, equals('寅'));
      final zokan = result.nicchu.zokan;
      final hei = zokan.firstWhere((e) => e.stem == '丙');
      expect(hei.tsuhen, equals(TsuhenStar.shokushin)); // 丙=食神
    });
  });
}
