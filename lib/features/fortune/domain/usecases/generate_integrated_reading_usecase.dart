import '../entities/integrated_reading.dart';
import '../entities/trait_profile.dart';
import '../services/reading_text_loader.dart';
import '../../../../core/constants/reading_weights.dart';
import '../../../meishiki/domain/entities/horoscope.dart';
import '../../../meishiki/domain/entities/shichu_meishiki.dart';

class GenerateIntegratedReadingUsecase {
  const GenerateIntegratedReadingUsecase(this._loader);

  final ReadingTextLoader _loader;

  Future<IntegratedReading> call(TraitProfile profile, int profileId) async {
    final texts = await _loader.loadReadingTexts();
    return IntegratedReading(
      profileId: profileId,
      generatedAt: DateTime.now(),
      personality: _lookup(texts, 'personality', _personalityBucket(profile)),
      aptitude: _lookup(texts, 'aptitude', _aptitudeBucket(profile)),
      love: _lookup(texts, 'love', _loveBucket(profile)),
      money: _lookup(texts, 'money', _moneyBucket(profile)),
      health: _lookup(texts, 'health', _healthBucket(profile)),
    );
  }

  List<String> _lookup(
      Map<String, dynamic> texts, String category, String bucket) {
    final cat = texts[category] as Map<String, dynamic>?;
    final list = cat?[bucket] as List<dynamic>?;
    return list?.cast<String>() ?? const [];
  }

  String _personalityBucket(TraitProfile p) {
    return '${_dominantWuXing(p.wuXingScores).name}_dominant';
  }

  String _aptitudeBucket(TraitProfile p) {
    final t = p.tsuhenCounts;
    final scores = <String, double>{
      'independent':
          ((t[TsuhenStar.hiken] ?? 0) + (t[TsuhenStar.kokuzai] ?? 0))
              .toDouble(),
      'creator':
          ((t[TsuhenStar.shokushin] ?? 0) + (t[TsuhenStar.shokan] ?? 0))
              .toDouble(),
      'wealth_seeker': p.financialStrength.toDouble(),
      'manager': p.authorityStrength.toDouble(),
      'intellectual':
          ((t[TsuhenStar.henin] ?? 0) + (t[TsuhenStar.insho] ?? 0))
              .toDouble(),
    };

    if (p.mcSign != null) {
      final type = _wuXingToAptitude(_zodiacToWuXing(p.mcSign!));
      scores[type] = (scores[type] ?? 0) + ReadingWeights.aptitude.seiza * 10;
    }

    final kyuseiWx = _honmeiToWuXing[p.honmeiElement];
    if (kyuseiWx != null) {
      final type = _wuXingToAptitude(kyuseiWx);
      scores[type] = (scores[type] ?? 0) + ReadingWeights.aptitude.kyusei * 10;
    }

    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _loveBucket(TraitProfile p) {
    final scores = <String, double>{
      'passionate': 0,
      'steady': 0,
      'intellectual': 0,
      'sensitive': 0,
    };

    if (p.venusSign != null) {
      final bucket = _westernElementToLove(_zodiacToWesternElement(p.venusSign!));
      scores[bucket] = scores[bucket]! + ReadingWeights.love.seiza * 10;
    }
    final moonBucket =
        _westernElementToLove(_zodiacToWesternElement(p.moonSign));
    scores[moonBucket] = scores[moonBucket]! + ReadingWeights.love.seiza * 6;

    final dominantWxBucket = _wuXingToLove(_dominantWuXing(p.wuXingScores));
    scores[dominantWxBucket] =
        scores[dominantWxBucket]! + ReadingWeights.love.shichu * 10;

    final kyuseiWx = _honmeiToWuXing[p.honmeiElement];
    if (kyuseiWx != null) {
      final bucket = _wuXingToLove(kyuseiWx);
      scores[bucket] = scores[bucket]! + ReadingWeights.love.kyusei * 10;
    }

    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _moneyBucket(TraitProfile p) {
    double score = p.financialStrength * ReadingWeights.money.shichu * 2;

    final earthPct = p.elementBalance[WesternElement.earth] ?? 0;
    score += (earthPct / 100.0) * 10 * ReadingWeights.money.seiza;

    if (p.honmeiElement == '土' || p.honmeiElement == '金') {
      score += ReadingWeights.money.kyusei * 5;
    }

    if (score >= 4.0) return 'high_financial';
    if (score >= 1.5) return 'moderate_financial';
    return 'low_financial';
  }

  String _healthBucket(TraitProfile p) {
    final adjusted = <WuXing, double>{
      for (final e in WuXing.values) e: (p.wuXingScores[e] ?? 0).toDouble(),
    };

    final kyuseiWx = _honmeiToWuXing[p.honmeiElement];
    if (kyuseiWx != null) {
      adjusted[kyuseiWx] =
          adjusted[kyuseiWx]! + ReadingWeights.health.kyusei * 20;
    }

    final maxEntry =
        adjusted.entries.reduce((a, b) => a.value >= b.value ? a : b);
    const excessThreshold = 28.0;
    if (maxEntry.value > excessThreshold) {
      return '${maxEntry.key.name}_excess';
    }
    return 'balanced';
  }

  WuXing _dominantWuXing(Map<WuXing, int> scores) =>
      scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  static const _honmeiToWuXing = <String, WuXing>{
    '木': WuXing.wood,
    '火': WuXing.fire,
    '土': WuXing.earth,
    '金': WuXing.metal,
    '水': WuXing.water,
  };

  WuXing _zodiacToWuXing(ZodiacSign sign) =>
      _westernElementToWuXing(_zodiacToWesternElement(sign));

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

  String _wuXingToAptitude(WuXing wx) {
    switch (wx) {
      case WuXing.wood:
        return 'independent';
      case WuXing.fire:
        return 'creator';
      case WuXing.earth:
        return 'wealth_seeker';
      case WuXing.metal:
        return 'manager';
      case WuXing.water:
        return 'intellectual';
    }
  }

  String _westernElementToLove(WesternElement we) {
    switch (we) {
      case WesternElement.fire:
        return 'passionate';
      case WesternElement.earth:
        return 'steady';
      case WesternElement.air:
        return 'intellectual';
      case WesternElement.water:
        return 'sensitive';
    }
  }

  String _wuXingToLove(WuXing wx) {
    switch (wx) {
      case WuXing.wood:
        return 'passionate';
      case WuXing.fire:
        return 'passionate';
      case WuXing.earth:
        return 'steady';
      case WuXing.metal:
        return 'intellectual';
      case WuXing.water:
        return 'sensitive';
    }
  }
}
