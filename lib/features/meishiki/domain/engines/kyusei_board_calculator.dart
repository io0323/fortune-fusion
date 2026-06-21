import '../entities/kyusei_result.dart';
import 'setsuiri_data.dart';

enum KyuseiBoardType { year, month, day }

class KyuseiBoardCalculator {
  const KyuseiBoardCalculator({required this.setsuiriData});

  final SetsuiriData setsuiriData;

  static const _getsumeiTable = [
    [8, 7, 6, 5, 4, 3, 2, 1, 9, 8, 7, 6], // Group A: 1,4,7
    [2, 1, 9, 8, 7, 6, 5, 4, 3, 2, 1, 9], // Group B: 2,5,8
    [5, 4, 3, 2, 1, 9, 8, 7, 6, 5, 4, 3], // Group C: 3,6,9
  ];

  static const _posToDirection = <int, String>{
    1: '北', 2: '南西', 3: '東', 4: '東南',
    6: '北西', 7: '西', 8: '北東', 9: '南',
  };

  static const _oppositePos = <int, int>{
    1: 9, 9: 1, 2: 8, 8: 2, 3: 7, 7: 3, 4: 6, 6: 4,
  };

  /// Returns a map from position (1-9) to KyuseiStar.
  /// Position 5 = 中宮 (center).
  Map<int, KyuseiStar> calculateBoard(KyuseiBoardType type, DateTime target) {
    final center = switch (type) {
      KyuseiBoardType.year => _yearCenter(target),
      KyuseiBoardType.month => _monthCenter(target),
      KyuseiBoardType.day => _dayCenter(target),
    };
    return {
      for (int p = 1; p <= 9; p++)
        p: KyuseiStar.fromNumber(((p + center - 6) % 9 + 9) % 9 + 1),
    };
  }

  String? directionOf(int starNumber, Map<int, KyuseiStar> board) {
    for (final entry in board.entries) {
      if (entry.value.number == starNumber) return _posToDirection[entry.key];
    }
    return null;
  }

  String? oppositeDirectionOf(int starNumber, Map<int, KyuseiStar> board) {
    for (final entry in board.entries) {
      if (entry.value.number == starNumber) {
        final opp = _oppositePos[entry.key];
        if (opp == null) return null;
        return _posToDirection[opp];
      }
    }
    return null;
  }

  int kyuseiYearOf(DateTime date) => _kyuseiYear(date);
  int setsuMonthOf(DateTime date) => _setsuMonth(date, _kyuseiYear(date));

  int _yearCenter(DateTime date) => _calcHonmei(_kyuseiYear(date));

  int _monthCenter(DateTime date) {
    final kyuseiYear = _kyuseiYear(date);
    final yearCenter = _calcHonmei(kyuseiYear);
    final setsuMonth = _setsuMonth(date, kyuseiYear);
    return _getsumeiTable[_group(yearCenter)][setsuMonth - 1];
  }

  int _dayCenter(DateTime date) {
    final ref = DateTime(1900, 1, 1);
    final days = DateTime(date.year, date.month, date.day).difference(ref).inDays;
    return ((-(days % 9) + 9) % 9) + 1;
  }

  int _kyuseiYear(DateTime date) {
    final risshun = setsuiriData.getRisshun(date.year);
    return date.isBefore(risshun) ? date.year - 1 : date.year;
  }

  int _calcHonmei(int kyuseiYear) {
    final n = _reduceDigits(kyuseiYear.abs());
    int result = 11 - n;
    if (result >= 10) result = _reduceDigits(result);
    return result;
  }

  int _reduceDigits(int n) {
    while (n >= 10) {
      var sum = 0;
      while (n > 0) {
        sum += n % 10;
        n ~/= 10;
      }
      n = sum;
    }
    return n;
  }

  int _setsuMonth(DateTime date, int kyuseiYear) {
    for (int i = 11; i >= 0; i--) {
      if (!date.isBefore(setsuiriData.getSetsuDate(kyuseiYear, i))) return i + 1;
    }
    return 1;
  }

  int _group(int honmei) {
    if (honmei == 1 || honmei == 4 || honmei == 7) return 0;
    if (honmei == 2 || honmei == 5 || honmei == 8) return 1;
    return 2;
  }
}
