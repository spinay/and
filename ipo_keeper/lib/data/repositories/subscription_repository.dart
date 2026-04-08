import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/personal_db.dart';
import '../models/subscription.dart';
import 'personal_db_provider.dart';

/// 청약기록 저장소 (Drift 기반).
///
/// 외부 인터페이스는 [Subscription] 도메인 모델을 쓰고, 내부적으로만
/// [SubscriptionRow] ↔ [Subscription] 매핑을 수행한다.
class SubscriptionRepository {
  SubscriptionRepository(this._db);

  final PersonalDb _db;

  Stream<List<Subscription>> watch() {
    return _db.watchSubscriptions().map(
          (rows) => rows.map(_rowToModel).toList(),
        );
  }

  Future<int> add(Subscription s) {
    return _db.insertSubscription(_modelToCompanion(s));
  }

  Future<void> update(Subscription s) async {
    final id = s.id;
    if (id == null) {
      throw StateError('Subscription.id is null — use add() for new rows');
    }
    await _db.updateSubscription(_modelToRow(s, id));
  }

  Future<void> delete(int id) => _db.deleteSubscription(id);

  // ─── mappers ─────────────────────────────────────────────

  Subscription _rowToModel(SubscriptionRow r) => Subscription(
        id: r.id,
        ipoId: r.ipoId,
        ipoName: r.ipoName,
        broker: r.broker,
        appliedQty: r.appliedQty,
        depositAmount: r.depositAmount,
        allocatedQty: r.allocatedQty,
        refundAmount: r.refundAmount,
        sellPrice: r.sellPrice,
        sellQty: r.sellQty,
        profitAmount: r.profitAmount,
        profitRate: r.profitRate,
        status: _parseStatus(r.status),
        memo: r.memo,
        createdAt: r.createdAt,
      );

  SubscriptionRecordsCompanion _modelToCompanion(Subscription s) {
    return SubscriptionRecordsCompanion.insert(
      ipoId: s.ipoId,
      ipoName: s.ipoName,
      broker: Value(s.broker),
      appliedQty: Value(s.appliedQty),
      depositAmount: Value(s.depositAmount),
      allocatedQty: Value(s.allocatedQty),
      refundAmount: Value(s.refundAmount),
      sellPrice: Value(s.sellPrice),
      sellQty: Value(s.sellQty),
      profitAmount: Value(s.profitAmount),
      profitRate: Value(s.profitRate),
      status: s.status.name,
      memo: Value(s.memo),
      createdAt: s.createdAt,
    );
  }

  SubscriptionRow _modelToRow(Subscription s, int id) => SubscriptionRow(
        id: id,
        ipoId: s.ipoId,
        ipoName: s.ipoName,
        broker: s.broker,
        appliedQty: s.appliedQty,
        depositAmount: s.depositAmount,
        allocatedQty: s.allocatedQty,
        refundAmount: s.refundAmount,
        sellPrice: s.sellPrice,
        sellQty: s.sellQty,
        profitAmount: s.profitAmount,
        profitRate: s.profitRate,
        status: s.status.name,
        memo: s.memo,
        createdAt: s.createdAt,
      );

  SubscriptionStatus _parseStatus(String raw) {
    for (final s in SubscriptionStatus.values) {
      if (s.name == raw) return s;
    }
    return SubscriptionStatus.applied; // fallback
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(personalDbProvider));
});

/// 청약기록 리스트를 스트림으로 노출. Drift 변경 시 자동 재빌드.
final subscriptionListProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watch();
});
