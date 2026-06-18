import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../../../shared/database/app_database.dart' hide Profile;
import '../../../meishiki/domain/engines/kyusei_engine.dart';
import '../../../meishiki/domain/engines/seiza_engine.dart';
import '../../../meishiki/domain/engines/shichu_engine.dart';
import '../../../meishiki/domain/entities/horoscope.dart';
import '../../../meishiki/domain/entities/kyusei_result.dart';
import '../../../meishiki/domain/entities/shichu_meishiki.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/daily_fortune.dart';
import '../../domain/entities/fortune_result.dart';
import '../../domain/entities/integrated_reading.dart';
import '../../domain/repositories/fortune_repository.dart';
import '../../domain/services/fortune_scorer.dart';

class FortuneRepositoryImpl implements FortuneRepository {
  const FortuneRepositoryImpl({
    required this.db,
    required this.shichuEngine,
    required this.seizaEngine,
    required this.kyuseiEngine,
  });

  final AppDatabase db;
  final ShichuEngine shichuEngine;
  final SeizaEngine seizaEngine;
  final KyuseiEngine kyuseiEngine;

  static const _stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

  // 五行 → ラッキーカラー
  static const _wuXingColors = ['緑', '赤', '黄', '白', '黒'];

  static const _cautionTexts = {
    'work': '仕事上のミスに注意。確認作業を怠らずに。',
    'money': '金銭面での衝動買いは控えめに。',
    'love': '今日は恋愛面で慎重に。感情的な判断は避けましょう。',
    'health': '体調管理に気を配り、無理をしないよう心がけましょう。',
  };

  // ---------- パブリックインターフェース ----------

  @override
  Future<DailyFortune> getDailyFortune(int profileId, DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    final cached = await _getFromCache(profileId, 'daily', targetDate);
    if (cached != null) {
      return DailyFortune(date: targetDate, result: _decodeResult(cached));
    }
    final profile = await _getProfile(profileId);
    final natal = _buildNatal(profile);
    final result = _computeDaily(natal, targetDate);
    await _saveToCache(profileId, 'daily', targetDate, _encodeResult(result));
    return DailyFortune(date: targetDate, result: result);
  }

  @override
  Future<List<FortuneResult>> getMonthlyFortune(
      int profileId, int year, int month) async {
    final cacheDate = DateTime(year, month, 1);
    final cached = await _getFromCache(profileId, 'monthly', cacheDate);
    if (cached != null) {
      return (jsonDecode(cached) as List)
          .map((e) => _decodeResultMap(e as Map<String, dynamic>))
          .toList();
    }
    final profile = await _getProfile(profileId);
    final natal = _buildNatal(profile);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final results = List.generate(
      daysInMonth,
      (i) => _computeDaily(natal, DateTime(year, month, i + 1)),
    );
    await _saveToCache(
      profileId,
      'monthly',
      cacheDate,
      jsonEncode(results.map(_encodeResultMap).toList()),
    );
    return results;
  }

  @override
  Future<List<FortuneResult>> getYearlyFortune(int profileId, int year) async {
    final cacheDate = DateTime(year, 1, 1);
    final cached = await _getFromCache(profileId, 'yearly', cacheDate);
    if (cached != null) {
      return (jsonDecode(cached) as List)
          .map((e) => _decodeResultMap(e as Map<String, dynamic>))
          .toList();
    }
    final profile = await _getProfile(profileId);
    final natal = _buildNatal(profile);
    final sd = kyuseiEngine.setsuiriData;

    final monthly = <FortuneResult>[];
    for (int i = 0; i < 12; i++) {
      final start = sd.getSetsuDate(year, i);
      final end = i < 11 ? sd.getSetsuDate(year, i + 1) : sd.getSetsuDate(year + 1, 0);
      monthly.add(_computeMonthAvg(natal, start, end));
    }

    // チャンス月・注意月を advice に付加
    final overalls = monthly.map((r) => r.overall).toList();
    final maxVal = overalls.reduce(math.max);
    final minVal = overalls.reduce(math.min);
    final maxIdx = overalls.indexOf(maxVal);
    final minIdx = overalls.indexOf(minVal);

    final results = List.generate(12, (i) {
      final r = monthly[i];
      final advice = i == maxIdx
          ? 'チャンスの月です。積極的に行動しましょう。'
          : i == minIdx
              ? '注意が必要な月です。慎重に行動しましょう。'
              : r.advice;
      return FortuneResult(
        overall: r.overall,
        love: r.love,
        work: r.work,
        money: r.money,
        health: r.health,
        luckyColor: r.luckyColor,
        luckyNumber: r.luckyNumber,
        luckyDirection: r.luckyDirection,
        advice: advice,
      );
    });

    await _saveToCache(
      profileId,
      'yearly',
      cacheDate,
      jsonEncode(results.map(_encodeResultMap).toList()),
    );
    return results;
  }

  @override
  Future<IntegratedReading> getIntegratedReading(int profileId) {
    throw UnimplementedError();
  }

  // ---------- 誕生データ計算 ----------

  _NatalData _buildNatal(Profile profile) {
    final shichu = shichuEngine.calculate(
      birthDate: profile.birthDate,
      birthTime: profile.birthTime,
    );
    final kyusei = kyuseiEngine.calculate(birthDate: profile.birthDate);
    final birthHoroscope = seizaEngine.calculate(
      birthDate: profile.birthDate,
      birthTime: profile.birthTime != null
          ? DateTime(
              profile.birthDate.year,
              profile.birthDate.month,
              profile.birthDate.day,
              profile.birthTime!.hour,
              profile.birthTime!.minute,
            )
          : null,
      timezoneOffsetMinutes: 540, // JST
      latitude: profile.birthLat,
      longitude: profile.birthLng,
    );
    return _NatalData(
      shichu: shichu,
      kyusei: kyusei,
      dayStemIdx: _stemIdx(shichu.nicchu.stem),
      moonSign: birthHoroscope.moonSign,
      venusSign: birthHoroscope.planets[Planet.venus]?.sign,
    );
  }

  // ---------- 日次運勢算出 ----------

  FortuneResult _computeDaily(_NatalData natal, DateTime date) {
    final todayShichu = shichuEngine.calculate(birthDate: date);
    final todayHoroscope = seizaEngine.calculate(
      birthDate: date,
      birthTime: DateTime(date.year, date.month, date.day, 12, 0),
      timezoneOffsetMinutes: 540,
      latitude: 0,
      longitude: 0,
    );
    final nichibanCenter = kyuseiEngine.calcNichibanCenter(date);
    final todayStemIdx = _stemIdx(todayShichu.nicchu.stem);
    final natalElem = natal.dayStemIdx ~/ 2; // 0=木,1=火,2=土,3=金,4=水
    final todayElem = todayStemIdx ~/ 2;
    final tsuhen = shichuEngine.calcTsuhenStar(natal.dayStemIdx, todayStemIdx);

    final work = FortuneScorer.workScore(natalElem, todayElem, tsuhen);
    final money = FortuneScorer.moneyScore(tsuhen, todayElem);
    final loveRef = natal.venusSign ?? natal.moonSign;
    final love = FortuneScorer.loveScore(_zodiacElem(loveRef), _zodiacElem(todayHoroscope.moonSign));
    final health = FortuneScorer.healthScore(natal.shichu, todayElem);
    final overall = ((work + money + love + health) / 4).round();

    final scores = {'work': work, 'money': money, 'love': love, 'health': health};
    final minKey = scores.entries.reduce((a, b) => a.value <= b.value ? a : b).key;

    return FortuneResult(
      overall: FortuneScorer.toStars(overall),
      work: FortuneScorer.toStars(work),
      money: FortuneScorer.toStars(money),
      love: FortuneScorer.toStars(love),
      health: FortuneScorer.toStars(health),
      luckyColor: _wuXingColors[todayElem],
      luckyNumber: ((nichibanCenter + date.day - 1) % 9) + 1,
      luckyDirection: kyuseiEngine.calcLuckyDirection(
          natal.kyusei.honmeisei.number, nichibanCenter),
      advice: _cautionTexts[minKey]!,
    );
  }

  // 月平均運勢算出 (yearly用)
  FortuneResult _computeMonthAvg(_NatalData natal, DateTime start, DateTime end) {
    var sumO = 0, sumL = 0, sumW = 0, sumM = 0, sumH = 0;
    var count = 0;
    var cursor = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    while (cursor.isBefore(endDay)) {
      final r = _computeDaily(natal, cursor);
      sumO += r.overall; sumL += r.love; sumW += r.work;
      sumM += r.money; sumH += r.health;
      count++;
      cursor = cursor.add(const Duration(days: 1));
    }
    if (count == 0) count = 1;
    final nichibanCenter = kyuseiEngine.calcNichibanCenter(start);
    return FortuneResult(
      overall: (sumO / count).round(),
      love: (sumL / count).round(),
      work: (sumW / count).round(),
      money: (sumM / count).round(),
      health: (sumH / count).round(),
      luckyColor: _wuXingColors[natal.dayStemIdx ~/ 2],
      luckyNumber: ((nichibanCenter + start.month - 1) % 9) + 1,
      luckyDirection: kyuseiEngine.calcLuckyDirection(
          natal.kyusei.honmeisei.number, nichibanCenter),
      advice: '',
    );
  }

  // ---------- ヘルパー ----------

  static int _stemIdx(String stem) => _stems.indexOf(stem);

  // 西洋元素: ZodiacSign.index % 4 → 0=火,1=地,2=風,3=水
  static int _zodiacElem(ZodiacSign sign) => sign.index % 4;

  // ---------- キャッシュ ----------

  Future<String?> _getFromCache(int profileId, String type, DateTime date) async {
    final rows = await (db.select(db.fortuneCache)
          ..where((c) =>
              c.profileId.equals(profileId) &
              c.fortuneType.equals(type) &
              c.targetDate.equals(date)))
        .get();
    return rows.isEmpty ? null : rows.first.resultJson;
  }

  Future<void> _saveToCache(
      int profileId, String type, DateTime date, String json) async {
    await db.into(db.fortuneCache).insert(
      FortuneCacheCompanion.insert(
        profileId: profileId,
        fortuneType: type,
        targetDate: date,
        resultJson: json,
      ),
    );
  }

  // ---------- DB ----------

  Future<Profile> _getProfile(int profileId) async {
    final row = await (db.select(db.profiles)
          ..where((p) => p.id.equals(profileId)))
        .getSingle();
    return Profile(
      id: row.id,
      nickname: row.nickname,
      gender: row.gender,
      birthDate: row.birthDate,
      birthTime: row.birthTime,
      birthPlace: row.birthPlace,
      birthLat: row.birthLat,
      birthLng: row.birthLng,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  // ---------- JSON ----------

  static Map<String, dynamic> _encodeResultMap(FortuneResult r) => {
        'overall': r.overall,
        'love': r.love,
        'work': r.work,
        'money': r.money,
        'health': r.health,
        'luckyColor': r.luckyColor,
        'luckyNumber': r.luckyNumber,
        'luckyDirection': r.luckyDirection,
        'advice': r.advice,
      };

  static String _encodeResult(FortuneResult r) => jsonEncode(_encodeResultMap(r));

  static FortuneResult _decodeResultMap(Map<String, dynamic> m) => FortuneResult(
        overall: m['overall'] as int,
        love: m['love'] as int,
        work: m['work'] as int,
        money: m['money'] as int,
        health: m['health'] as int,
        luckyColor: m['luckyColor'] as String,
        luckyNumber: m['luckyNumber'] as int,
        luckyDirection: m['luckyDirection'] as String,
        advice: m['advice'] as String,
      );

  static FortuneResult _decodeResult(String s) =>
      _decodeResultMap(jsonDecode(s) as Map<String, dynamic>);
}

class _NatalData {
  const _NatalData({
    required this.shichu,
    required this.kyusei,
    required this.dayStemIdx,
    required this.moonSign,
    this.venusSign,
  });

  final ShichuMeishiki shichu;
  final KyuseiResult kyusei;
  final int dayStemIdx;
  final ZodiacSign moonSign;
  final ZodiacSign? venusSign;
}
