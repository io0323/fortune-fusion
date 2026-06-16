import '../entities/trait_profile.dart';
import '../../../meishiki/domain/entities/horoscope.dart';
import '../../../meishiki/domain/entities/kyusei_result.dart';
import '../../../meishiki/domain/entities/shichu_meishiki.dart';

class TraitExtractor {
  const TraitExtractor();

  static const _stemToWuXing = <String, WuXing>{
    '甲': WuXing.wood, '乙': WuXing.wood,
    '丙': WuXing.fire, '丁': WuXing.fire,
    '戊': WuXing.earth, '己': WuXing.earth,
    '庚': WuXing.metal, '辛': WuXing.metal,
    '壬': WuXing.water, '癸': WuXing.water,
  };

  static const _kyuseiElementToWuXing = <String, WuXing>{
    '木': WuXing.wood,
    '火': WuXing.fire,
    '土': WuXing.earth,
    '金': WuXing.metal,
    '水': WuXing.water,
  };

  TraitProfile extract({
    required ShichuMeishiki shichu,
    required KyuseiResult kyusei,
    required Horoscope horoscope,
  }) {
    final rawWuXing = <WuXing, double>{
      WuXing.wood: 0,
      WuXing.fire: 0,
      WuXing.earth: 0,
      WuXing.metal: 0,
      WuXing.water: 0,
    };

    final pillars = [
      shichu.nenchu,
      shichu.gecchu,
      shichu.nicchu,
      if (shichu.jichu != null) shichu.jichu!,
    ];

    for (final pillar in pillars) {
      final wx = _stemToWuXing[pillar.stem];
      if (wx != null) rawWuXing[wx] = rawWuXing[wx]! + 20;
      for (final z in pillar.zokan) {
        final zwx = _stemToWuXing[z.stem];
        if (zwx != null) rawWuXing[zwx] = rawWuXing[zwx]! + 5;
      }
    }

    final kyuseiWx = _kyuseiElementToWuXing[kyusei.honmeisei.element];
    if (kyuseiWx != null) rawWuXing[kyuseiWx] = rawWuXing[kyuseiWx]! + 30;

    final westernRaw = <WesternElement, int>{
      WesternElement.fire: 0,
      WesternElement.earth: 0,
      WesternElement.air: 0,
      WesternElement.water: 0,
    };

    void addSign(ZodiacSign? sign, int weight) {
      if (sign == null) return;
      final we = _zodiacToWesternElement(sign);
      westernRaw[we] = westernRaw[we]! + weight;
      final wx = _westernElementToWuXing(we);
      rawWuXing[wx] = rawWuXing[wx]! + weight;
    }

    addSign(horoscope.sunSign, 10);
    addSign(horoscope.moonSign, 8);
    if (!horoscope.isTimeUncertain) {
      addSign(horoscope.ascSign, 6);
      addSign(ZodiacSign.fromLongitude(horoscope.midheaven), 4);
    }
    final venusPos = horoscope.planets[Planet.venus];
    addSign(venusPos?.sign, 3);

    final totalRaw = rawWuXing.values.fold(0.0, (a, b) => a + b);
    final wuXingScores = <WuXing, int>{};
    for (final entry in rawWuXing.entries) {
      wuXingScores[entry.key] =
          totalRaw > 0 ? (entry.value / totalRaw * 100).round() : 20;
    }

    final totalWe = westernRaw.values.fold(0, (a, b) => a + b);
    final elementBalance = <WesternElement, int>{};
    for (final entry in westernRaw.entries) {
      elementBalance[entry.key] =
          totalWe > 0 ? (entry.value / totalWe * 100).round() : 25;
    }

    final tsuhenCounts = <TsuhenStar, int>{
      for (final ts in TsuhenStar.values) ts: 0,
    };
    for (final pillar in pillars) {
      if (pillar.tsuhen != null) {
        tsuhenCounts[pillar.tsuhen!] = tsuhenCounts[pillar.tsuhen!]! + 1;
      }
      for (final z in pillar.zokan) {
        tsuhenCounts[z.tsuhen] = tsuhenCounts[z.tsuhen]! + 1;
      }
    }

    final financialStrength = (tsuhenCounts[TsuhenStar.henzai] ?? 0) +
        (tsuhenCounts[TsuhenStar.seizai] ?? 0);
    final authorityStrength = (tsuhenCounts[TsuhenStar.henkan] ?? 0) +
        (tsuhenCounts[TsuhenStar.seikan] ?? 0);

    return TraitProfile(
      wuXingScores: wuXingScores,
      elementBalance: elementBalance,
      tsuhenCounts: tsuhenCounts,
      financialStrength: financialStrength,
      authorityStrength: authorityStrength,
      venusSign: venusPos?.sign,
      moonSign: horoscope.moonSign,
      mcSign: horoscope.isTimeUncertain
          ? null
          : ZodiacSign.fromLongitude(horoscope.midheaven),
      honmeiElement: kyusei.honmeisei.element,
    );
  }

  WesternElement _zodiacToWesternElement(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries:
      case ZodiacSign.leo:
      case ZodiacSign.sagittarius:
        return WesternElement.fire;
      case ZodiacSign.taurus:
      case ZodiacSign.virgo:
      case ZodiacSign.capricorn:
        return WesternElement.earth;
      case ZodiacSign.gemini:
      case ZodiacSign.libra:
      case ZodiacSign.aquarius:
        return WesternElement.air;
      case ZodiacSign.cancer:
      case ZodiacSign.scorpio:
      case ZodiacSign.pisces:
        return WesternElement.water;
    }
  }

  WuXing _westernElementToWuXing(WesternElement we) {
    switch (we) {
      case WesternElement.fire:
        return WuXing.fire;
      case WesternElement.earth:
        return WuXing.earth;
      case WesternElement.air:
        return WuXing.metal;
      case WesternElement.water:
        return WuXing.water;
    }
  }
}
