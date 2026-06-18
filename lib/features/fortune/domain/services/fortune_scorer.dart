import 'dart:math' as math;

import '../../../meishiki/domain/entities/shichu_meishiki.dart';

class FortuneScorer {
  static const _workBases = [65, 50, 72, 30, 80];
  static const _stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

  static const _workBonuses = <TsuhenStar, int>{
    TsuhenStar.seikan: 18,
    TsuhenStar.henkan: 15,
    TsuhenStar.shokushin: 13,
    TsuhenStar.shokan: 10,
    TsuhenStar.hiken: 8,
    TsuhenStar.kokuzai: 5,
    TsuhenStar.henzai: 6,
    TsuhenStar.seizai: 6,
    TsuhenStar.henin: 6,
    TsuhenStar.insho: 8,
  };

  static const _moneyBaseScores = <TsuhenStar, int>{
    TsuhenStar.henzai: 85,
    TsuhenStar.seizai: 78,
    TsuhenStar.shokushin: 65,
    TsuhenStar.shokan: 55,
    TsuhenStar.seikan: 52,
    TsuhenStar.hiken: 42,
    TsuhenStar.henin: 38,
    TsuhenStar.insho: 35,
    TsuhenStar.henkan: 40,
    TsuhenStar.kokuzai: 28,
  };

  // diff=(todayElem-natalElem+5)%5
  // 0=同, 1=natal→today生, 2=natal克today, 3=today克natal, 4=today→natal生
  static int workScore(int natalElem, int todayElem, TsuhenStar tsuhen) {
    final diff = (todayElem - natalElem + 5) % 5;
    return (_workBases[diff] + (_workBonuses[tsuhen] ?? 5)).clamp(0, 100);
  }

  // todayElem==2(土) に+8ボーナス
  static int moneyScore(TsuhenStar tsuhen, int todayElem) {
    return ((_moneyBaseScores[tsuhen] ?? 40) + (todayElem == 2 ? 8 : 0))
        .clamp(0, 100);
  }

  // natalElem/todayElem: ZodiacSign.index%4 → 0=火,1=地,2=風,3=水
  static int loveScore(int natalElem, int todayElem) {
    if (natalElem == todayElem) return 80;
    final a = natalElem, b = todayElem;
    if ((a == 0 && b == 2) || (a == 2 && b == 0)) return 68; // 火-風 トライン
    if ((a == 1 && b == 3) || (a == 3 && b == 1)) return 72; // 地-水 トライン
    if ((a == 0 && b == 3) || (a == 3 && b == 0)) return 28; // 火-水 オポジション
    if ((a == 1 && b == 2) || (a == 2 && b == 1)) return 32; // 地-風 オポジション
    return 48;
  }

  // todayElem 0-4 (0=木,1=火,2=土,3=金,4=水)
  static int healthScore(ShichuMeishiki natal, int todayElem) {
    final counts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0};
    for (final pillar in [
      natal.nenchu,
      natal.gecchu,
      natal.nicchu,
      if (natal.jichu != null) natal.jichu!,
    ]) {
      final idx = _stems.indexOf(pillar.stem);
      if (idx >= 0) counts[idx ~/ 2] = counts[idx ~/ 2]! + 1;
    }
    final minC = counts.values.reduce(math.min);
    final maxC = counts.values.reduce(math.max);
    final deficient = counts.entries.firstWhere((e) => e.value == minC).key;
    final dominant = counts.entries.firstWhere((e) => e.value == maxC).key;
    if (todayElem == deficient) return 85;
    if (todayElem == dominant) return 30;
    return 55;
  }

  static int toStars(int score) {
    if (score <= 20) return 1;
    if (score <= 40) return 2;
    if (score <= 60) return 3;
    if (score <= 80) return 4;
    return 5;
  }
}
