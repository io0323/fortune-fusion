import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/setsuiri_data.dart';
import 'package:fortune_fusion/features/meishiki/domain/entities/kyusei_result.dart';

// 立春時刻を含むテスト用SetsuiriData
SetsuiriData _testData() => SetsuiriData(
      risshunOverrides: {
        1985: DateTime(1985, 2, 4, 10, 11),
        1987: DateTime(1987, 2, 4, 22, 9),
        1988: DateTime(1988, 2, 4, 4, 3),
        1990: DateTime(1990, 2, 4, 15, 27),
        1999: DateTime(1999, 2, 4, 19, 57),
        2000: DateTime(2000, 2, 4, 8, 33),
      },
      defaultRisshunDay: 4,
      defaultRisshunHour: 12,
      defaultRisshunMinute: 0,
    );

void main() {
  late KyuseiEngine engine;

  setUp(() {
    engine = KyuseiEngine(setsuiriData: _testData());
  });

  group('本命星 ゴールデンテスト', () {
    // 検算:
    // 1990: 1+9+9+0=19→10→1, 11-1=10→1 → 一白水星
    test('1990/6/15 → 一白水星', () {
      final result = engine.calcHonmeisei(DateTime(1990, 6, 15));
      expect(result, KyuseiStar.ikkhaku);
    });

    // 1985: 1+9+8+5=23→5, 11-5=6 → 六白金星
    test('1985/3/20 → 六白金星', () {
      final result = engine.calcHonmeisei(DateTime(1985, 3, 20));
      expect(result, KyuseiStar.roppaku);
    });

    // 1988/1/10は立春(1988/2/4 04:03)前 → 九星年=1987
    // 1987: 1+9+8+7=25→7, 11-7=4 → 四緑木星
    test('1988/1/10（立春前）→ 九星年1987 → 四緑木星', () {
      final result = engine.calcHonmeisei(DateTime(1988, 1, 10));
      expect(result, KyuseiStar.shiryoku);
    });

    // 2000立春 08:33 JST、07:00生まれ → 九星年1999
    // 1999: 1+9+9+9=28→10→1, 11-1=10→1 → 一白水星
    test('2000/2/4 07:00（立春前）→ 九星年1999 → 一白水星', () {
      final result = engine.calcHonmeisei(DateTime(2000, 2, 4, 7, 0));
      expect(result, KyuseiStar.ikkhaku);
    });

    // 2000立春 08:33 JST、09:00生まれ → 九星年2000
    // 2000: 2+0+0+0=2, 11-2=9 → 九紫火星
    test('2000/2/4 09:00（立春後）→ 九星年2000 → 九紫火星', () {
      final result = engine.calcHonmeisei(DateTime(2000, 2, 4, 9, 0));
      expect(result, KyuseiStar.kyushi);
    });

    // 閏年 2000/2/29: 立春(2/4 08:33)後 → 九星年2000 → 九紫火星
    test('閏年 2000/2/29 → 九星年2000 → 九紫火星', () {
      final result = engine.calcHonmeisei(DateTime(2000, 2, 29));
      expect(result, KyuseiStar.kyushi);
    });
  });

  group('月命星 ゴールデンテスト', () {
    // 1990/6/15: 本命星=一白(Group A)
    // 6/15 は 芒種(6/6)以降 小暑(7/7)未満 → 節月5
    // Group A 節月5 = 4 → 四緑木星
    test('1990/6/15 → 月命星 四緑木星', () {
      final result = engine.calculate(birthDate: DateTime(1990, 6, 15));
      expect(result.getsumeisei, KyuseiStar.shiryoku);
    });

    // 1985/3/20: 本命星=六白(Group C)
    // 3/20 は 啓蟄(3/6)以降 清明(4/5)未満 → 節月2
    // Group C 節月2 = 4 → 四緑木星
    test('1985/3/20 → 月命星 四緑木星', () {
      final result = engine.calculate(birthDate: DateTime(1985, 3, 20));
      expect(result.getsumeisei, KyuseiStar.shiryoku);
    });

    // 1988/1/10: 九星年1987, 本命星=四緑(Group A)
    // 1/10 は 小寒(1/6)以降 立春(2/4)未満 → 節月12
    // Group A 節月12 = 6 → 六白金星
    test('1988/1/10（立春前）→ 月命星 六白金星', () {
      final result = engine.calculate(birthDate: DateTime(1988, 1, 10));
      expect(result.getsumeisei, KyuseiStar.roppaku);
    });

    // 閏年 2000/2/29: 本命星=九紫(Group C)
    // 2/29 は 立春(2/4)以降 啓蟄(3/6)未満 → 節月1
    // Group C 節月1 = 5 → 五黄土星
    test('閏年 2000/2/29 → 月命星 五黄土星', () {
      final result = engine.calculate(birthDate: DateTime(2000, 2, 29));
      expect(result.getsumeisei, KyuseiStar.gokou);
    });
  });

  group('傾斜宮 ゴールデンテスト', () {
    // 1990/6/15: 本命星=1(一白), 月命星=4(四緑)
    // keishaPos = ((4 - 1 + 4) % 9) + 1 = 8 → 艮宮
    test('1990/6/15 → 傾斜宮 艮宮', () {
      final result = engine.calculate(birthDate: DateTime(1990, 6, 15));
      expect(result.keisha, KeishaKyu.gon);
    });

    // 1985/3/20: 本命星=6(六白), 月命星=4(四緑)
    // keishaPos = ((4 - 6 + 4) % 9) + 1 = (2 % 9) + 1 = 3 → 震宮
    test('1985/3/20 → 傾斜宮 震宮', () {
      final result = engine.calculate(birthDate: DateTime(1985, 3, 20));
      expect(result.keisha, KeishaKyu.shin);
    });

    // 1988/1/10: 本命星=4(四緑), 月命星=6(六白)
    // keishaPos = ((6 - 4 + 4) % 9) + 1 = (6 % 9) + 1 = 7 → 兌宮
    test('1988/1/10 → 傾斜宮 兌宮', () {
      final result = engine.calculate(birthDate: DateTime(1988, 1, 10));
      expect(result.keisha, KeishaKyu.da);
    });

    // 2000/2/29: 本命星=9(九紫), 月命星=5(五黄)
    // keishaPos = ((5 - 9 + 4) % 9) + 1 = (0 % 9) + 1 = 1 → 坎宮
    test('閏年 2000/2/29 → 傾斜宮 坎宮', () {
      final result = engine.calculate(birthDate: DateTime(2000, 2, 29));
      expect(result.keisha, KeishaKyu.kan);
    });
  });

  group('年盤中宮星', () {
    test('2000年の年盤中宮星 = 9(九紫)', () {
      final result = engine.calculate(
        birthDate: DateTime(1990, 6, 15),
        targetDate: DateTime(2000, 6, 1),
      );
      expect(result.nenbanCenter, 9);
    });

    test('1985年の年盤中宮星 = 6(六白)', () {
      final result = engine.calculate(
        birthDate: DateTime(1990, 6, 15),
        targetDate: DateTime(1985, 6, 1),
      );
      expect(result.nenbanCenter, 6);
    });
  });

  group('境界値テスト', () {
    test('立春ちょうど1分前 → 前年扱い', () {
      final birthDate = DateTime(2000, 2, 4, 8, 32);
      expect(engine.calcHonmeisei(birthDate), KyuseiStar.ikkhaku);
    });

    test('立春ちょうどの時刻 → 当年扱い', () {
      final birthDate = DateTime(2000, 2, 4, 8, 33);
      expect(engine.calcHonmeisei(birthDate), KyuseiStar.kyushi);
    });
  });
}
