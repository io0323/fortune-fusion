import '../entities/kyusei_result.dart';

class KyuseiEngine {
  const KyuseiEngine();

  KyuseiResult calculate({
    required DateTime birthDate,
    DateTime? targetDate,
  }) {
    throw UnimplementedError('KyuseiEngine.calculate is not yet implemented');
  }

  int calculateHonmeiStar(DateTime birthDate) {
    throw UnimplementedError();
  }

  int calculateGetsumeiStar(DateTime birthDate) {
    throw UnimplementedError();
  }

  int calculateKeishakyu(DateTime birthDate) {
    throw UnimplementedError();
  }

  List<String> calculateLuckyDirections({
    required int honmeiStar,
    required DateTime targetDate,
  }) {
    throw UnimplementedError();
  }

  List<String> calculateUnluckyDirections({
    required int honmeiStar,
    required DateTime targetDate,
  }) {
    throw UnimplementedError();
  }
}
