import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';

class SubscriptionRepository extends StateNotifier<List<Subscription>> {
  SubscriptionRepository() : super(_dummySubscriptions);

  void add(Subscription subscription) {
    state = [...state, subscription];
  }

  void update(Subscription updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
  }

  void delete(int id) {
    state = state.where((s) => s.id != id).toList();
  }

  List<Subscription> getActive() =>
      state.where((s) => s.status != SubscriptionStatus.sold).toList();

  List<Subscription> getCompleted() =>
      state.where((s) => s.status == SubscriptionStatus.sold).toList();

  int get totalProfit => state
      .where((s) => s.profitAmount != null)
      .fold(0, (sum, s) => sum + s.profitAmount!);
}

// 더미 청약 기록 (다음 단계에서 Drift DB로 교체 예정)
final _dummySubscriptions = <Subscription>[
  Subscription(
    id: 1,
    ipoId: '2026-04-07_그린에너지솔루션',
    ipoName: '그린에너지솔루션',
    broker: '미래에셋증권',
    appliedQty: 20,
    depositAmount: 55000,
    allocatedQty: 3,
    refundAmount: 22000,
    status: SubscriptionStatus.refunded,
    createdAt: DateTime(2026, 4, 7),
  ),
  Subscription(
    id: 2,
    ipoId: '2026-04-14_클라우드원',
    ipoName: '클라우드원',
    broker: 'NH투자증권',
    appliedQty: 10,
    depositAmount: 67500,
    status: SubscriptionStatus.applied,
    createdAt: DateTime(2026, 4, 14),
  ),
];

final subscriptionRepositoryProvider =
    StateNotifierProvider<SubscriptionRepository, List<Subscription>>(
  (ref) => SubscriptionRepository(),
);
