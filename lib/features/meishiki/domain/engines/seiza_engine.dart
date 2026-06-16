import 'dart:math';

import '../entities/horoscope.dart';
import 'ephemeris/julian_day.dart';
import 'ephemeris/sidereal_time.dart';
import 'ephemeris/vsop87.dart';
import 'ephemeris/elp2000.dart';

class SeizaEngine {
  const SeizaEngine();

  static const double _obliquity = 23.4392911; // mean obliquity J2000

  Horoscope calculate({
    required DateTime birthDate,
    DateTime? birthTime,
    int timezoneOffsetMinutes = 0,
    required double latitude,
    required double longitude,
  }) {
    final bool uncertain = birthTime == null;

    // Build UTC datetime
    final local = uncertain
        ? DateTime(birthDate.year, birthDate.month, birthDate.day, 12, 0, 0)
        : DateTime(
            birthDate.year,
            birthDate.month,
            birthDate.day,
            birthTime.hour,
            birthTime.minute,
            birthTime.second,
          );
    final utc = local.subtract(Duration(minutes: timezoneOffsetMinutes));

    final jd = JulianDay.fromDateTime(utc);
    final t = JulianDay.julianCenturies(jd);

    // Planet longitudes (geocentric ecliptic)
    final planetLons = _calcPlanetLongitudes(t, jd, longitude);

    // ASC / MC
    double asc = 0, mc = 0;
    List<HouseCusp> houseCusps;

    if (!uncertain) {
      final ramcDeg = SiderealTime.ramc(jd, longitude);
      final eps = _obliquityAtT(t);
      asc = _calcAsc(ramcDeg, latitude, eps);
      mc = _calcMc(ramcDeg, eps);
      houseCusps = _calcPorphyryHouses(asc, mc);
    } else {
      houseCusps = List.generate(
          12, (i) => HouseCusp(house: i + 1, longitude: i * 30.0));
    }

    // House assignment
    final planets = <Planet, PlanetPosition>{};
    for (final entry in planetLons.entries) {
      final lon = entry.value;
      final house = uncertain ? 0 : _assignHouse(lon, houseCusps);
      // Retrograde: compare with yesterday's longitude
      final lonYesterday = _planetLongitude(entry.key, t - 1 / 36525.0);
      final retrograde = uncertain ? false : _isRetrograde(lon, lonYesterday);
      planets[entry.key] = PlanetPosition(
        planet: entry.key,
        longitude: lon,
        sign: ZodiacSign.fromLongitude(lon),
        house: house,
        isRetrograde: retrograde,
      );
    }

    final sunLon = planetLons[Planet.sun]!;
    final moonLon = planetLons[Planet.moon]!;

    return Horoscope(
      planets: planets,
      ascendant: uncertain ? 0.0 : asc,
      midheaven: uncertain ? 0.0 : mc,
      sunSign: ZodiacSign.fromLongitude(sunLon),
      moonSign: ZodiacSign.fromLongitude(moonLon),
      ascSign: uncertain ? ZodiacSign.aries : ZodiacSign.fromLongitude(asc),
      houses: houseCusps,
      houseSystem: HouseSystem.porphyry,
      isTimeUncertain: uncertain,
    );
  }

  // --- Convenience methods ---

  String calculateSunSign(DateTime birthDate) {
    final utc =
        DateTime(birthDate.year, birthDate.month, birthDate.day, 12, 0, 0);
    final jd = JulianDay.fromDateTime(utc);
    final t = JulianDay.julianCenturies(jd);
    final lon = Vsop87.sun(t);
    return ZodiacSign.fromLongitude(lon).name;
  }

  String calculateMoonSign({
    required DateTime birthDate,
    required DateTime? birthTime,
    required double latitude,
    required double longitude,
  }) {
    final h = calculate(
      birthDate: birthDate,
      birthTime: birthTime,
      latitude: latitude,
      longitude: longitude,
    );
    return h.moonSign.name;
  }

  String calculateAscendant({
    required DateTime birthDate,
    required DateTime birthTime,
    required double latitude,
    required double longitude,
  }) {
    final h = calculate(
      birthDate: birthDate,
      birthTime: birthTime,
      latitude: latitude,
      longitude: longitude,
    );
    return h.ascSign.name;
  }

  String calculateMidheaven({
    required DateTime birthDate,
    required DateTime birthTime,
    required double latitude,
    required double longitude,
  }) {
    final h = calculate(
      birthDate: birthDate,
      birthTime: birthTime,
      latitude: latitude,
      longitude: longitude,
    );
    return ZodiacSign.fromLongitude(h.midheaven).name;
  }

  List<PlanetPosition> calculatePlanets({
    required DateTime birthDate,
    DateTime? birthTime,
    required double latitude,
    required double longitude,
  }) {
    final h = calculate(
      birthDate: birthDate,
      birthTime: birthTime,
      latitude: latitude,
      longitude: longitude,
    );
    return h.planets.values.toList();
  }

  // --- Private calculations ---

  double _obliquityAtT(double t) {
    return _obliquity -
        0.013004167 * t -
        0.0000001639 * t * t +
        0.0000005036 * t * t * t;
  }

  Map<Planet, double> _calcPlanetLongitudes(
      double t, double jd, double longitudeDeg) {
    return {
      Planet.sun: Vsop87.sun(t),
      Planet.moon: Elp2000.longitude(t),
      Planet.mercury: _mercuryGeocentric(t),
      Planet.venus: _venusGeocentric(t),
      Planet.mars: Vsop87.mars(t),
      Planet.jupiter: Vsop87.jupiter(t),
      Planet.saturn: Vsop87.saturn(t),
      Planet.uranus: Vsop87.uranus(t),
      Planet.neptune: Vsop87.neptune(t),
      Planet.pluto: Vsop87.pluto(t),
    };
  }

  double _planetLongitude(Planet planet, double t) {
    switch (planet) {
      case Planet.sun:
        return Vsop87.sun(t);
      case Planet.moon:
        return Elp2000.longitude(t);
      case Planet.mercury:
        return _mercuryGeocentric(t);
      case Planet.venus:
        return _venusGeocentric(t);
      case Planet.mars:
        return Vsop87.mars(t);
      case Planet.jupiter:
        return Vsop87.jupiter(t);
      case Planet.saturn:
        return Vsop87.saturn(t);
      case Planet.uranus:
        return Vsop87.uranus(t);
      case Planet.neptune:
        return Vsop87.neptune(t);
      case Planet.pluto:
        return Vsop87.pluto(t);
    }
  }

  // Mercury geocentric: use Sun and Mercury heliocentric positions
  double _mercuryGeocentric(double t) {
    final sunLon = Vsop87.sun(t);
    final mercLon = Vsop87.mercury(t);
    // Inner planet geocentric: project through Earth
    // Approximate: geocentric = atan2(sin(M-S)*rM, rE - cos(M-S)*rM) + S
    const rMerc = 0.387098; // AU
    const rEarth = 1.0;
    final diff = _rad(mercLon - sunLon);
    final geoRad = atan2(sin(diff) * rMerc, rEarth - cos(diff) * rMerc);
    final geo = (sunLon + geoRad * 180.0 / pi) % 360.0;
    return geo < 0 ? geo + 360.0 : geo;
  }

  double _venusGeocentric(double t) {
    final sunLon = Vsop87.sun(t);
    final venusLon = Vsop87.venus(t);
    const rVenus = 0.723332;
    const rEarth = 1.0;
    final diff = _rad(venusLon - sunLon);
    final geoRad = atan2(sin(diff) * rVenus, rEarth - cos(diff) * rVenus);
    final geo = (sunLon + geoRad * 180.0 / pi) % 360.0;
    return geo < 0 ? geo + 360.0 : geo;
  }

  double _calcAsc(double ramcDeg, double latDeg, double epsDeg) {
    final ramc = _rad(ramcDeg);
    final lat = _rad(latDeg);
    final eps = _rad(epsDeg);

    // tan(ASC) = -cos(RAMC) / (sin(eps)*tan(lat) + cos(eps)*sin(RAMC))
    final numerator = -cos(ramc);
    final denominator = sin(eps) * tan(lat) + cos(eps) * sin(ramc);

    double asc = atan2(numerator, denominator) * 180.0 / pi;

    // Quadrant correction: ASC must be in same semicircle as RAMC+90
    // Ensure ASC is in correct quadrant based on RAMC
    if (denominator < 0) asc += 180.0;
    asc = (asc % 360.0 + 360.0) % 360.0;
    return asc;
  }

  double _calcMc(double ramcDeg, double epsDeg) {
    final ramc = _rad(ramcDeg);
    final eps = _rad(epsDeg);
    // tan(MC) = tan(RAMC) / cos(eps)
    double mc = atan2(sin(ramc), cos(ramc) * cos(eps)) * 180.0 / pi;
    // MC must be in same semicircle as RAMC
    if (mc < 0) mc += 360.0;
    if ((ramcDeg % 360.0) > 180.0 && mc < 180.0) mc += 180.0;
    if ((ramcDeg % 360.0) <= 180.0 && mc >= 180.0) mc -= 180.0;
    return (mc % 360.0 + 360.0) % 360.0;
  }

  // Porphyry house system: divide ASC-MC arc into 3 equal parts
  List<HouseCusp> _calcPorphyryHouses(double asc, double mc) {
    final descArc = (asc - mc + 360.0) % 360.0; // ASC to DESC arc via MC
    final icArc = 360.0 - descArc; // IC to ASC arc
    final thirdDesc = descArc / 3.0;
    final thirdAsc = icArc / 3.0;

    final ic = (mc + 180.0) % 360.0;
    final desc = (asc + 180.0) % 360.0;

    return [
      HouseCusp(house: 1, longitude: asc),
      HouseCusp(house: 2, longitude: (asc + thirdAsc) % 360.0),
      HouseCusp(house: 3, longitude: (asc + 2 * thirdAsc) % 360.0),
      HouseCusp(house: 4, longitude: ic),
      HouseCusp(house: 5, longitude: (ic + thirdDesc) % 360.0),
      HouseCusp(house: 6, longitude: (ic + 2 * thirdDesc) % 360.0),
      HouseCusp(house: 7, longitude: desc),
      HouseCusp(house: 8, longitude: (desc + thirdAsc) % 360.0),
      HouseCusp(house: 9, longitude: (desc + 2 * thirdAsc) % 360.0),
      HouseCusp(house: 10, longitude: mc),
      HouseCusp(house: 11, longitude: (mc + thirdDesc) % 360.0),
      HouseCusp(house: 12, longitude: (mc + 2 * thirdDesc) % 360.0),
    ];
  }

  int _assignHouse(double planetLon, List<HouseCusp> cusps) {
    for (int i = 0; i < 12; i++) {
      final cuspStart = cusps[i].longitude;
      final cuspEnd = cusps[(i + 1) % 12].longitude;
      if (_inArc(planetLon, cuspStart, cuspEnd)) return i + 1;
    }
    return 1;
  }

  bool _inArc(double lon, double start, double end) {
    if (end > start) return lon >= start && lon < end;
    // Wrap-around
    return lon >= start || lon < end;
  }

  bool _isRetrograde(double lonNow, double lonYesterday) {
    double diff = lonNow - lonYesterday;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff < 0;
  }

  double _rad(double d) => d * pi / 180.0;
}
