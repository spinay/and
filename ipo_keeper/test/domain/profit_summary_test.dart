import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/data/models/subscription.dart';
import 'package:ipo_keeper/domain/profit_summary.dart';

Subscription _s({
  required SubscriptionStatus status,
  int? profit,
  int? deposit,
}) {
  return Subscription(
    id: null,
    ipoId: 'x',
    ipoName: 'x',
    depositAmount: deposit,
    profitAmount: profit,
    status: status,
    createdAt: DateTime(2026, 4, 1),
  );
}

void main() {
  group('ProfitSummary.from', () {
    test('빈 리스트 → 모든 값 0', () {
      final s = ProfitSummary.from(const []);
      expect(s.totalProfit, 0);
      expect(s.totalDeposit, 0);
      expect(s.totalCount, 0);
      expect(s.avgProfit, 0);
      expect(s.winRate, 0.0);
      expect(s.soldCount, 0);
      expect(s.activeCount, 0);
      expect(s.activeDeposit, 0);
    });

    test('진행중만 있을 땐 sold 관련 지표 0', () {
      final s = ProfitSummary.from([
        _s(status: SubscriptionStatus.applied, deposit: 50000),
        _s(status: SubscriptionStatus.allocated, deposit: 100000),
      ]);
      expect(s.totalCount, 2);
      expect(s.activeCount, 2);
      expect(s.activeDeposit, 150000);
      expect(s.totalDeposit, 150000);
      expect(s.soldCount, 0);
      expect(s.totalProfit, 0);
      expect(s.winRate, 0.0);
    });

    test('매도 3건 중 2건 양수 → 승률 66.6..%', () {
      final s = ProfitSummary.from([
        _s(status: SubscriptionStatus.sold, profit: 10000, deposit: 100000),
        _s(status: SubscriptionStatus.sold, profit: 20000, deposit: 100000),
        _s(status: SubscriptionStatus.sold, profit: -5000, deposit: 100000),
      ]);
      expect(s.soldCount, 3);
      expect(s.totalProfit, 25000);
      expect(s.avgProfit, 25000 ~/ 3);
      expect(s.winRate, closeTo(66.66, 0.1));
    });

    test('profit 0은 승에 미포함 (> 0만 승)', () {
      final s = ProfitSummary.from([
        _s(status: SubscriptionStatus.sold, profit: 0),
        _s(status: SubscriptionStatus.sold, profit: 100),
      ]);
      expect(s.winRate, 50.0);
    });

    test('진행중 + 완료 혼합: totalDeposit = 전체 증거금 합', () {
      final s = ProfitSummary.from([
        _s(status: SubscriptionStatus.applied, deposit: 50000),
        _s(status: SubscriptionStatus.sold, deposit: 100000, profit: 30000),
      ]);
      expect(s.totalDeposit, 150000);
      expect(s.activeDeposit, 50000);
      expect(s.activeCount, 1);
      expect(s.soldCount, 1);
      expect(s.totalProfit, 30000);
    });
  });
}
