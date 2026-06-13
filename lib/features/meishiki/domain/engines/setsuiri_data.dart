class SetsuiriData {
  SetsuiriData({
    this.risshunOverrides = const {},
    this.defaultRisshunDay = 4,
    this.defaultRisshunHour = 12,
    this.defaultRisshunMinute = 0,
  });

  final Map<int, DateTime> risshunOverrides;
  final int defaultRisshunDay;
  final int defaultRisshunHour;
  final int defaultRisshunMinute;

  // Index 0=立春 … 10=大雪, 11=小寒(翌年1月)
  static const _defaultSetsuDates = [
    [2, 4], [3, 6], [4, 5], [5, 6], [6, 6], [7, 7],
    [8, 7], [9, 8], [10, 8], [11, 7], [12, 7], [1, 6],
  ];

  DateTime getRisshun(int year) {
    return risshunOverrides[year] ??
        DateTime(year, 2, defaultRisshunDay, defaultRisshunHour, defaultRisshunMinute);
  }

  /// setsuIndex: 0=立春 … 11=小寒
  DateTime getSetsuDate(int kyuseiYear, int setsuIndex) {
    if (setsuIndex == 0) return getRisshun(kyuseiYear);
    final md = _defaultSetsuDates[setsuIndex];
    final calYear = setsuIndex == 11 ? kyuseiYear + 1 : kyuseiYear;
    return DateTime(calYear, md[0], md[1]);
  }

  factory SetsuiriData.fromJson(Map<String, dynamic> json) {
    final overrides = <int, DateTime>{};
    final raw = json['risshun_overrides'] as Map<String, dynamic>? ?? {};
    for (final entry in raw.entries) {
      final year = int.parse(entry.key);
      final d = entry.value as Map<String, dynamic>;
      overrides[year] = DateTime(
        year,
        d['month'] as int,
        d['day'] as int,
        d['hour'] as int,
        d['minute'] as int,
      );
    }
    final def = json['default_risshun'] as Map<String, dynamic>? ?? {};
    return SetsuiriData(
      risshunOverrides: overrides,
      defaultRisshunDay: def['day'] as int? ?? 4,
      defaultRisshunHour: def['hour'] as int? ?? 12,
      defaultRisshunMinute: def['minute'] as int? ?? 0,
    );
  }
}
