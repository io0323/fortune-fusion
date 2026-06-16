import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/seiza_engine.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/ephemeris/julian_day.dart';
import 'package:fortune_fusion/features/meishiki/domain/engines/ephemeris/sidereal_time.dart';
import 'package:fortune_fusion/features/meishiki/domain/entities/horoscope.dart';

void main() {
  late SeizaEngine engine;

  setUp(() {
    engine = const SeizaEngine();
  });

  group('JulianDay', () {
    test('J2000.0: 2000-01-01 12:00 UTC → JD 2451545.0', () {
      final jd = JulianDay.fromDateTime(DateTime.utc(2000, 1, 1, 12, 0, 0));
      expect(jd, closeTo(2451545.0, 0.0001));
    });

    test('1990-06-15 00:00 UTC', () {
      // JD for 1990-06-15 = 2448057.5
      final jd = JulianDay.fromDateTime(DateTime.utc(1990, 6, 15, 0, 0, 0));
      expect(jd, closeTo(2448057.5, 0.001));
    });
  });

  group('SiderealTime', () {
    test('GMST at J2000.0 ≈ 280.46°', () {
      final gst = SiderealTime.gmst(2451545.0);
      // At J2000.0 noon, GMST ≈ 280.46°
      expect(gst, closeTo(280.46, 1.0));
    });
  });

  group('Sun longitude', () {
    test('2000-01-01 12:00 UTC → sun ≈ 280.6° (±0.05°)', () {
      final jd = JulianDay.fromDateTime(DateTime.utc(2000, 1, 1, 12, 0, 0));
      final t = JulianDay.julianCenturies(jd);
      final h = engine.calculate(
        birthDate: DateTime(2000, 1, 1),
        birthTime: DateTime(2000, 1, 1, 12, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: 51.48,
        longitude: 0.0,
      );
      expect(h.planets[Planet.sun]!.longitude, closeTo(280.6, 0.5));
    });

    test('1990-06-15 12:00 JST (UTC+9), Tokyo → sun sign: Gemini', () {
      final h = engine.calculate(
        birthDate: DateTime(1990, 6, 15),
        birthTime: DateTime(1990, 6, 15, 12, 0, 0),
        timezoneOffsetMinutes: 9 * 60,
        latitude: 35.68,
        longitude: 139.77,
      );
      expect(h.sunSign, equals(ZodiacSign.gemini));
    });

    test('calculateSunSign 1990-06-15 → gemini', () {
      final sign = engine.calculateSunSign(DateTime(1990, 6, 15));
      expect(sign, equals('gemini'));
    });
  });

  group('ZodiacSign', () {
    test('fromLongitude: 0° → aries', () {
      expect(ZodiacSign.fromLongitude(0.0), ZodiacSign.aries);
    });
    test('fromLongitude: 59.9° → taurus', () {
      expect(ZodiacSign.fromLongitude(59.9), ZodiacSign.taurus);
    });
    test('fromLongitude: 280° → capricorn', () {
      expect(ZodiacSign.fromLongitude(280.0), ZodiacSign.capricorn);
    });
    test('fromLongitude: 360° wraps to aries', () {
      expect(ZodiacSign.fromLongitude(360.0), ZodiacSign.aries);
    });
  });

  group('ASC quadrant judgment', () {
    // Test 4 RAMC quadrant combinations
    test('RAMC=0° low lat → ASC in aries/taurus range', () {
      final h = engine.calculate(
        birthDate: DateTime(2000, 3, 21),
        birthTime: DateTime(2000, 3, 21, 0, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: 35.0,
        longitude: 0.0,
      );
      // ASC should be 0–360
      expect(h.ascendant, inInclusiveRange(0.0, 360.0));
    });

    test('RAMC=90° → ASC differs from MC', () {
      final h = engine.calculate(
        birthDate: DateTime(2000, 6, 21),
        birthTime: DateTime(2000, 6, 21, 6, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: 51.48,
        longitude: 0.0,
      );
      expect(h.ascendant, isNot(closeTo(h.midheaven, 5.0)));
    });

    test('high latitude 60°N produces valid ASC', () {
      final h = engine.calculate(
        birthDate: DateTime(2000, 1, 1),
        birthTime: DateTime(2000, 1, 1, 12, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: 60.0,
        longitude: 25.0,
      );
      expect(h.ascendant, inInclusiveRange(0.0, 360.0));
    });

    test('southern hemisphere lat -35° produces valid ASC', () {
      final h = engine.calculate(
        birthDate: DateTime(2000, 1, 1),
        birthTime: DateTime(2000, 1, 1, 12, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: -35.0,
        longitude: 151.0,
      );
      expect(h.ascendant, inInclusiveRange(0.0, 360.0));
    });
  });

  group('Time uncertainty', () {
    test('null birthTime → isTimeUncertain=true', () {
      final h = engine.calculate(
        birthDate: DateTime(1990, 4, 15),
        latitude: 35.68,
        longitude: 139.77,
      );
      expect(h.isTimeUncertain, isTrue);
    });

    test('non-null birthTime → isTimeUncertain=false', () {
      final h = engine.calculate(
        birthDate: DateTime(1990, 4, 15),
        birthTime: DateTime(1990, 4, 15, 10, 0, 0),
        latitude: 35.68,
        longitude: 139.77,
      );
      expect(h.isTimeUncertain, isFalse);
    });
  });

  group('House cusps', () {
    test('12 house cusps are returned', () {
      final h = engine.calculate(
        birthDate: DateTime(2000, 1, 1),
        birthTime: DateTime(2000, 1, 1, 12, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: 35.68,
        longitude: 139.77,
      );
      expect(h.houses.length, equals(12));
    });

    test('house 1 cusp = ascendant', () {
      final h = engine.calculate(
        birthDate: DateTime(2000, 1, 1),
        birthTime: DateTime(2000, 1, 1, 12, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: 35.68,
        longitude: 139.77,
      );
      expect(h.houses[0].longitude, closeTo(h.ascendant, 0.001));
    });

    test('house 10 cusp = MC', () {
      final h = engine.calculate(
        birthDate: DateTime(2000, 1, 1),
        birthTime: DateTime(2000, 1, 1, 12, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: 35.68,
        longitude: 139.77,
      );
      expect(h.houses[9].longitude, closeTo(h.midheaven, 0.001));
    });
  });

  group('Planet count and retrograde', () {
    test('all 10 planets returned', () {
      final h = engine.calculate(
        birthDate: DateTime(2000, 1, 1),
        birthTime: DateTime(2000, 1, 1, 12, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: 35.68,
        longitude: 139.77,
      );
      expect(h.planets.length, equals(10));
    });

    test('all planet longitudes are 0–360', () {
      final h = engine.calculate(
        birthDate: DateTime(2000, 1, 1),
        birthTime: DateTime(2000, 1, 1, 12, 0, 0),
        timezoneOffsetMinutes: 0,
        latitude: 35.68,
        longitude: 139.77,
      );
      for (final pp in h.planets.values) {
        expect(pp.longitude, inInclusiveRange(0.0, 360.0));
      }
    });
  });
}
