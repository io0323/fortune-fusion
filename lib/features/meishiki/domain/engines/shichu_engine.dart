import '../entities/shichu_meishiki.dart';
import 'setsuiri_data.dart';

class ShichuEngine {
  ShichuEngine({required this.setsuiriData});

  final SetsuiriData setsuiriData;

  // 23:xx（夜子時）は翌日ではなく当日の日干を使用する
  static const bool nightZiIsCurrentDay = true;

  static const _stems = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'
  ];

  static const _branches = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'
  ];

  // 蔵干テーブル: index=支インデックス(子=0..亥=11)
  // 各エントリ = [(干, 種類)] ※ Dart 3 records
  static const _zokan = [
    [('壬', '余気'), ('癸', '本気')],                      // 子
    [('癸', '余気'), ('辛', '中気'), ('己', '本気')],       // 丑
    [('戊', '余気'), ('丙', '中気'), ('甲', '本気')],       // 寅
    [('甲', '余気'), ('乙', '本気')],                      // 卯
    [('乙', '余気'), ('癸', '中気'), ('戊', '本気')],       // 辰
    [('戊', '余気'), ('庚', '中気'), ('丙', '本気')],       // 巳
    [('丙', '余気'), ('己', '中気'), ('丁', '本気')],       // 午
    [('丁', '余気'), ('乙', '中気'), ('己', '本気')],       // 未
    [('戊', '余気'), ('壬', '中気'), ('庚', '本気')],       // 申
    [('庚', '余気'), ('辛', '本気')],                      // 酉
    [('辛', '余気'), ('丁', '中気'), ('戊', '本気')],       // 戌
    [('甲', '余気'), ('壬', '本気')],                      // 亥
  ];

  // 十二運の長生起点ブランチインデックス (干インデックス 0-9)
  // 陽干(偶数index)は順行、陰干(奇数index)は逆行
  //    甲  乙  丙  丁  戊  己  庚  辛  壬  癸
  static const _juniUnStart = [11, 6, 2, 9, 2, 9, 5, 0, 8, 3];

  // 五虎遁: 年干インデックス%5 → 寅月(節月=1)の月干インデックス
  // 甲己→丙(2), 乙庚→戊(4), 丙辛→庚(6), 丁壬→壬(8), 戊癸→甲(0)
  static const _gokotonBase = [2, 4, 6, 8, 0];

  // 五鼠遁: 日干インデックス%5 → 子時(時支=0)の時干インデックス
  // 甲己→甲(0), 乙庚→丙(2), 丙辛→戊(4), 丁壬→庚(6), 戊癸→壬(8)
  static const _goratonBase = [0, 2, 4, 6, 8];

  ShichuMeishiki calculate({
    required DateTime birthDate,
    DateTime? birthTime,
  }) {
    // --- 年柱 ---
    final kyuseiYear = _getKyuseiYear(birthDate);
    final yearIdx = ((kyuseiYear - 4) % 60 + 60) % 60;
    final yearStemIdx = yearIdx % 10;
    final yearBranchIdx = yearIdx % 12;

    // --- 月柱 ---
    final setsuMonth = _getSetsuMonth(birthDate, kyuseiYear);
    final monthBranchIdx = (setsuMonth + 1) % 12; // 1→寅(2), 12→丑(1)
    final monthStemIdx = (_gokotonBase[yearStemIdx % 5] + setsuMonth - 1) % 10;

    // --- 日柱 ---
    final dayBase = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final ref = DateTime(1900, 1, 1);
    final days = dayBase.difference(ref).inDays;
    final dayIdx60 = ((10 + days) % 60 + 60) % 60;
    final dayStemIdx = dayIdx60 % 10;
    final dayBranchIdx = dayIdx60 % 12;

    final nenchu = _buildPillar(yearStemIdx, yearBranchIdx, dayStemIdx, false);
    final gecchu = _buildPillar(monthStemIdx, monthBranchIdx, dayStemIdx, false);
    final nicchu = _buildPillar(dayStemIdx, dayBranchIdx, dayStemIdx, true);

    // --- 時柱 ---
    Pillar? jichu;
    if (birthTime != null) {
      final hourBranchIdx = _hourBranchIndex(birthTime.hour);
      final hourStemIdx = (_goratonBase[dayStemIdx % 5] + hourBranchIdx) % 10;
      jichu = _buildPillar(hourStemIdx, hourBranchIdx, dayStemIdx, false);
    }

    return ShichuMeishiki(
      nenchu: nenchu,
      gecchu: gecchu,
      nicchu: nicchu,
      jichu: jichu,
    );
  }

  // 通変星 (公開メソッド)
  TsuhenStar calcTsuhenStar(int dayStemIdx, int targetStemIdx) =>
      _calcTsuhen(dayStemIdx, targetStemIdx);

  // 時支インデックス: 23→0(子), 0→0(子), 1→1(丑), 3→2(寅), ...
  int _hourBranchIndex(int hour) => (hour + 1) ~/ 2 % 12;

  Pillar _buildPillar(int stemIdx, int branchIdx, int dayStemIdx, bool isDay) {
    return Pillar(
      stem: _stems[stemIdx],
      branch: _branches[branchIdx],
      tsuhen: isDay ? null : _calcTsuhen(dayStemIdx, stemIdx),
      juniun: _calcJuniUn(dayStemIdx, branchIdx),
      zokan: _buildZokan(branchIdx, dayStemIdx),
    );
  }

  TsuhenStar _calcTsuhen(int dayStemIdx, int targetStemIdx) {
    final dayElem = dayStemIdx ~/ 2; // 0=木,1=火,2=土,3=金,4=水
    final dayPol = dayStemIdx % 2; // 0=陽,1=陰
    final targetElem = targetStemIdx ~/ 2;
    final targetPol = targetStemIdx % 2;
    final same = dayPol == targetPol;

    if (dayElem == targetElem) {
      return same ? TsuhenStar.hiken : TsuhenStar.kokuzai;
    }
    if (targetElem == (dayElem + 1) % 5) {
      return same ? TsuhenStar.shokushin : TsuhenStar.shokan;
    }
    if (targetElem == (dayElem + 2) % 5) {
      return same ? TsuhenStar.henzai : TsuhenStar.seizai;
    }
    if (targetElem == (dayElem + 3) % 5) {
      return same ? TsuhenStar.henkan : TsuhenStar.seikan;
    }
    // (dayElem+4)%5: target generates day
    return same ? TsuhenStar.henin : TsuhenStar.insho;
  }

  JuniUn _calcJuniUn(int dayStemIdx, int branchIdx) {
    final start = _juniUnStart[dayStemIdx];
    final isYang = dayStemIdx % 2 == 0;
    final idx = isYang
        ? (branchIdx - start + 12) % 12
        : (start - branchIdx + 12) % 12;
    return JuniUn.values[idx];
  }

  List<ZokanEntry> _buildZokan(int branchIdx, int dayStemIdx) {
    return _zokan[branchIdx].map((e) {
      final zokanStemIdx = _stems.indexOf(e.$1);
      return ZokanEntry(
        stem: e.$1,
        type: e.$2,
        tsuhen: _calcTsuhen(dayStemIdx, zokanStemIdx),
      );
    }).toList();
  }

  // 九星年（立春で切り替わる）
  int _getKyuseiYear(DateTime date) {
    final risshun = setsuiriData.getRisshun(date.year);
    return date.isBefore(risshun) ? date.year - 1 : date.year;
  }

  // 節月（1=寅月/立春 … 12=丑月/小寒）
  int _getSetsuMonth(DateTime birthDate, int kyuseiYear) {
    for (int i = 11; i >= 0; i--) {
      final setsuDate = setsuiriData.getSetsuDate(kyuseiYear, i);
      if (!birthDate.isBefore(setsuDate)) return i + 1;
    }
    return 1;
  }
}
