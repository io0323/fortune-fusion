import '../entities/shichu_meishiki.dart';

class ShichuEngine {
  const ShichuEngine();

  ShichuMeishiki calculate({
    required DateTime birthDate,
    DateTime? birthTime,
  }) {
    throw UnimplementedError('ShichuEngine.calculate is not yet implemented');
  }

  String calculateYearStem(int year) {
    throw UnimplementedError();
  }

  String calculateYearBranch(int year) {
    throw UnimplementedError();
  }

  String calculateMonthStem(int year, int month) {
    throw UnimplementedError();
  }

  String calculateMonthBranch(int month) {
    throw UnimplementedError();
  }

  String calculateDayStem(DateTime date) {
    throw UnimplementedError();
  }

  String calculateDayBranch(DateTime date) {
    throw UnimplementedError();
  }

  String? calculateHourStem(DateTime? birthTime, String dayStem) {
    if (birthTime == null) return null;
    throw UnimplementedError();
  }

  String? calculateHourBranch(DateTime? birthTime) {
    if (birthTime == null) return null;
    throw UnimplementedError();
  }
}
