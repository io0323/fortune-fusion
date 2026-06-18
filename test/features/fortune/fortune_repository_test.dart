import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/fortune/data/repositories/fortune_repository_impl.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/kyusei_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/seiza_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/setsuiri_data.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/shichu_engine.dart';
import 'package:fortune_fusion/shared/database/app_database.dart';

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

FortuneRepositoryImpl _makeRepo(AppDatabase db) => FortuneRepositoryImpl(
      db: db,
      shichuEngine: ShichuEngine(setsuiriData: SetsuiriData()),
      seizaEngine: const SeizaEngine(),
      kyuseiEngine: KyuseiEngine(setsuiriData: SetsuiriData()),
    );

Future<int> _insertProfile(AppDatabase db, {bool nullBirthTime = false}) =>
    db.into(db.profiles).insert(ProfilesCompanion.insert(
      nickname: 'テスト',
      gender: '男性',
      birthDate: DateTime(1990, 6, 15),
      birthTime: nullBirthTime
          ? const Value.absent()
          : Value(DateTime(1990, 6, 15, 12, 0)),
      birthPlace: '東京都',
      birthLat: 35.68,
      birthLng: 139.77,
    ));

void main() {
  late AppDatabase db;
  late FortuneRepositoryImpl repo;

  setUp(() {
    db = _makeTestDb();
    repo = _makeRepo(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('FortuneRepositoryImpl.getDailyFortune', () {
    test('決定論: 同一入力2回で完全一致', () async {
      final profileId = await _insertProfile(db);
      final date = DateTime(2024, 6, 15);
      final r1 = await repo.getDailyFortune(profileId, date);
      final r2 = await repo.getDailyFortune(profileId, date);
      expect(r2.result.overall, equals(r1.result.overall));
      expect(r2.result.love, equals(r1.result.love));
      expect(r2.result.work, equals(r1.result.work));
      expect(r2.result.money, equals(r1.result.money));
      expect(r2.result.health, equals(r1.result.health));
    });

    test('★は1〜5の範囲内', () async {
      final profileId = await _insertProfile(db);
      final r = await repo.getDailyFortune(profileId, DateTime(2024, 6, 15));
      for (final s in [
        r.result.overall,
        r.result.love,
        r.result.work,
        r.result.money,
        r.result.health,
      ]) {
        expect(s, inInclusiveRange(1, 5));
      }
    });

    test('連続7日でworkスコアに分散がある（全日同一でない）', () async {
      final profileId = await _insertProfile(db);
      final works = <int>[];
      for (int i = 0; i < 7; i++) {
        final r =
            await repo.getDailyFortune(profileId, DateTime(2024, 6, 15 + i));
        works.add(r.result.work);
      }
      expect(works.toSet().length, greaterThan(1));
    });

    test('キャッシュヒット時に再算出と同一結果・キャッシュ行は1つ', () async {
      final profileId = await _insertProfile(db);
      final date = DateTime(2024, 7, 1);
      final r1 = await repo.getDailyFortune(profileId, date);
      final r2 = await repo.getDailyFortune(profileId, date);
      final cacheRows = await db.select(db.fortuneCache).get();
      expect(cacheRows.length, equals(1));
      expect(r2.result.overall, equals(r1.result.overall));
      expect(r2.result.work, equals(r1.result.work));
      expect(r2.result.love, equals(r1.result.love));
    });

    test('出生時刻null時も運勢が破綻しない', () async {
      final profileId = await _insertProfile(db, nullBirthTime: true);
      final r = await repo.getDailyFortune(profileId, DateTime(2024, 6, 15));
      expect(r.result.overall, inInclusiveRange(1, 5));
      expect(r.result.love, inInclusiveRange(1, 5));
      expect(r.result.work, inInclusiveRange(1, 5));
      expect(r.result.money, inInclusiveRange(1, 5));
      expect(r.result.health, inInclusiveRange(1, 5));
    });
  });
}
