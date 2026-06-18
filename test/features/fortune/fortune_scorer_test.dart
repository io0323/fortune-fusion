import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/fortune/domain/services/fortune_scorer.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/setsuiri_data.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/shichu_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/entities/shichu_meishiki.dart';

void main() {
  group('FortuneScorer.toStars', () {
    test('境界値: 全スコアで1〜5の範囲', () {
      for (int s = 0; s <= 100; s++) {
        expect(FortuneScorer.toStars(s), inInclusiveRange(1, 5),
            reason: 'score=$s');
      }
    });

    test('区切り境界が正しい', () {
      expect(FortuneScorer.toStars(0), 1);
      expect(FortuneScorer.toStars(20), 1);
      expect(FortuneScorer.toStars(21), 2);
      expect(FortuneScorer.toStars(40), 2);
      expect(FortuneScorer.toStars(41), 3);
      expect(FortuneScorer.toStars(60), 3);
      expect(FortuneScorer.toStars(61), 4);
      expect(FortuneScorer.toStars(80), 4);
      expect(FortuneScorer.toStars(81), 5);
      expect(FortuneScorer.toStars(100), 5);
    });
  });

  group('FortuneScorer.workScore 五行生剋', () {
    // natal=甲(木, elem=0) を基準に五行生剋関係を検証
    // bases=[65,50,72,30,80] for diff=[0,1,2,3,4]
    // 甲(0)対: 甲(0)=hiken, 丙(2)=shokushin, 戊(4)=henzai, 庚(6)=henkan, 壬(8)=henin
    test('今日natal生ずる(水→木,diff=4,base=80) > natal克today(木→土,diff=2,base=72) > 同(diff=0,base=65) > natal生today(木→火,diff=1,base=50) > 今日natal克(金→木,diff=3,base=30)', () {
      final todayGenNatal = FortuneScorer.workScore(0, 4, TsuhenStar.henin); // 80+6=86
      final natalConqToday = FortuneScorer.workScore(0, 2, TsuhenStar.henzai); // 72+6=78
      final same = FortuneScorer.workScore(0, 0, TsuhenStar.hiken); // 65+8=73
      final natalGenToday = FortuneScorer.workScore(0, 1, TsuhenStar.shokushin); // 50+13=63
      final todayConqNatal = FortuneScorer.workScore(0, 3, TsuhenStar.henkan); // 30+15=45

      expect(todayGenNatal, greaterThan(natalConqToday));
      expect(natalConqToday, greaterThan(same));
      expect(same, greaterThan(natalGenToday));
      expect(natalGenToday, greaterThan(todayConqNatal));
    });

    test('既知値: today→natal生(水→木, diff=4, henin) = 86', () {
      expect(FortuneScorer.workScore(0, 4, TsuhenStar.henin), equals(86));
    });

    test('既知値: today克natal(金→木, diff=3, henkan) = 45', () {
      expect(FortuneScorer.workScore(0, 3, TsuhenStar.henkan), equals(45));
    });

    test('既知値: natal克today(木→土, diff=2, henzai) = 78', () {
      expect(FortuneScorer.workScore(0, 2, TsuhenStar.henzai), equals(78));
    });

    test('全組み合わせで0〜100の範囲', () {
      for (final tsuhen in TsuhenStar.values) {
        for (int n = 0; n < 5; n++) {
          for (int t = 0; t < 5; t++) {
            final s = FortuneScorer.workScore(n, t, tsuhen);
            expect(s, inInclusiveRange(0, 100),
                reason: 'natal=$n today=$t tsuhen=$tsuhen');
          }
        }
      }
    });
  });

  group('FortuneScorer.loveScore 西洋元素相性', () {
    test('同じ元素 → 80', () {
      expect(FortuneScorer.loveScore(0, 0), equals(80));
      expect(FortuneScorer.loveScore(3, 3), equals(80));
    });

    test('火(0)-水(3) オポジション → 28', () {
      expect(FortuneScorer.loveScore(0, 3), equals(28));
      expect(FortuneScorer.loveScore(3, 0), equals(28));
    });

    test('地(1)-水(3) トライン → 72', () {
      expect(FortuneScorer.loveScore(1, 3), equals(72));
      expect(FortuneScorer.loveScore(3, 1), equals(72));
    });

    test('火(0)-風(2) トライン → 68', () {
      expect(FortuneScorer.loveScore(0, 2), equals(68));
      expect(FortuneScorer.loveScore(2, 0), equals(68));
    });

    test('地(1)-風(2) オポジション → 32', () {
      expect(FortuneScorer.loveScore(1, 2), equals(32));
      expect(FortuneScorer.loveScore(2, 1), equals(32));
    });

    test('隣接(火-地, 風-水) → 48', () {
      expect(FortuneScorer.loveScore(0, 1), equals(48));
      expect(FortuneScorer.loveScore(2, 3), equals(48));
    });

    test('相性スコアは対称', () {
      for (int a = 0; a < 4; a++) {
        for (int b = 0; b < 4; b++) {
          expect(FortuneScorer.loveScore(a, b), equals(FortuneScorer.loveScore(b, a)));
        }
      }
    });
  });

  group('FortuneScorer.moneyScore', () {
    test('偏財(henzai) = 85', () {
      expect(FortuneScorer.moneyScore(TsuhenStar.henzai, 0), equals(85));
    });

    test('正財(seizai) = 78', () {
      expect(FortuneScorer.moneyScore(TsuhenStar.seizai, 0), equals(78));
    });

    test('偏財 > 正財 > 食神', () {
      final henzai = FortuneScorer.moneyScore(TsuhenStar.henzai, 0);
      final seizai = FortuneScorer.moneyScore(TsuhenStar.seizai, 0);
      final shokushin = FortuneScorer.moneyScore(TsuhenStar.shokushin, 0);
      expect(henzai, greaterThan(seizai));
      expect(seizai, greaterThan(shokushin));
    });

    test('土気ボーナス(todayElem=2): hiken(42)+8=50', () {
      expect(FortuneScorer.moneyScore(TsuhenStar.hiken, 2), equals(50));
      expect(FortuneScorer.moneyScore(TsuhenStar.hiken, 0), equals(42));
    });
  });

  group('FortuneScorer.healthScore', () {
    final engine = ShichuEngine(setsuiriData: SetsuiriData());

    test('不足五行で85, 旺盛五行で30, 中立で55', () {
      final natal = engine.calculate(birthDate: DateTime(1990, 6, 15));
      final scores = List.generate(5, (e) => FortuneScorer.healthScore(natal, e));
      expect(scores, contains(85));
      expect(scores, contains(30));
      expect(scores, everyElement(anyOf(equals(85), equals(55), equals(30))));
    });

    test('出生時刻なし命式でも正常動作', () {
      final natal = engine.calculate(birthDate: DateTime(1990, 6, 15));
      for (int e = 0; e < 5; e++) {
        expect(FortuneScorer.healthScore(natal, e), inInclusiveRange(0, 100));
      }
    });
  });
}
