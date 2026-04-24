import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils.format', () {
    test('천 단위 구분자 표시', () {
      expect(CurrencyUtils.format(1000), '1,000원');
      expect(CurrencyUtils.format(135000), '135,000원');
      expect(CurrencyUtils.format(12345678), '12,345,678원');
    });

    test('0원도 포맷', () {
      expect(CurrencyUtils.format(0), '0원');
    });

    test('음수도 포맷', () {
      expect(CurrencyUtils.format(-5000), '-5,000원');
    });
  });

  group('CurrencyUtils.formatShort', () {
    test('1만 미만은 그대로', () {
      expect(CurrencyUtils.formatShort(500), '500원');
      expect(CurrencyUtils.formatShort(9999), '9,999원');
    });

    test('1만~1억은 만원 단위', () {
      expect(CurrencyUtils.formatShort(10000), '1만원');
      expect(CurrencyUtils.formatShort(15000), '1.5만원');
      expect(CurrencyUtils.formatShort(1000000), '100만원');
    });

    test('1억 이상은 억원 단위', () {
      expect(CurrencyUtils.formatShort(100000000), '1억원');
      expect(CurrencyUtils.formatShort(150000000), '1.5억원');
    });
  });

  group('CurrencyUtils.calcMinSubscriptionAmount', () {
    test('청약가 × 수량 × 증거금비율', () {
      // 13,500 × 10 × 0.5 = 67,500
      expect(
        CurrencyUtils.calcMinSubscriptionAmount(
          confirmedPrice: 13500,
          minQty: 10,
          depositRatio: 0.5,
        ),
        67500,
      );
    });

    test('100% 증거금 (증거금 비율 1.0)', () {
      expect(
        CurrencyUtils.calcMinSubscriptionAmount(
          confirmedPrice: 50000,
          minQty: 10,
          depositRatio: 1.0,
        ),
        500000,
      );
    });

    test('소수점 발생 시 올림', () {
      // 12,345 × 10 × 0.5 = 61,725
      expect(
        CurrencyUtils.calcMinSubscriptionAmount(
          confirmedPrice: 12345,
          minQty: 10,
          depositRatio: 0.5,
        ),
        61725,
      );
    });
  });
}
