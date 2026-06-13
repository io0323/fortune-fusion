class Pillar {
  const Pillar({required this.stem, required this.branch});
  final String stem;
  final String branch;

  @override
  bool operator ==(Object other) =>
      other is Pillar && stem == other.stem && branch == other.branch;

  @override
  int get hashCode => Object.hash(stem, branch);
}

class ShichuMeishiki {
  const ShichuMeishiki({
    required this.yearPillar,
    required this.monthPillar,
    required this.dayPillar,
    required this.hourPillar,
  });

  final Pillar yearPillar;
  final Pillar monthPillar;
  final Pillar dayPillar;
  final Pillar? hourPillar;

  ShichuMeishiki copyWith({
    Pillar? yearPillar,
    Pillar? monthPillar,
    Pillar? dayPillar,
    Pillar? hourPillar,
  }) {
    return ShichuMeishiki(
      yearPillar: yearPillar ?? this.yearPillar,
      monthPillar: monthPillar ?? this.monthPillar,
      dayPillar: dayPillar ?? this.dayPillar,
      hourPillar: hourPillar ?? this.hourPillar,
    );
  }
}
