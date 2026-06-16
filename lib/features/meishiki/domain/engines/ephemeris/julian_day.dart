class JulianDay {
  static double fromDateTime(DateTime utc) {
    final y = utc.year;
    final m = utc.month;
    final d = utc.day +
        utc.hour / 24.0 +
        utc.minute / 1440.0 +
        utc.second / 86400.0 +
        utc.millisecond / 86400000.0;

    int yy = y;
    int mm = m;
    if (m <= 2) {
      yy = y - 1;
      mm = m + 12;
    }
    final a = (yy / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (yy + 4716)).floor() +
        (30.6001 * (mm + 1)).floor() +
        d +
        b -
        1524.5;
  }

  static double julianCenturies(double jd) => (jd - 2451545.0) / 36525.0;
}
