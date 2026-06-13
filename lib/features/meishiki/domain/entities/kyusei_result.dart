enum KyuseiStar {
  ikkhaku(1, '一白水星', '水', '白'),
  jikoku(2, '二黒土星', '土', '黒'),
  sanpeki(3, '三碧木星', '木', '碧'),
  shiryoku(4, '四緑木星', '木', '緑'),
  gokou(5, '五黄土星', '土', '黄'),
  roppaku(6, '六白金星', '金', '白'),
  shichiseki(7, '七赤金星', '金', '赤'),
  happu(8, '八白土星', '土', '白'),
  kyushi(9, '九紫火星', '火', '紫');

  const KyuseiStar(this.number, this.label, this.element, this.color);

  final int number;
  final String label;
  final String element;
  final String color;

  static KyuseiStar fromNumber(int n) {
    assert(n >= 1 && n <= 9, 'KyuseiStar number must be 1-9, got $n');
    return values.firstWhere((s) => s.number == n);
  }
}

enum KeishaKyu {
  kan(1, '坎宮'),
  kon(2, '坤宮'),
  shin(3, '震宮'),
  son(4, '巽宮'),
  chu(5, '中宮'),
  ken(6, '乾宮'),
  da(7, '兌宮'),
  gon(8, '艮宮'),
  ri(9, '離宮');

  const KeishaKyu(this.position, this.label);

  final int position;
  final String label;

  static KeishaKyu fromPosition(int p) {
    assert(p >= 1 && p <= 9, 'KeishaKyu position must be 1-9, got $p');
    return values.firstWhere((k) => k.position == p);
  }
}

class KyuseiResult {
  const KyuseiResult({
    required this.honmeisei,
    required this.getsumeisei,
    required this.keisha,
    required this.nenbanCenter,
  });

  final KyuseiStar honmeisei;
  final KyuseiStar getsumeisei;
  final KeishaKyu keisha;
  final int nenbanCenter;

  KyuseiResult copyWith({
    KyuseiStar? honmeisei,
    KyuseiStar? getsumeisei,
    KeishaKyu? keisha,
    int? nenbanCenter,
  }) {
    return KyuseiResult(
      honmeisei: honmeisei ?? this.honmeisei,
      getsumeisei: getsumeisei ?? this.getsumeisei,
      keisha: keisha ?? this.keisha,
      nenbanCenter: nenbanCenter ?? this.nenbanCenter,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is KyuseiResult &&
      honmeisei == other.honmeisei &&
      getsumeisei == other.getsumeisei &&
      keisha == other.keisha &&
      nenbanCenter == other.nenbanCenter;

  @override
  int get hashCode => Object.hash(honmeisei, getsumeisei, keisha, nenbanCenter);
}
