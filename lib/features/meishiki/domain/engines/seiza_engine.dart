import '../entities/horoscope.dart';

class SeizaEngine {
  const SeizaEngine();

  Horoscope calculate({
    required DateTime birthDate,
    DateTime? birthTime,
    required double latitude,
    required double longitude,
  }) {
    throw UnimplementedError('SeizaEngine.calculate is not yet implemented');
  }

  String calculateSunSign(DateTime birthDate) {
    throw UnimplementedError();
  }

  String calculateMoonSign({
    required DateTime birthDate,
    required DateTime? birthTime,
    required double latitude,
    required double longitude,
  }) {
    throw UnimplementedError();
  }

  String calculateAscendant({
    required DateTime birthDate,
    required DateTime birthTime,
    required double latitude,
    required double longitude,
  }) {
    throw UnimplementedError();
  }

  String calculateMidheaven({
    required DateTime birthDate,
    required DateTime birthTime,
    required double latitude,
    required double longitude,
  }) {
    throw UnimplementedError();
  }

  List<PlanetPosition> calculatePlanets({
    required DateTime birthDate,
    DateTime? birthTime,
    required double latitude,
    required double longitude,
  }) {
    throw UnimplementedError();
  }
}
