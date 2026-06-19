import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/seiza_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/shichu_engine.dart';
import 'package:fortune_fusion/features/profile/domain/entities/profile.dart';

import '../entities/compatibility_result.dart';

class CalculateCompatibilityUsecase {
  const CalculateCompatibilityUsecase({
    required this.shichuEngine,
    required this.seizaEngine,
    required this.kyuseiEngine,
  });

  final ShichuEngine shichuEngine;
  final SeizaEngine seizaEngine;
  final KyuseiEngine kyuseiEngine;

  CompatibilityResult call(Profile profileA, Profile profileB) {
    final shichuScore = _shichuScore(profileA, profileB);
    final seizaScore = _seizaScore(profileA, profileB);
    final kyuseiScore = _kyuseiScore(profileA, profileB);
    final score =
        (shichuScore * 0.4 + seizaScore * 0.3 + kyuseiScore * 0.3).round().clamp(0, 100);
    return CompatibilityResult(
      profileAId: profileA.id,
      profileBId: profileB.id,
      score: score,
      description: _description(score),
      shichuScore: shichuScore,
      seizaScore: seizaScore,
      kyuseiScore: kyuseiScore,
    );
  }

  int _shichuScore(Profile a, Profile b) {
    final ma = shichuEngine.calculate(birthDate: a.birthDate, birthTime: a.birthTime);
    final mb = shichuEngine.calculate(birthDate: b.birthDate, birthTime: b.birthTime);
    return _wuXingScore(_stemToElement(ma.nicchu.stem), _stemToElement(mb.nicchu.stem));
  }

  int _seizaScore(Profile a, Profile b) {
    final ha = seizaEngine.calculate(
      birthDate: a.birthDate,
      birthTime: null,
      latitude: 0.0,
      longitude: 0.0,
    );
    final hb = seizaEngine.calculate(
      birthDate: b.birthDate,
      birthTime: null,
      latitude: 0.0,
      longitude: 0.0,
    );
    return _westernElementScore(ha.sunSign.index % 4, hb.sunSign.index % 4);
  }

  int _kyuseiScore(Profile a, Profile b) {
    final starA = kyuseiEngine.calcHonmeisei(a.birthDate);
    final starB = kyuseiEngine.calcHonmeisei(b.birthDate);
    return _wuXingScore(_kyuseiToElement(starA.number), _kyuseiToElement(starB.number));
  }

  // WuXing element index: 0=木, 1=火, 2=土, 3=金, 4=水
  // 相生: a→b(diff=1): 80, b→a(diff=4): 75, 比和(diff=0): 65, b克a(diff=3): 40, a克b(diff=2): 30
  int _wuXingScore(int a, int b) {
    final diff = (b - a + 5) % 5;
    return switch (diff) {
      0 => 65,
      1 => 80,
      4 => 75,
      2 => 30,
      3 => 40,
      _ => 50,
    };
  }

  // Western element index: 0=火, 1=地, 2=風, 3=水
  // Trine(same or fire-air or earth-water): high, Square: mid, Opposition(fire-water or earth-air): low
  int _westernElementScore(int a, int b) {
    if (a == b) return 80;
    if ((a == 0 && b == 2) || (a == 2 && b == 0)) return 72;
    if ((a == 1 && b == 3) || (a == 3 && b == 1)) return 72;
    if ((a == 0 && b == 3) || (a == 3 && b == 0)) return 30;
    if ((a == 1 && b == 2) || (a == 2 && b == 1)) return 30;
    return 50;
  }

  // Stems: 甲乙=木, 丙丁=火, 戊己=土, 庚辛=金, 壬癸=水
  int _stemToElement(String stem) {
    const stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    return stems.indexOf(stem) ~/ 2;
  }

  // Stars: 1水, 2土, 3木, 4木, 5土, 6金, 7金, 8土, 9火
  int _kyuseiToElement(int starNumber) {
    const map = <int, int>{1: 4, 2: 2, 3: 0, 4: 0, 5: 2, 6: 3, 7: 3, 8: 2, 9: 1};
    return map[starNumber]!;
  }

  String _description(int score) {
    if (score >= 80) return '非常に相性が良い';
    if (score >= 65) return '相性が良い';
    if (score >= 50) return '普通';
    if (score >= 35) return 'やや相性が難しい';
    return '相性が難しい';
  }
}
