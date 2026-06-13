class PlanetPosition {
  const PlanetPosition({
    required this.planet,
    required this.sign,
    required this.degree,
    required this.house,
  });

  final String planet;
  final String sign;
  final double degree;
  final int house;
}

class Horoscope {
  const Horoscope({
    required this.sunSign,
    required this.moonSign,
    required this.ascendant,
    required this.midheaven,
    required this.planets,
  });

  final String sunSign;
  final String moonSign;
  final String ascendant;
  final String midheaven;
  final List<PlanetPosition> planets;
}
