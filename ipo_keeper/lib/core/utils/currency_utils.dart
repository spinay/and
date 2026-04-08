import 'package:intl/intl.dart';

class CurrencyUtils {
  static final _formatter = NumberFormat('#,###', 'ko_KR');

  static String format(int amount) => '${_formatter.format(amount)}원';

  static String formatShort(int amount) {
    if (amount >= 100000000) {
      final eok = amount / 100000000;
      return '${eok.toStringAsFixed(eok % 1 == 0 ? 0 : 1)}억원';
    }
    if (amount >= 10000) {
      final man = amount / 10000;
      return '${man.toStringAsFixed(man % 1 == 0 ? 0 : 1)}만원';
    }
    return format(amount);
  }

  /// 최소 청약 가능 금액 계산
  static int calcMinSubscriptionAmount({
    required int confirmedPrice,
    required int minQty,
    required double depositRatio,
  }) {
    return (confirmedPrice * minQty * depositRatio).ceil();
  }
}
