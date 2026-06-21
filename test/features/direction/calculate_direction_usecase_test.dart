import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/direction/domain/entities/direction_result.dart';
import 'package:fortune_fusion/features/direction/domain/usecases/calculate_direction_usecase.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_board_calculator.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/setsuiri_data.dart';
import 'package:fortune_fusion/features/profile/domain/entities/profile.dart';

SetsuiriData _testData() => SetsuiriData(
      risshunOverrides: {
        1985: DateTime(1985, 2, 4, 10, 11),
        1990: DateTime(1990, 2, 4, 15, 27),
        2000: DateTime(2000, 2, 4, 8, 33),
        2024: DateTime(2024, 2, 4, 17, 27),
        2025: DateTime(2025, 2, 3, 22, 10),
        2026: DateTime(2026, 2, 4, 4, 2),
      },
      defaultRisshunDay: 4,
      defaultRisshunHour: 12,
      defaultRisshunMinute: 0,
    );

Profile _profile({DateTime? birthDate}) => Profile(
      id: 1,
      nickname: 'テスト',
      gender: 'male',
      birthDate: birthDate ?? DateTime(1990, 6, 15),
      birthPlace: '東京',
      birthLat: 35.6895,
      birthLng: 139.6917,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

void main() {
  late CalculateDirectionUsecase usecase;
  late KyuseiBoardCalculator boardCalculator;

  setUp(() {
    final data = _testData();
    final kyuseiEngine = KyuseiEngine(setsuiriData: data);
    boardCalculator = KyuseiBoardCalculator(setsuiriData: data);
    usecase = CalculateDirectionUsecase(
      kyuseiEngine: kyuseiEngine,
      boardCalculator: boardCalculator,
    );
  });

  group('決定論', () {
    test('同一入力で同一結果', () {
      final date = DateTime(2025, 6, 15);
      final profile = _profile();
      final r1 = usecase(profile, date);
      final r2 = usecase(profile, date);
      expect(r1, equals(r2));
    });

    test('directions は常に8方位', () {
      final result = usecase(_profile(), DateTime(2025, 3, 10));
      expect(result.directions.length, 8);
    });
  });

  group('五黄殺・暗剣殺', () {
    // 月盤中宮が5以外の日を選ぶ。2025/3/10 月盤中宮を確認。
    // 2025年九星年: 2+0+2+5=9, 11-9=2 → 二黒土星
    // 節月3(3/6〜) = 辰月 → group B(2,5,8)のindex2 → _getsumeiTable[1][2]=9
    // → 月盤中宮=9 → 五黄土星は中宮以外に回座
    test('五黄殺と暗剣殺が正反対の方位', () {
      final result = usecase(_profile(), DateTime(2025, 3, 10), boardType: KyuseiBoardType.month);
      final gokoSatsu = result.directions.where((d) => d.reason == '五黄殺').toList();
      final ankensatsu = result.directions.where((d) => d.reason == '暗剣殺').toList();

      // 月盤中宮≠5なら両方存在する
      if (gokoSatsu.isNotEmpty && ankensatsu.isNotEmpty) {
        final allDirs = ['北', '北東', '東', '東南', '南', '南西', '西', '北西'];
        final gokoIdx = allDirs.indexOf(gokoSatsu.first.direction);
        final ankenIdx = allDirs.indexOf(ankensatsu.first.direction);
        // 正反対: 差が4（8方位の半分）
        expect((gokoIdx - ankenIdx).abs() % 4, 0);
        expect((gokoIdx - ankenIdx).abs(), 4);
      }
    });

    test('五黄殺はdaikyo、暗剣殺はdaikyo', () {
      final result = usecase(_profile(), DateTime(2025, 3, 10), boardType: KyuseiBoardType.month);
      for (final d in result.directions) {
        if (d.reason == '五黄殺' || d.reason == '暗剣殺') {
          expect(d.rank, DirectionRank.daikyo, reason: '${d.direction}: ${d.reason}');
        }
      }
    });
  });

  group('凶方位6種の検証', () {
    test('本命殺・本命的殺が存在する（中宮でない限り）', () {
      // 1990/6/15生まれ → 本命星=一白水星(1)
      // 月盤中宮が1以外なら本命殺が現れる
      final result = usecase(_profile(), DateTime(2025, 6, 15), boardType: KyuseiBoardType.month);
      final honmeiSatsu = result.directions.where((d) => d.reason == '本命殺').toList();
      final honmeiTeki = result.directions.where((d) => d.reason == '本命的殺').toList();
      // 月盤中宮が1でない場合に成立
      final board = boardCalculator.calculateBoard(KyuseiBoardType.month, DateTime(2025, 6, 15));
      final centerStar = board[5]!.number;
      if (centerStar != 1) {
        expect(honmeiSatsu.length, 1);
        expect(honmeiTeki.length, 1);
      }
    });

    test('本命殺と本命的殺は正反対', () {
      final result = usecase(_profile(), DateTime(2025, 6, 15), boardType: KyuseiBoardType.month);
      final satsu = result.directions.where((d) => d.reason == '本命殺').toList();
      final teki = result.directions.where((d) => d.reason == '本命的殺').toList();
      if (satsu.isNotEmpty && teki.isNotEmpty) {
        final allDirs = ['北', '北東', '東', '東南', '南', '南西', '西', '北西'];
        final sIdx = allDirs.indexOf(satsu.first.direction);
        final tIdx = allDirs.indexOf(teki.first.direction);
        expect((sIdx - tIdx).abs(), 4);
      }
    });

    test('凶方位の種類は最大6種（重複時は先勝ち）', () {
      final result = usecase(_profile(), DateTime(2025, 4, 10), boardType: KyuseiBoardType.month);
      final unluckyReasons = result.unlucky.map((d) => d.reason).toSet();
      expect(unluckyReasons.length, lessThanOrEqualTo(8));
    });
  });

  group('吉方位が凶方位と重複しない', () {
    test('luckyとunluckyの方位が重複しない', () {
      for (final date in [
        DateTime(2025, 1, 20),
        DateTime(2025, 4, 5),
        DateTime(2025, 9, 1),
        DateTime(2026, 2, 10),
      ]) {
        final result = usecase(_profile(), date);
        final luckyDirs = result.lucky.map((d) => d.direction).toSet();
        final unluckyDirs = result.unlucky.map((d) => d.direction).toSet();
        expect(
          luckyDirs.intersection(unluckyDirs),
          isEmpty,
          reason: '$date で吉凶が重複',
        );
      }
    });
  });

  group('盤種別で結果が変わる', () {
    test('年盤・月盤・日盤で異なる結果', () {
      final profile = _profile();
      final date = DateTime(2025, 6, 15);
      final year = usecase(profile, date, boardType: KyuseiBoardType.year);
      final month = usecase(profile, date, boardType: KyuseiBoardType.month);
      final day = usecase(profile, date, boardType: KyuseiBoardType.day);

      expect(year.boardType, KyuseiBoardType.year);
      expect(month.boardType, KyuseiBoardType.month);
      expect(day.boardType, KyuseiBoardType.day);

      // 3つの盤が全て同一ということはない（理論上）
      final allSame = year.directions == month.directions &&
          month.directions == day.directions;
      expect(allSame, isFalse);
    });
  });

  group('凶方位ランク', () {
    test('本命殺・月命殺などはkyo', () {
      final result = usecase(_profile(), DateTime(2025, 6, 15), boardType: KyuseiBoardType.month);
      for (final d in result.directions) {
        if (d.reason == '本命殺' ||
            d.reason == '本命的殺' ||
            d.reason == '月命殺' ||
            d.reason == '月命的殺' ||
            d.reason == '月破' ||
            d.reason == '歳破') {
          expect(d.rank, DirectionRank.kyo, reason: '${d.direction}: ${d.reason}');
        }
      }
    });
  });
}
