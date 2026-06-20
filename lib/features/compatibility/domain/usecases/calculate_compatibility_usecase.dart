import 'package:fortune_fusion/core/constants/app_constants.dart';
import 'package:fortune_fusion/core/constants/reading_weights.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/seiza_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/shichu_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/entities/horoscope.dart';
import 'package:fortune_fusion/features/meishiki/domain/entities/shichu_meishiki.dart';
import 'package:fortune_fusion/features/profile/domain/entities/profile.dart';

import '../entities/compatibility_result.dart';

enum _Cat { love, work, friend }

class CalculateCompatibilityUsecase {
  const CalculateCompatibilityUsecase({
    required this.shichuEngine,
    required this.seizaEngine,
    required this.kyuseiEngine,
  });

  final ShichuEngine shichuEngine;
  final SeizaEngine seizaEngine;
  final KyuseiEngine kyuseiEngine;

  static const _stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

  static const _kangoPairs = <(String, String)>{
    ('甲', '己'), ('己', '甲'),
    ('乙', '庚'), ('庚', '乙'),
    ('丙', '辛'), ('辛', '丙'),
    ('丁', '壬'), ('壬', '丁'),
    ('戊', '癸'), ('癸', '戊'),
  };

  static const _shigoPairs = <(String, String)>{
    ('子', '丑'), ('丑', '子'),
    ('寅', '亥'), ('亥', '寅'),
    ('卯', '戌'), ('戌', '卯'),
    ('辰', '酉'), ('酉', '辰'),
    ('巳', '申'), ('申', '巳'),
    ('午', '未'), ('未', '午'),
  };

  static const _sangoFrames = [
    ['申', '子', '辰'],
    ['亥', '卯', '未'],
    ['寅', '午', '戌'],
    ['巳', '酉', '丑'],
  ];

  static const _chuPairs = <(String, String)>{
    ('子', '午'), ('午', '子'),
    ('丑', '未'), ('未', '丑'),
    ('寅', '申'), ('申', '寅'),
    ('卯', '酉'), ('酉', '卯'),
    ('辰', '戌'), ('戌', '辰'),
    ('巳', '亥'), ('亥', '巳'),
  };

  static const _keiPairs = <(String, String)>{
    ('子', '卯'), ('卯', '子'),
    ('寅', '巳'), ('巳', '申'), ('申', '寅'),
    ('丑', '戌'), ('戌', '未'), ('未', '丑'),
  };

  static const _gaiPairs = <(String, String)>{
    ('子', '未'), ('未', '子'),
    ('丑', '午'), ('午', '丑'),
    ('寅', '巳'), ('巳', '寅'),
    ('卯', '辰'), ('辰', '卯'),
    ('申', '亥'), ('亥', '申'),
    ('酉', '戌'), ('戌', '酉'),
  };

  static const _kyuseiElemMap = <int, int>{
    1: 4, 2: 2, 3: 0, 4: 0, 5: 2, 6: 3, 7: 3, 8: 2, 9: 1,
  };

  static const _compatTexts = {
    'love': {'high': '相思相愛の縁。互いの魅力を引き立て合えます。', 'mid': '程よい刺激と安らぎが交わる関係。努力次第で深まります。', 'low': '相違点が多いですが、補い合えれば成長できます。'},
    'work': {'high': '互いの強みを活かし、最高のチームワークを発揮できます。', 'mid': '役割を明確にすれば、安定したパートナーシップを築けます。', 'low': '価値観のズレを話し合いで乗り越えることが成功の鍵。'},
    'friend': {'high': '自然体でいられる大切な友人。長く続く縁。', 'mid': 'お互いを刺激し合える良き友人関係。', 'low': '距離感を大切にすることで、良好な関係を保てます。'},
  };

  CompatibilityResult call(Profile profileA, Profile profileB) {
    final isPartnerTimeUncertain = profileB.birthTime == null;

    final ma = shichuEngine.calculate(
        birthDate: profileA.birthDate, birthTime: profileA.birthTime);
    final mb = shichuEngine.calculate(
        birthDate: profileB.birthDate, birthTime: profileB.birthTime);
    final ha = seizaEngine.calculate(
      birthDate: profileA.birthDate,
      birthTime: profileA.birthTime,
      latitude: profileA.birthLat,
      longitude: profileA.birthLng,
    );
    final hb = seizaEngine.calculate(
      birthDate: profileB.birthDate,
      birthTime: profileB.birthTime,
      latitude: profileB.birthLat,
      longitude: profileB.birthLng,
    );

    final shichuScore = _shichuScore(ma, mb);
    final seizaLove = _seizaScore(ha, hb, isPartnerTimeUncertain, _Cat.love);
    final seizaWork = _seizaScore(ha, hb, isPartnerTimeUncertain, _Cat.work);
    final seizaFriend = _seizaScore(ha, hb, isPartnerTimeUncertain, _Cat.friend);
    final seizaScore = ((seizaLove + seizaWork + seizaFriend) / 3).round();

    final starA = kyuseiEngine.calcHonmeisei(profileA.birthDate);
    final starB = kyuseiEngine.calcHonmeisei(profileB.birthDate);
    final kyuseiScore = _kyuseiScore(starA.number, starB.number);

    final wL = ReadingWeights.compatibilityLove;
    final wW = ReadingWeights.compatibilityWork;
    final wF = ReadingWeights.compatibilityFriend;

    final loveScore = (shichuScore * wL.shichu + seizaLove * wL.seiza + kyuseiScore * wL.kyusei)
        .round()
        .clamp(0, 100);
    final workScore = (shichuScore * wW.shichu + seizaWork * wW.seiza + kyuseiScore * wW.kyusei)
        .round()
        .clamp(0, 100);
    final friendScore =
        (shichuScore * wF.shichu + seizaFriend * wF.seiza + kyuseiScore * wF.kyusei)
            .round()
            .clamp(0, 100);

    return CompatibilityResult(
      loveScore: loveScore,
      workScore: workScore,
      friendScore: friendScore,
      loveStars: _toStars(loveScore),
      workStars: _toStars(workScore),
      friendStars: _toStars(friendScore),
      loveComment: _comment('love', loveScore),
      workComment: _comment('work', workScore),
      friendComment: _comment('friend', friendScore),
      isPartnerTimeUncertain: isPartnerTimeUncertain,
      shichuScore: shichuScore,
      seizaScore: seizaScore,
      kyuseiScore: kyuseiScore,
    );
  }

  // ── Shichu ────────────────────────────────────────────────────────────────

  int _shichuScore(ShichuMeishiki ma, ShichuMeishiki mb) {
    final sA = ma.nicchu.stem;
    final sB = mb.nicchu.stem;
    final bA = ma.nicchu.branch;
    final bB = mb.nicchu.branch;

    final base = _wuXingSymScore(_stemToElem(sA), _stemToElem(sB));
    final kango = _kangoPairs.contains((sA, sB)) ? 15 : 0;
    final branch = _branchDelta(bA, bB);
    final tsuhen = _tsuhenBonus(sA, sB);

    return (base + kango + branch + tsuhen).clamp(0, 100);
  }

  // Symmetric WuXing score: 比和=65, 相生=75, 相剋=35
  int _wuXingSymScore(int a, int b) {
    final diff = (b - a + 5) % 5;
    final sym = diff > 2 ? 5 - diff : diff;
    return switch (sym) {
      0 => 65,
      1 => 75,
      _ => 35,
    };
  }

  int _stemToElem(String stem) => _stems.indexOf(stem) ~/ 2;

  int _stemToIdx(String stem) => _stems.indexOf(stem);

  int _branchDelta(String bA, String bB) {
    if (_shigoPairs.contains((bA, bB))) return 12;
    for (final frame in _sangoFrames) {
      if (frame.contains(bA) && frame.contains(bB)) return 10;
    }
    if (_chuPairs.contains((bA, bB))) return -15;
    if (_keiPairs.contains((bA, bB))) return -10;
    if (_gaiPairs.contains((bA, bB))) return -8;
    return 0;
  }

  int _tsuhenBonus(String stemA, String stemB) {
    final tsA = _tsuhenOf(_stemToIdx(stemA), _stemToIdx(stemB));
    final tsB = _tsuhenOf(_stemToIdx(stemB), _stemToIdx(stemA));
    int bonus = 0;
    if (tsA == TsuhenStar.seikan || tsA == TsuhenStar.seizai) bonus += 8;
    if (tsB == TsuhenStar.seikan || tsB == TsuhenStar.seizai) bonus += 8;
    return bonus;
  }

  TsuhenStar _tsuhenOf(int dayIdx, int targetIdx) {
    final dayElem = dayIdx ~/ 2;
    final dayPol = dayIdx % 2;
    final targetElem = targetIdx ~/ 2;
    final targetPol = targetIdx % 2;
    final same = dayPol == targetPol;
    if (dayElem == targetElem) return same ? TsuhenStar.hiken : TsuhenStar.kokuzai;
    if (targetElem == (dayElem + 1) % 5) return same ? TsuhenStar.shokushin : TsuhenStar.shokan;
    if (targetElem == (dayElem + 2) % 5) return same ? TsuhenStar.henzai : TsuhenStar.seizai;
    if (targetElem == (dayElem + 3) % 5) return same ? TsuhenStar.henkan : TsuhenStar.seikan;
    return same ? TsuhenStar.henin : TsuhenStar.insho;
  }

  // ── Seiza (synastry) ──────────────────────────────────────────────────────

  int _seizaScore(Horoscope ha, Horoscope hb, bool excludePartnerMoon, _Cat cat) {
    final pairs = _synastryPairs(cat, excludePartnerMoon);
    if (pairs.isEmpty) return 50;

    var totalWeighted = 0.0;
    var totalWeight = 0.0;
    for (final (pa, pb, w) in pairs) {
      final angle = _angDiff(ha, hb, pa, pb);
      totalWeighted += _aspectScore(angle, cat) * w;
      totalWeight += w;
    }
    final avg = totalWeighted / totalWeight; // range: [-5, 20]
    return ((avg + 5) / 25 * 100).round().clamp(0, 100);
  }

  double _angDiff(Horoscope ha, Horoscope hb, Planet pa, Planet pb) {
    final la = ha.planets[pa]?.longitude ?? 0.0;
    final lb = hb.planets[pb]?.longitude ?? 0.0;
    var diff = ((lb - la).abs()) % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  int _aspectScore(double angle, _Cat cat) {
    const orb = AppConstants.aspectOrb;
    if (angle <= orb) return 20;
    if ((angle - 60).abs() <= orb) return 12;
    if ((angle - 90).abs() <= orb) return -5;
    if ((angle - 120).abs() <= orb) return 18;
    if ((angle - 180).abs() <= orb) return cat == _Cat.love ? 8 : 2;
    return 0;
  }

  List<(Planet, Planet, int)> _synastryPairs(_Cat cat, bool excludePartnerMoon) {
    return switch (cat) {
      _Cat.love => [
          (Planet.venus, Planet.mars, 3),
          (Planet.mars, Planet.venus, 3),
          if (!excludePartnerMoon) ...[
            (Planet.moon, Planet.moon, 2),
            (Planet.venus, Planet.moon, 2),
            (Planet.sun, Planet.moon, 1),
            (Planet.moon, Planet.sun, 1),
          ],
          (Planet.moon, Planet.venus, 2),
          (Planet.sun, Planet.sun, 1),
          (Planet.venus, Planet.venus, 1),
        ],
      _Cat.work => [
          (Planet.sun, Planet.sun, 3),
          (Planet.sun, Planet.saturn, 2),
          (Planet.saturn, Planet.sun, 2),
          (Planet.mercury, Planet.mercury, 2),
          (Planet.sun, Planet.mars, 1),
          (Planet.mars, Planet.sun, 1),
        ],
      _Cat.friend => [
          (Planet.sun, Planet.sun, 2),
          if (!excludePartnerMoon) ...[
            (Planet.moon, Planet.moon, 2),
            (Planet.venus, Planet.moon, 1),
            (Planet.sun, Planet.moon, 1),
          ],
          (Planet.moon, Planet.venus, 1),
          (Planet.moon, Planet.sun, 1),
          (Planet.venus, Planet.venus, 2),
          (Planet.mercury, Planet.mercury, 1),
          (Planet.sun, Planet.venus, 1),
          (Planet.venus, Planet.sun, 1),
        ],
    };
  }

  // ── Kyusei ────────────────────────────────────────────────────────────────

  int _kyuseiScore(int starA, int starB) =>
      _wuXingSymScore(_kyuseiElemMap[starA]!, _kyuseiElemMap[starB]!);

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _toStars(int score) => ((score - 1) ~/ 20 + 1).clamp(1, 5);

  String _comment(String cat, int score) {
    final bucket = score >= 70 ? 'high' : score >= 40 ? 'mid' : 'low';
    return _compatTexts[cat]![bucket]!;
  }
}
