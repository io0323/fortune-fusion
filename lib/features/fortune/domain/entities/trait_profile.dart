import '../../../meishiki/domain/entities/horoscope.dart';
import '../../../meishiki/domain/entities/shichu_meishiki.dart';

enum WuXing {
  wood('木'),
  fire('火'),
  earth('土'),
  metal('金'),
  water('水');

  const WuXing(this.label);
  final String label;
}

enum WesternElement {
  fire('火'),
  earth('地'),
  air('風'),
  water('水');

  const WesternElement(this.label);
  final String label;
}

class TraitProfile {
  const TraitProfile({
    required this.wuXingScores,
    required this.elementBalance,
    required this.tsuhenCounts,
    required this.financialStrength,
    required this.authorityStrength,
    required this.venusSign,
    required this.moonSign,
    required this.mcSign,
    required this.honmeiElement,
  });

  final Map<WuXing, int> wuXingScores;
  final Map<WesternElement, int> elementBalance;
  final Map<TsuhenStar, int> tsuhenCounts;
  final int financialStrength;
  final int authorityStrength;
  final ZodiacSign? venusSign;
  final ZodiacSign moonSign;
  final ZodiacSign? mcSign;
  final String honmeiElement;

  TraitProfile copyWith({
    Map<WuXing, int>? wuXingScores,
    Map<WesternElement, int>? elementBalance,
    Map<TsuhenStar, int>? tsuhenCounts,
    int? financialStrength,
    int? authorityStrength,
    ZodiacSign? venusSign,
    ZodiacSign? moonSign,
    ZodiacSign? mcSign,
    String? honmeiElement,
  }) {
    return TraitProfile(
      wuXingScores: wuXingScores ?? this.wuXingScores,
      elementBalance: elementBalance ?? this.elementBalance,
      tsuhenCounts: tsuhenCounts ?? this.tsuhenCounts,
      financialStrength: financialStrength ?? this.financialStrength,
      authorityStrength: authorityStrength ?? this.authorityStrength,
      venusSign: venusSign ?? this.venusSign,
      moonSign: moonSign ?? this.moonSign,
      mcSign: mcSign ?? this.mcSign,
      honmeiElement: honmeiElement ?? this.honmeiElement,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraitProfile &&
          _mapsEqual(wuXingScores, other.wuXingScores) &&
          _mapsEqual(elementBalance, other.elementBalance) &&
          _mapsEqual(tsuhenCounts, other.tsuhenCounts) &&
          financialStrength == other.financialStrength &&
          authorityStrength == other.authorityStrength &&
          venusSign == other.venusSign &&
          moonSign == other.moonSign &&
          mcSign == other.mcSign &&
          honmeiElement == other.honmeiElement;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(wuXingScores.entries.map((e) => Object.hash(e.key, e.value))),
        Object.hashAll(elementBalance.entries.map((e) => Object.hash(e.key, e.value))),
        financialStrength,
        authorityStrength,
        venusSign,
        moonSign,
        mcSign,
        honmeiElement,
      );

  static bool _mapsEqual<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
