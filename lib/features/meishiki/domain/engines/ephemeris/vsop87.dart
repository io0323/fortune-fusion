import 'dart:math';

// VSOP87 simplified — mean longitude formulas for planet positions.
// Returns ecliptic longitude in degrees.
class Vsop87 {
  static double _norm(double deg) {
    final r = deg % 360.0;
    return r < 0 ? r + 360.0 : r;
  }

  static double sun(double t) {
    // Sun's geometric mean longitude (Meeus Ch.25 low-precision)
    final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    final mRad = (357.52911 + 35999.05029 * t - 0.0001537 * t * t) * pi / 180;
    final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(mRad) +
        (0.019993 - 0.000101 * t) * sin(2 * mRad) +
        0.000289 * sin(3 * mRad);
    final sunLon = l0 + c;
    final omegaRad = (125.04 - 1934.136 * t) * pi / 180;
    final apparent = sunLon - 0.00569 - 0.00478 * sin(omegaRad);
    return _norm(apparent);
  }

  static double mercury(double t) {
    final t2 = t * t;
    return _norm(252.250906 +
        149472.6746358 * t -
        0.00000535 * t2 -
        0.000000002 * t2 * t);
  }

  static double venus(double t) {
    final t2 = t * t;
    return _norm(181.979801 +
        58517.8156760 * t +
        0.00000165 * t2 -
        0.000000002 * t2 * t);
  }

  static double mars(double t) {
    final t2 = t * t;
    return _norm(355.433275 +
        19140.2993313 * t +
        0.00000261 * t2 -
        0.000000003 * t2 * t);
  }

  static double jupiter(double t) {
    final t2 = t * t;
    return _norm(34.351519 +
        3034.9056606 * t -
        0.00008501 * t2 +
        0.000000004 * t2 * t);
  }

  static double saturn(double t) {
    final t2 = t * t;
    return _norm(50.077444 +
        1222.1138488 * t +
        0.00021004 * t2 -
        0.000000019 * t2 * t);
  }

  static double uranus(double t) {
    final t2 = t * t;
    return _norm(314.055005 +
        428.4669983 * t -
        0.00000486 * t2 +
        0.000000006 * t2 * t);
  }

  static double neptune(double t) {
    final t2 = t * t;
    return _norm(304.348665 +
        218.4862002 * t +
        0.00000059 * t2 -
        0.000000002 * t2 * t);
  }

  static double pluto(double t) {
    return _norm(238.92881 + 145.20780 * t);
  }
}
