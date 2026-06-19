import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_board_calculator.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_engine.dart';
import 'package:fortune_fusion/features/profile/domain/entities/profile.dart';

import '../entities/direction_result.dart';

class CalculateDirectionUsecase {
  const CalculateDirectionUsecase({
    required this.kyuseiEngine,
    required this.boardCalculator,
  });

  final KyuseiEngine kyuseiEngine;
  final KyuseiBoardCalculator boardCalculator;

  // WuXing generation: 木生火→火生土→土生金→金生水→水生木
  // Star elements: 1水,2土,3木,4木,5土,6金,7金,8土,9火
  static const _generators = <int, int>{
    1: 6, // 水←金(六白)
    2: 9, // 土←火(九紫)
    3: 1, // 木←水(一白)
    4: 1, // 木←水(一白)
    5: 9, // 土←火(九紫)
    6: 2, // 金←土(二黒)
    7: 2, // 金←土(二黒)
    8: 9, // 土←火(九紫)
    9: 3, // 火←木(三碧)
  };

  DirectionResult call(Profile profile, DateTime targetDate) {
    final honmei = kyuseiEngine.calcHonmeisei(profile.birthDate);
    final dayBoard = boardCalculator.calculateBoard(KyuseiBoardType.day, targetDate);

    final luckyDirs = <String>[];
    final unluckyDirs = <String>[];

    final honmeiDir = boardCalculator.directionOf(honmei.number, dayBoard);
    if (honmeiDir != null) luckyDirs.add(honmeiDir);

    final generatorStar = _generators[honmei.number];
    if (generatorStar != null) {
      final genDir = boardCalculator.directionOf(generatorStar, dayBoard);
      if (genDir != null && !luckyDirs.contains(genDir)) luckyDirs.add(genDir);
    }

    final gokoDir = boardCalculator.directionOf(5, dayBoard);
    if (gokoDir != null) unluckyDirs.add(gokoDir);

    final ankensatsuDir = boardCalculator.oppositeDirectionOf(5, dayBoard);
    if (ankensatsuDir != null && !unluckyDirs.contains(ankensatsuDir)) {
      unluckyDirs.add(ankensatsuDir);
    }

    return DirectionResult(
      profileId: profile.id,
      targetDate: targetDate,
      luckyDirections: luckyDirs,
      unluckyDirections: unluckyDirs,
      description: _buildDescription(luckyDirs, unluckyDirs),
    );
  }

  String _buildDescription(List<String> lucky, List<String> unlucky) {
    final buf = StringBuffer();
    if (lucky.isNotEmpty) buf.write('吉方位: ${lucky.join('・')}');
    if (unlucky.isNotEmpty) {
      if (buf.isNotEmpty) buf.write(' / ');
      buf.write('凶方位: ${unlucky.join('・')}');
    }
    return buf.toString();
  }
}
