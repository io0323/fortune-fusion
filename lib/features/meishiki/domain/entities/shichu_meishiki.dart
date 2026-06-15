typedef Stem = String;
typedef Branch = String;

enum TsuhenStar {
  hiken('比肩'),
  kokuzai('劫財'),
  shokushin('食神'),
  shokan('傷官'),
  henzai('偏財'),
  seizai('正財'),
  henkan('偏官'),
  seikan('正官'),
  henin('偏印'),
  insho('印綬');

  const TsuhenStar(this.label);
  final String label;
}

enum JuniUn {
  choisei('長生'),
  mokuyo('沐浴'),
  kanta('冠帯'),
  kenroku('建禄'),
  teiou('帝旺'),
  sui('衰'),
  byo('病'),
  shi('死'),
  bo('墓'),
  zetsu('絶'),
  tai('胎'),
  yo('養');

  const JuniUn(this.label);
  final String label;
}

class ZokanEntry {
  const ZokanEntry({
    required this.stem,
    required this.type,
    required this.tsuhen,
  });

  final Stem stem;
  final String type; // '本気', '中気', '余気'
  final TsuhenStar tsuhen;
}

class Pillar {
  const Pillar({
    required this.stem,
    required this.branch,
    this.tsuhen,
    required this.juniun,
    required this.zokan,
  });

  final Stem stem;
  final Branch branch;
  final TsuhenStar? tsuhen; // null for 日柱(日主)
  final JuniUn juniun;
  final List<ZokanEntry> zokan;

  @override
  bool operator ==(Object other) =>
      other is Pillar && stem == other.stem && branch == other.branch;

  @override
  int get hashCode => Object.hash(stem, branch);
}

class ShichuMeishiki {
  const ShichuMeishiki({
    required this.nenchu,
    required this.gecchu,
    required this.nicchu,
    this.jichu,
  });

  final Pillar nenchu; // 年柱
  final Pillar gecchu; // 月柱
  final Pillar nicchu; // 日柱
  final Pillar? jichu; // 時柱（null=出生時刻不明）

  ShichuMeishiki copyWith({
    Pillar? nenchu,
    Pillar? gecchu,
    Pillar? nicchu,
    Pillar? jichu,
  }) {
    return ShichuMeishiki(
      nenchu: nenchu ?? this.nenchu,
      gecchu: gecchu ?? this.gecchu,
      nicchu: nicchu ?? this.nicchu,
      jichu: jichu ?? this.jichu,
    );
  }
}
