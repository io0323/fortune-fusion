import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_board_calculator.dart';

enum DirectionRank { daikichi, kichi, chuyou, kyo, daikyo }

class DirectionInfo {
  const DirectionInfo({
    required this.direction,
    required this.rank,
    required this.reason,
  });

  final String direction;
  final DirectionRank rank;
  final String reason;

  @override
  bool operator ==(Object other) =>
      other is DirectionInfo &&
      direction == other.direction &&
      rank == other.rank &&
      reason == other.reason;

  @override
  int get hashCode => Object.hash(direction, rank, reason);
}

class DirectionResult {
  const DirectionResult({
    required this.profileId,
    required this.targetDate,
    required this.boardType,
    required this.directions,
  });

  final int profileId;
  final DateTime targetDate;
  final KyuseiBoardType boardType;

  /// 8方位すべてのDirectionInfo（中宮は含まない）
  final List<DirectionInfo> directions;

  List<DirectionInfo> get lucky => directions
      .where((d) => d.rank == DirectionRank.daikichi || d.rank == DirectionRank.kichi)
      .toList();

  List<DirectionInfo> get unlucky => directions
      .where((d) => d.rank == DirectionRank.daikyo || d.rank == DirectionRank.kyo)
      .toList();

  DirectionResult copyWith({
    int? profileId,
    DateTime? targetDate,
    KyuseiBoardType? boardType,
    List<DirectionInfo>? directions,
  }) {
    return DirectionResult(
      profileId: profileId ?? this.profileId,
      targetDate: targetDate ?? this.targetDate,
      boardType: boardType ?? this.boardType,
      directions: directions ?? this.directions,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DirectionResult &&
      profileId == other.profileId &&
      targetDate == other.targetDate &&
      boardType == other.boardType &&
      _listEq(directions, other.directions);

  @override
  int get hashCode => Object.hash(
        profileId,
        targetDate,
        boardType,
        Object.hashAll(directions),
      );

  static bool _listEq(List<DirectionInfo> a, List<DirectionInfo> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
