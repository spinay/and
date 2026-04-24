import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/data/models/ipo.dart';

void main() {
  group('IPO.fromJson', () {
    test('전체 필드 매핑', () {
      final ipo = IPO.fromJson({
        'canonical_key': '2026-04-21_클라우드원',
        'company_name': '클라우드원',
        'sector': 'IT/소프트웨어',
        'business_summary': 'SaaS',
        'demand_start': '2026-04-14',
        'demand_end': '2026-04-15',
        'subscription_start': '2026-04-21',
        'subscription_end': '2026-04-22',
        'refund_date': '2026-04-24',
        'listing_date': '2026-04-28',
        'price_band_low': 12000,
        'price_band_high': 14000,
        'confirmed_price': 13500,
        'min_subscription_qty': 10,
        'deposit_ratio': 0.5,
        'underwriters': ['미래에셋증권', 'NH투자증권'],
        'competition_rate': 892.3,
        'status': 'subscribing',
      });

      expect(ipo.id, '2026-04-21_클라우드원');
      expect(ipo.companyName, '클라우드원');
      expect(ipo.subscriptionStart, DateTime(2026, 4, 21));
      expect(ipo.confirmedPrice, 13500);
      expect(ipo.minSubscriptionQty, 10);
      expect(ipo.depositRatio, 0.5);
      expect(ipo.leadUnderwriters, ['미래에셋증권', 'NH투자증권']);
      expect(ipo.status, IPOStatus.subscribing);
    });

    test('확정가 없으면 minSubscriptionAmount == null', () {
      final ipo = IPO.fromJson({
        'canonical_key': 'x',
        'company_name': '',
        'min_subscription_qty': 10,
        'deposit_ratio': 0.5,
      });
      expect(ipo.minSubscriptionAmount, isNull);
      expect(ipo.priceBandText, '미정');
    });

    test('확정가 있으면 최소청약금 계산', () {
      final ipo = IPO.fromJson({
        'canonical_key': 'x',
        'company_name': '',
        'confirmed_price': 10000,
        'min_subscription_qty': 10,
        'deposit_ratio': 0.5,
      });
      // 10000 * 10 * 0.5 = 50000
      expect(ipo.minSubscriptionAmount, 50000);
      expect(ipo.priceBandText, '10,000원 (확정)');
    });

    test('확정가 없고 밴드만 있으면 밴드 표시', () {
      final ipo = IPO.fromJson({
        'canonical_key': 'x',
        'company_name': '',
        'price_band_low': 8000,
        'price_band_high': 10000,
        'min_subscription_qty': 20,
        'deposit_ratio': 0.5,
      });
      expect(ipo.priceBandText, '8,000원 ~ 10,000원');
      expect(ipo.minSubscriptionAmount, isNull);
    });

    test('알 수 없는 status는 upcoming으로 fallback', () {
      final ipo = IPO.fromJson({
        'canonical_key': 'x',
        'company_name': '',
        'min_subscription_qty': 10,
        'deposit_ratio': 0.5,
        'status': 'nonexistent',
      });
      expect(ipo.status, IPOStatus.upcoming);
    });

    test('min_subscription_qty 없으면 기본값 10, deposit_ratio 기본값 0.5', () {
      final ipo = IPO.fromJson({
        'canonical_key': 'x',
        'company_name': '',
      });
      expect(ipo.minSubscriptionQty, 10);
      expect(ipo.depositRatio, 0.5);
    });
  });
}
