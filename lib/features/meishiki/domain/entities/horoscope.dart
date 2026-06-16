enum ZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces;

  static ZodiacSign fromLongitude(double lon) {
    final normalized = lon % 360;
    final adjusted = normalized < 0 ? normalized + 360 : normalized;
    return ZodiacSign.values[(adjusted / 30).floor()];
  }
}

enum Planet {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
  uranus,
  neptune,
  pluto,
}

enum HouseSystem { porphyry, placidus }

class PlanetPosition {
  const PlanetPosition({
    required this.planet,
    required this.longitude,
    required this.sign,
    required this.house,
    required this.isRetrograde,
  });

  final Planet planet;
  final double longitude;
  final ZodiacSign sign;
  final int house;
  final bool isRetrograde;

  double get degree => longitude % 30;
}

class HouseCusp {
  const HouseCusp({required this.house, required this.longitude});
  final int house;
  final double longitude;
}

class Horoscope {
  const Horoscope({
    required this.planets,
    required this.ascendant,
    required this.midheaven,
    required this.sunSign,
    required this.moonSign,
    required this.ascSign,
    required this.houses,
    required this.houseSystem,
    this.isTimeUncertain = false,
  });

  final Map<Planet, PlanetPosition> planets;
  final double ascendant;
  final double midheaven;
  final ZodiacSign sunSign;
  final ZodiacSign moonSign;
  final ZodiacSign ascSign;
  final List<HouseCusp> houses;
  final HouseSystem houseSystem;
  final bool isTimeUncertain;
}
