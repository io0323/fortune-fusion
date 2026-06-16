import 'dart:math';

// ELP2000 simplified — main 60 terms for Moon's longitude (Meeus Ch.47).
// Returns geocentric ecliptic longitude in degrees.
class Elp2000 {
  static double _rad(double d) => d * pi / 180.0;

  static double _norm(double d) {
    final r = d % 360.0;
    return r < 0 ? r + 360.0 : r;
  }

  static double longitude(double t) {
    final t2 = t * t;
    final t3 = t2 * t;
    final t4 = t3 * t;

    // Moon's mean longitude (degrees)
    final lPrime = 218.3165 + 481267.8813 * t - 0.0013268 * t2 +
        t3 / 538841.0 - t4 / 65194000.0;

    // Fundamental arguments (degrees → radians)
    final mRad = _rad(_norm(357.5291 + 35999.0503 * t - 0.0001559 * t2));
    final mpRad = _rad(_norm(134.9634 + 477198.8676 * t + 0.0089970 * t2));
    final dRad = _rad(_norm(297.8502 + 445267.1115 * t - 0.0016300 * t2));
    final fRad = _rad(_norm(93.2720 + 483202.0175 * t - 0.0034029 * t2));

    // E factor for M (Sun's eccentricity correction)
    final e = 1.0 - 0.002516 * t - 0.0000074 * t2;
    final e2 = e * e;

    // Terms [coefficient_0.000001deg, D, M, M', F]
    const terms = [
      [6288774.0, 0, 0, 1, 0],
      [1274027.0, 2, 0, -1, 0],
      [658314.0, 2, 0, 0, 0],
      [213618.0, 0, 0, 2, 0],
      [-185116.0, 0, 1, 0, 0],
      [-114332.0, 0, 0, 0, 2],
      [58793.0, 2, 0, -2, 0],
      [57066.0, 2, -1, -1, 0],
      [53322.0, 2, 0, 1, 0],
      [45758.0, 2, -1, 0, 0],
      [-40923.0, 0, 1, -1, 0],
      [-34720.0, 1, 0, 0, 0],
      [-30383.0, 0, 1, 1, 0],
      [15327.0, 2, 0, 0, -2],
      [-12528.0, 0, 0, 1, 2],
      [10980.0, 0, 0, 1, -2],
      [10675.0, 4, 0, -1, 0],
      [10034.0, 0, 0, 3, 0],
      [8548.0, 4, 0, -2, 0],
      [-7888.0, 2, 1, -1, 0],
      [-6766.0, 2, 1, 0, 0],
      [-5163.0, 1, 0, -1, 0],
      [4987.0, 1, 1, 0, 0],
      [4036.0, 2, -1, 1, 0],
      [3994.0, 2, 0, 2, 0],
      [3861.0, 4, 0, 0, 0],
      [3665.0, 2, 0, -3, 0],
      [-2689.0, 0, 1, -2, 0],
      [-2602.0, 2, 0, -1, 2],
      [2390.0, 2, -1, -2, 0],
      [-2348.0, 1, 0, 1, 0],
      [2236.0, 2, -2, 0, 0],
      [-2120.0, 0, 1, 2, 0],
      [-2069.0, 0, 2, 0, 0],
      [2048.0, 2, -2, -1, 0],
      [-1773.0, 2, 0, 1, -2],
      [-1595.0, 2, 0, 0, 2],
      [1215.0, 4, -1, -1, 0],
      [-1110.0, 0, 0, 2, 2],
      [-892.0, 3, 0, -1, 0],
      [-810.0, 2, 1, 1, 0],
      [759.0, 4, -1, -2, 0],
      [-713.0, 0, 2, -1, 0],
      [-700.0, 2, 2, -1, 0],
      [691.0, 2, 1, -2, 0],
      [596.0, 2, -1, 0, -2],
      [549.0, 4, 0, 1, 0],
      [537.0, 0, 0, 4, 0],
      [520.0, 4, -1, 0, 0],
      [-487.0, 1, 0, -2, 0],
      [-399.0, 2, 1, 0, -2],
      [-381.0, 0, 0, 2, -2],
      [351.0, 1, 1, 1, 0],
      [-340.0, 3, 0, -2, 0],
      [330.0, 4, 0, -3, 0],
      [327.0, 2, -1, 2, 0],
      [-323.0, 0, 2, 1, 0],
      [299.0, 1, 1, -1, 0],
      [294.0, 2, 0, 3, 0],
      [0.0, 0, 0, 0, 0], // padding to 60
    ];

    double sumL = 0;
    for (final row in terms) {
      final coeff = row[0].toDouble();
      if (coeff == 0) continue;
      final nd = row[1].toDouble();
      final nm = row[2].toDouble();
      final nmp = row[3].toDouble();
      final nf = row[4].toDouble();

      final argRad = nd * dRad + nm * mRad + nmp * mpRad + nf * fRad;

      double c = coeff;
      final absNm = nm.abs();
      if (absNm == 1) c *= e;
      if (absNm == 2) c *= e2;

      sumL += c * sin(argRad);
    }

    // Additional terms
    sumL += 3958.0 * sin(_rad(119.75 + 131.849 * t));
    sumL += 1962.0 * sin(_rad(lPrime - 93.2720 - 483202.0175 * t));
    sumL += 318.0 * sin(_rad(53.09 + 479264.290 * t));

    final lon = lPrime + sumL / 1000000.0;

    // Nutation correction (simplified)
    final omegaRad = _rad(125.04452 - 1934.136261 * t);
    final nutation = -17.20 / 3600.0 * sin(omegaRad) -
        1.32 / 3600.0 * sin(2 * _rad(280.4665 + 36000.7698 * t)) -
        0.23 / 3600.0 * sin(2 * _rad(218.3165 + 481267.8813 * t)) +
        0.21 / 3600.0 * sin(2 * omegaRad);

    return _norm(lon + nutation);
  }
}
