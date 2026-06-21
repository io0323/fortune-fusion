import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_board_calculator.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/entities/kyusei_result.dart';
import 'package:fortune_fusion/features/profile/domain/entities/profile.dart';

import '../entities/direction_result.dart';

class CalculateDirectionUsecase {
  const CalculateDirectionUsecase({
    required this.kyuseiEngine,
    required this.boardCalculator,
  });

  final KyuseiEngine kyuseiEngine;
  final KyuseiBoardCalculator boardCalculator;

  // 五行要素: 0=木, 1=火, 2=土, 3=金, 4=水
  static const _starElem = <int, int>{
    1: 4, 2: 2, 3: 0, 4: 0, 5: 2, 6: 3, 7: 3, 8: 2, 9: 1,
  };

  // 十二支インデックス(0=子..11=亥) → 後天定位盤上の位置
  static const _branchToPos = <int, int>{
    0: 1,  // 子 → 北(pos1)
    1: 8,  // 丑 → 北東(pos8)
    2: 8,  // 寅 → 北東(pos8)
    3: 3,  // 卯 → 東(pos3)
    4: 4,  // 辰 → 東南(pos4)
    5: 4,  // 巳 → 東南(pos4)
    6: 9,  // 午 → 南(pos9)
    7: 2,  // 未 → 南西(pos2)
    8: 2,  // 申 → 南西(pos2)
    9: 7,  // 酉 → 西(pos7)
    10: 6, // 戌 → 北西(pos6)
    11: 6, // 亥 → 北西(pos6)
  };

  static const _oppositePos = <int, int>{
    1: 9, 9: 1, 2: 8, 8: 2, 3: 7, 7: 3, 4: 6, 6: 4,
  };

  static const _posToDirection = <int, String>{
    1: '北', 2: '南西', 3: '東', 4: '東南',
    6: '北西', 7: '西', 8: '北東', 9: '南',
  };

  DirectionResult call(
    Profile profile,
    DateTime targetDate, {
    KyuseiBoardType boardType = KyuseiBoardType.month,
  }) {
    final kyuseiResult = kyuseiEngine.calculate(birthDate: profile.birthDate);
    final honmei = kyuseiResult.honmeisei;
    final getsumei = kyuseiResult.getsumeisei;
    final board = boardCalculator.calculateBoard(boardType, targetDate);

    final unluckyMap = <String, String>{}; // direction → reason

    // 五黄殺 (大凶)
    final gokoDir = boardCalculator.directionOf(5, board);
    if (gokoDir != null) unluckyMap[gokoDir] = '五黄殺';

    // 暗剣殺 = 五黄殺の反対 (大凶)
    final ankensatsuDir = boardCalculator.oppositeDirectionOf(5, board);
    if (ankensatsuDir != null) unluckyMap.putIfAbsent(ankensatsuDir, () => '暗剣殺');

    // 本命殺 (凶)
    final honmeiSatsuDir = boardCalculator.directionOf(honmei.number, board);
    if (honmeiSatsuDir != null) unluckyMap.putIfAbsent(honmeiSatsuDir, () => '本命殺');

    // 本命的殺 = 本命殺の反対 (凶)
    final honmeiTekisatsuDir = boardCalculator.oppositeDirectionOf(honmei.number, board);
    if (honmeiTekisatsuDir != null) unluckyMap.putIfAbsent(honmeiTekisatsuDir, () => '本命的殺');

    // 月命殺 (凶)
    final getsumeiSatsuDir = boardCalculator.directionOf(getsumei.number, board);
    if (getsumeiSatsuDir != null) unluckyMap.putIfAbsent(getsumeiSatsuDir, () => '月命殺');

    // 月命的殺 = 月命殺の反対 (凶)
    final getsumeiTekisatsuDir = boardCalculator.oppositeDirectionOf(getsumei.number, board);
    if (getsumeiTekisatsuDir != null) unluckyMap.putIfAbsent(getsumeiTekisatsuDir, () => '月命的殺');

    // 歳破 (年盤) / 月破 (月盤・日盤)
    final haDir = _haDirection(boardType, targetDate);
    if (haDir != null) unluckyMap.putIfAbsent(haDir, () => boardType == KyuseiBoardType.year ? '歳破' : '月破');

    final directions = _posToDirection.entries.map((e) {
      final pos = e.key;
      final dir = e.value;
      if (unluckyMap.containsKey(dir)) {
        final isGrave = unluckyMap[dir] == '五黄殺' || unluckyMap[dir] == '暗剣殺';
        return DirectionInfo(
          direction: dir,
          rank: isGrave ? DirectionRank.daikyo : DirectionRank.kyo,
          reason: unluckyMap[dir]!,
        );
      }
      final star = board[pos]!;
      final rank = _luckyRank(star, honmei, getsumei);
      return DirectionInfo(
        direction: dir,
        rank: rank,
        reason: _luckyReason(rank, star),
      );
    }).toList();

    return DirectionResult(
      profileId: profile.id,
      targetDate: targetDate,
      boardType: boardType,
      directions: directions,
    );
  }

  String? _haDirection(KyuseiBoardType boardType, DateTime targetDate) {
    final int branchIdx;
    if (boardType == KyuseiBoardType.year) {
      final ky = boardCalculator.kyuseiYearOf(targetDate);
      branchIdx = (ky - 4 % 12 + 1200) % 12;
    } else {
      final setsuMonth = boardCalculator.setsuMonthOf(targetDate);
      // 節月1=寅(2), 2=卯(3), ..., 11=子(0), 12=丑(1)
      branchIdx = (setsuMonth + 1) % 12;
    }
    final pos = _branchToPos[branchIdx];
    if (pos == null) return null;
    final oppPos = _oppositePos[pos];
    if (oppPos == null) return null;
    return _posToDirection[oppPos];
  }

  DirectionRank _luckyRank(KyuseiStar star, KyuseiStar honmei, KyuseiStar getsumei) {
    final withHonmei = _isSosei(star.number, honmei.number);
    final withGetsumei = _isSosei(star.number, getsumei.number);
    if (withHonmei && withGetsumei) return DirectionRank.daikichi;
    if (withHonmei || withGetsumei) return DirectionRank.kichi;
    return DirectionRank.chuyou;
  }

  bool _isSosei(int starA, int starB) {
    final eA = _starElem[starA]!;
    final eB = _starElem[starB]!;
    return (eA + 1) % 5 == eB || (eB + 1) % 5 == eA;
  }

  String _luckyReason(DirectionRank rank, KyuseiStar star) {
    return switch (rank) {
      DirectionRank.daikichi => '${star.label}・相生（大吉）',
      DirectionRank.kichi => '${star.label}・相生',
      _ => star.label,
    };
  }
}
