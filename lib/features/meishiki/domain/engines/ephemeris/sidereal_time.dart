import 'dart:math';

class SiderealTime {
  // Greenwich Mean Sidereal Time in degrees
  static double gmst(double jd) {
    final t = (jd - 2451545.0) / 36525.0;
    final gst = 280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    return gst % 360.0;
  }

  // Local Sidereal Time in degrees
  static double lst(double jd, double longitudeDeg) {
    return (gmst(jd) + longitudeDeg) % 360.0;
  }

  // RAMC = LST in degrees
  static double ramc(double jd, double longitudeDeg) => lst(jd, longitudeDeg);

  static double toRadians(double deg) => deg * pi / 180.0;
  static double toDegrees(double rad) => rad * 180.0 / pi;
}
