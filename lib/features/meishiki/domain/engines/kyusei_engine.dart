import '../entities/kyusei_result.dart';
import 'setsuiri_data.dart';

class KyuseiEngine {
  const KyuseiEngine({required this.setsuiriData});

  final SetsuiriData setsuiriData;

  // 月命星テーブル: [Group A, Group B, Group C] × 節月1-12
  static const _getsumeiTable = [
    [8, 7, 6, 5, 4, 3, 2, 1, 9, 8, 7, 6], // Group A: 本命星 1,4,7
    [2, 1, 9, 8, 7, 6, 5, 4, 3, 2, 1, 9], // Group B: 本命星 2,5,8
    [5, 4, 3, 2, 1, 9, 8, 7, 6, 5, 4, 3], // Group C: 本命星 3,6,9
  ];

  KyuseiResult calculate({
    required DateTime birthDate,
    DateTime? targetDate,
  }) {
    final td = targetDate ?? DateTime.now();
    final kyuseiYear = _getKyuseiYear(birthDate);
    final honmei = _calcHonmei(kyuseiYear);
    final setsuMonth = _getSetsuMonth(birthDate, kyuseiYear);
    final getsumei = _calcGetsumei(honmei, setsuMonth);
    final keishaPos = _calcKeishaPosition(honmei, getsumei);
    final nenbanCenter = _calcHonmei(_getKyuseiYear(td));

    return KyuseiResult(
      honmeisei: KyuseiStar.fromNumber(honmei),
      getsumeisei: KyuseiStar.fromNumber(getsumei),
      keisha: KeishaKyu.fromPosition(keishaPos),
      nenbanCenter: nenbanCenter,
    );
  }

  // 本命星だけ返す補助メソッド（テスト用）
  KyuseiStar calcHonmeisei(DateTime birthDate) {
    final kyuseiYear = _getKyuseiYear(birthDate);
    return KyuseiStar.fromNumber(_calcHonmei(kyuseiYear));
  }

  // 九星年（立春で切り替わる）
  int _getKyuseiYear(DateTime date) {
    final risshun = setsuiriData.getRisshun(date.year);
    return date.isBefore(risshun) ? date.year - 1 : date.year;
  }

  // 本命星計算: 各桁の和を1桁に→11から引く
  int _calcHonmei(int kyuseiYear) {
    final n = _reduceToSingleDigit(kyuseiYear.abs());
    int result = 11 - n;
    if (result >= 10) result = _reduceToSingleDigit(result);
    return result;
  }

  int _reduceToSingleDigit(int n) {
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

  // 節月（1=寅月/立春 … 12=丑月/小寒）
  int _getSetsuMonth(DateTime birthDate, int kyuseiYear) {
    for (int i = 11; i >= 0; i--) {
      final setsuDate = setsuiriData.getSetsuDate(kyuseiYear, i);
      if (!birthDate.isBefore(setsuDate)) return i + 1;
    }
    return 1;
  }

  // グループ判定: 0=A(1,4,7), 1=B(2,5,8), 2=C(3,6,9)
  int _getGroup(int honmei) {
    if (honmei == 1 || honmei == 4 || honmei == 7) return 0;
    if (honmei == 2 || honmei == 5 || honmei == 8) return 1;
    return 2;
  }

  int _calcGetsumei(int honmei, int setsuMonth) {
    return _getsumeiTable[_getGroup(honmei)][setsuMonth - 1];
  }

  // 傾斜宮位置: 年盤（本命星=中宮）における月命星の位置
  // 後天定位盤番号→位置の標準対応: 番号=位置
  // 年盤中宮=H のとき星Sの位置 = ((S + (5-H) - 1) % 9) + 1
  int _calcKeishaPosition(int honmei, int getsumei) {
    return ((getsumei - honmei + 4) % 9) + 1;
  }
}
