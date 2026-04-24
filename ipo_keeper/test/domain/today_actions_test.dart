import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/data/models/ipo.dart';
import 'package:ipo_keeper/data/models/subscription.dart';
import 'package:ipo_keeper/domain/today_actions.dart';

IPO _ipo({
  String id = 'x',
  DateTime? demand,
  DateTime? subStart,
  DateTime? subEnd,
  DateTime? refund,
  DateTime? listing,
}) {
  return IPO(
    id: id,
    companyName: id,
    sector: '',
    businessSummary: '',
    demandForecastStart: demand,
    subscriptionStart: subStart,
    subscriptionEnd: subEnd,
    refundDate: refund,
    listingDate: listing,
    minSubscriptionQty: 10,
    depositRatio: 0.5,
    status: IPOStatus.subscribing,
  );
}

Subscription _sub(String ipoId) => Subscription(
      id: 1,
      ipoId: ipoId,
      ipoName: ipoId,
      status: SubscriptionStatus.applied,
      createdAt: DateTime(2026, 4, 1),
    );

void main() {
  group('computeTodayActions', () {
    final today = DateTime(2026, 4, 23);

    test('오늘 날짜 이벤트 없으면 빈 리스트', () {
      final actions = computeTodayActions(
        ipos: [_ipo(subStart: DateTime(2026, 5, 1))],
        subscriptions: const [],
        today: today,
      );
      expect(actions, isEmpty);
    });

    test('오늘이 청약 시작일이면 subscriptionStart 액션', () {
      final actions = computeTodayActions(
        ipos: [_ipo(id: 'A', subStart: today)],
        subscriptions: const [],
        today: today,
      );
      expect(actions.length, 1);
      expect(actions.first.type, TodayActionType.subscriptionStart);
      expect(actions.first.ipo.id, 'A');
    });

    test('오늘이 청약 마감일이면 subscriptionEnd 액션', () {
      final actions = computeTodayActions(
        ipos: [_ipo(id: 'A', subEnd: today)],
        subscriptions: const [],
        today: today,
      );
      expect(actions.map((e) => e.type), [TodayActionType.subscriptionEnd]);
    });

    test('수요예측 시작일 감지', () {
      final actions = computeTodayActions(
        ipos: [_ipo(id: 'A', demand: today)],
        subscriptions: const [],
        today: today,
      );
      expect(actions.map((e) => e.type), [TodayActionType.demandForecast]);
    });

    test('내 청약이 있는 IPO만 환불/상장 알림', () {
      final ipoWithMine = _ipo(id: 'mine', refund: today, listing: today);
      final ipoWithoutMine = _ipo(id: 'other', refund: today, listing: today);
      final actions = computeTodayActions(
        ipos: [ipoWithMine, ipoWithoutMine],
        subscriptions: [_sub('mine')],
        today: today,
      );

      // 내 것만 refund/listing 2건
      expect(actions.length, 2);
      expect(actions.every((a) => a.ipo.id == 'mine'), isTrue);
      expect(
        actions.map((a) => a.type).toSet(),
        {TodayActionType.refund, TodayActionType.listing},
      );
    });

    test('catalog에 없는 고아 Subscription은 무시', () {
      final actions = computeTodayActions(
        ipos: const [],
        subscriptions: [_sub('ghost')],
        today: today,
      );
      expect(actions, isEmpty);
    });

    test('같은 IPO가 시작+마감이 같은 날이면 액션 2건', () {
      final actions = computeTodayActions(
        ipos: [_ipo(id: 'A', subStart: today, subEnd: today)],
        subscriptions: const [],
        today: today,
      );
      expect(actions.length, 2);
    });
  });
}
