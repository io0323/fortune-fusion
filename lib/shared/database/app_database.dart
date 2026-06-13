import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nickname => text().withLength(min: 1, max: 50)();
  TextColumn get gender => text().withLength(min: 1, max: 20)();
  DateTimeColumn get birthDate => dateTime()();
  DateTimeColumn get birthTime => dateTime().nullable()();
  TextColumn get birthPlace => text().withLength(min: 1, max: 100)();
  RealColumn get birthLat => real()();
  RealColumn get birthLng => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class FortuneCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get fortuneType => text().withLength(min: 1, max: 50)();
  DateTimeColumn get targetDate => dateTime()();
  TextColumn get resultJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Profiles, FortuneCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fortune_fusion.db'));
    return NativeDatabase.createInBackground(file);
  });
}
