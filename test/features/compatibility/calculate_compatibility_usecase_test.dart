import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/compatibility/domain/usecases/calculate_compatibility_usecase.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/seiza_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/shichu_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/setsuiri_data.dart';
import 'package:fortune_fusion/features/profile/domain/entities/profile.dart';

Profile _makeProfile({
  required int id,
  required DateTime birthDate,
  DateTime? birthTime,
  double lat = 35.6895,
  double lng = 139.6917,
}) {
  final now = DateTime(2024, 1, 1);
  return Profile(
    id: id,
    nickname: 'test$id',
    gender: 'unknown',
    birthDate: birthDate,
    birthTime: birthTime,
    birthPlace: 'Tokyo',
    birthLat: lat,
    birthLng: lng,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late CalculateCompatibilityUsecase usecase;

  setUp(() {
    final setsuiri = SetsuiriData();
    usecase = CalculateCompatibilityUsecase(
      shichuEngine: ShichuEngine(setsuiriData: setsuiri),
      seizaEngine: const SeizaEngine(),
      kyuseiEngine: KyuseiEngine(setsuiriData: setsuiri),
    );
  });

  final pA = _makeProfile(
    id: 1,
    birthDate: DateTime(1990, 6, 15),
    birthTime: DateTime(1990, 6, 15, 10, 0),
  );
  final pB = _makeProfile(
    id: 2,
    birthDate: DateTime(1992, 3, 20),
    birthTime: DateTime(1992, 3, 20, 14, 30),
  );

  group('determinism', () {
    test('same inputs → same result', () {
      final r1 = usecase.call(pA, pB);
      final r2 = usecase.call(pA, pB);
      expect(r1, equals(r2));
    });

    test('swap A and B → same scores', () {
      final ab = usecase.call(pA, pB);
      final ba = usecase.call(pB, pA);
      expect(ab.loveScore, equals(ba.loveScore));
      expect(ab.workScore, equals(ba.workScore));
      expect(ab.friendScore, equals(ba.friendScore));
    });
  });

  group('score range', () {
    test('all scores 0-100', () {
      final r = usecase.call(pA, pB);
      expect(r.loveScore, inInclusiveRange(0, 100));
      expect(r.workScore, inInclusiveRange(0, 100));
      expect(r.friendScore, inInclusiveRange(0, 100));
      expect(r.shichuScore, inInclusiveRange(0, 100));
      expect(r.seizaScore, inInclusiveRange(0, 100));
      expect(r.kyuseiScore, inInclusiveRange(0, 100));
    });

    test('stars 1-5', () {
      final r = usecase.call(pA, pB);
      expect(r.loveStars, inInclusiveRange(1, 5));
      expect(r.workStars, inInclusiveRange(1, 5));
      expect(r.friendStars, inInclusiveRange(1, 5));
    });
  });

  group('partner time uncertain', () {
    test('null birthTime sets isPartnerTimeUncertain', () {
      final pBNoTime = _makeProfile(id: 3, birthDate: DateTime(1992, 3, 20));
      final r = usecase.call(pA, pBNoTime);
      expect(r.isPartnerTimeUncertain, isTrue);
    });

    test('known birthTime → isPartnerTimeUncertain is false', () {
      final r = usecase.call(pA, pB);
      expect(r.isPartnerTimeUncertain, isFalse);
    });

    test('null birthTime does not crash', () {
      final pBNoTime = _makeProfile(id: 3, birthDate: DateTime(1992, 3, 20));
      expect(() => usecase.call(pA, pBNoTime), returnsNormally);
    });

    test('null birthTime → scores remain in range', () {
      final pBNoTime = _makeProfile(id: 3, birthDate: DateTime(1992, 3, 20));
      final r = usecase.call(pA, pBNoTime);
      expect(r.loveScore, inInclusiveRange(0, 100));
      expect(r.workScore, inInclusiveRange(0, 100));
      expect(r.friendScore, inInclusiveRange(0, 100));
    });
  });

  group('shichu 干合 bonus', () {
    // 甲己 = 干合ペア. 甲=1990-01-04(庚午年→甲の日を探す), 己 pairing.
    // 甲日: dayIdx60 % 10 == 0. ref=1900-01-01, days=((10+days)%60)%10==0 → days%10==0
    // 1990-01-04: diff from 1900-01-01 = 32875 days. (10+32875)%60=45, 45%10=5 → 戊
    // Use 甲日: need (10+days)%10==0 → days%10==0. 1990-06-15: diff=33038. (10+33038)%60=48. 48%10=8 → 壬
    // Let me use 1990-03-01: diff=32934. (10+32934)%60=4. 4%10=4 → 戊
    // 甲 day: (10+days)%10==0 → days=10,20,30... 1900+10=1900-01-11. Too early.
    // For practical test: just verify that 甲己 pair scores higher than a 相剋 pair on raw shichu.
    // We test by checking comments differ or by using profiles where shichu is demonstrably different.
    test('comments are non-empty strings', () {
      final r = usecase.call(pA, pB);
      expect(r.loveComment, isNotEmpty);
      expect(r.workComment, isNotEmpty);
      expect(r.friendComment, isNotEmpty);
    });

    test('高得点ペアは相性コメントがhighまたはmid', () {
      // 同じ人との相性（完全一致）= 比和. shichuScore=65, kyusei=65, seiza varies
      final r = usecase.call(pA, pA);
      expect(r.loveScore, greaterThanOrEqualTo(40));
    });
  });

  group('known 干合 pair gets bonus', () {
    // 甲(0)-己(5): kangoBonus=15. We can verify shichuScore is higher than with 甲(0)-庚(6) 相剋.
    // Profile with 甲 nicchu: 1900-01-11 → days=10, (10+10)%60=20, stemIdx=20%10=0=甲 ✓
    // Profile with 己 nicchu: days=5+x where (10+x)%10==5 → x=55,115... 1900-03-07: diff=65, (10+65)%60=15, 15%10=5=己 ✓
    // Profile with 庚 nicchu (相剋 vs 甲): (10+x)%10==6 → x=56. 1900-02-26: diff=56, 66%60=6, 6%10=6=庚 ✓
    final pKou = _makeProfile(id: 10, birthDate: DateTime(1900, 1, 11)); // 甲日
    final pKi = _makeProfile(id: 11, birthDate: DateTime(1900, 3, 7));   // 己日 → 干合
    final pKo = _makeProfile(id: 12, birthDate: DateTime(1900, 2, 26));  // 庚日 → 相剋

    test('干合ペア(甲己) > 相剋ペア(甲庚) のshichuScore', () {
      final rKango = usecase.call(pKou, pKi);
      final rKokku = usecase.call(pKou, pKo);
      expect(rKango.shichuScore, greaterThan(rKokku.shichuScore));
    });
  });

  group('known 支合 pair gets bonus', () {
    // 子午冲 vs 子丑合. 子=dayBranchIdx=0, 丑=1, 午=6.
    // dayIdx60 % 12 = branchIdx.
    // 子(0): dayIdx60=0 or 12 or 24... (10+days)%60=0 → days=50. 1900-02-19: diff=49→(59)%60=59. No.
    // 子 branch: need (10+days)%12==0 → days where (10+days)%12==0. days=2: 12%12=0 ✓. 1900-01-03.
    // 丑(1): (10+days)%12==1 → days=3. 1900-01-04.
    // 午(6): (10+days)%12==6 → days=8. 1900-01-09.
    final pNe = _makeProfile(id: 20, birthDate: DateTime(1900, 1, 3));  // 子
    final pUshi = _makeProfile(id: 21, birthDate: DateTime(1900, 1, 4)); // 丑 → 子丑 支合
    final pUma = _makeProfile(id: 22, birthDate: DateTime(1900, 1, 9));  // 午 → 子午 冲

    test('支合(子丑) > 冲(子午) のshichuScore', () {
      final rShigo = usecase.call(pNe, pUshi);
      final rChu = usecase.call(pNe, pUma);
      expect(rShigo.shichuScore, greaterThan(rChu.shichuScore));
    });
  });
}
