import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/data/local/personal_db.dart';
import 'package:ipo_keeper/data/models/ipo.dart';
import 'package:ipo_keeper/data/models/subscription.dart';
import 'package:ipo_keeper/data/repositories/subscription_repository.dart';

/// in-memory Drift DB 위에서 SubscriptionRepository의 핵심 로직을 검증한다.
void main() {
  late PersonalDb db;
  late SubscriptionRepository repo;

  setUp(() {
    db = PersonalDb.forTesting(NativeDatabase.memory());
    repo = SubscriptionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  IPO makeIpo({
    String id = 'x',
    DateTime? refund,
    DateTime? listing,
  }) {
    return IPO(
      id: id,
      companyName: 'x',
      sector: '',
      businessSummary: '',
      refundDate: refund,
      listingDate: listing,
      minSubscriptionQty: 10,
      depositRatio: 0.5,
      status: IPOStatus.subscribing,
    );
  }

  Subscription baseSub({
    String ipoId = 'x',
    SubscriptionStatus status = SubscriptionStatus.applied,
  }) {
    return Subscription(
      ipoId: ipoId,
      ipoName: '테스트종목',
      status: status,
      createdAt: DateTime(2026, 4, 10),
    );
  }

  group('CRUD', () {
    test('add → watch 스트림에 반영', () async {
      final id = await repo.add(baseSub());
      expect(id, isNonZero);

      final list = await repo.watch().first;
      expect(list.length, 1);
      expect(list.first.ipoId, 'x');
      expect(list.first.status, SubscriptionStatus.applied);
    });

    test('update 후 값 반영', () async {
      final id = await repo.add(baseSub());
      final list = await repo.watch().first;
      final updated = list.first.copyWith(
        allocatedQty: 3,
        status: SubscriptionStatus.allocated,
      );
      final withId = Subscription(
        id: id,
        ipoId: updated.ipoId,
        ipoName: updated.ipoName,
        appliedQty: updated.appliedQty,
        depositAmount: updated.depositAmount,
        allocatedQty: updated.allocatedQty,
        status: updated.status,
        createdAt: updated.createdAt,
      );
      await repo.update(withId);

      final after = await repo.watch().first;
      expect(after.first.allocatedQty, 3);
      expect(after.first.status, SubscriptionStatus.allocated);
    });

    test('delete 후 사라짐', () async {
      final id = await repo.add(baseSub());
      await repo.delete(id);
      final list = await repo.watch().first;
      expect(list, isEmpty);
    });
  });

  group('autoTransition', () {
    test('환불일이 지나면 applied → refunded', () async {
      await repo.add(baseSub(status: SubscriptionStatus.applied));
      final ipo = makeIpo(refund: DateTime(2026, 4, 15));

      final changed = await repo.autoTransition(
        catalog: [ipo],
        now: DateTime(2026, 4, 20),
      );

      expect(changed, 1);
      final list = await repo.watch().first;
      expect(list.first.status, SubscriptionStatus.refunded);
    });

    test('환불일+상장일 모두 지나면 refunded → listed (한 번에 2단계 승격 가능)', () async {
      await repo.add(baseSub(status: SubscriptionStatus.applied));
      final ipo = makeIpo(
        refund: DateTime(2026, 4, 15),
        listing: DateTime(2026, 4, 18),
      );

      final changed = await repo.autoTransition(
        catalog: [ipo],
        now: DateTime(2026, 4, 20),
      );

      expect(changed, 1);
      final list = await repo.watch().first;
      expect(list.first.status, SubscriptionStatus.listed);
    });

    test('환불일 전이면 상태 유지', () async {
      await repo.add(baseSub(status: SubscriptionStatus.applied));
      final ipo = makeIpo(refund: DateTime(2026, 5, 1));

      final changed = await repo.autoTransition(
        catalog: [ipo],
        now: DateTime(2026, 4, 20),
      );

      expect(changed, 0);
      final list = await repo.watch().first;
      expect(list.first.status, SubscriptionStatus.applied);
    });

    test('sold 상태는 되돌리지 않음', () async {
      await repo.add(baseSub(status: SubscriptionStatus.sold));
      final ipo = makeIpo(
        refund: DateTime(2026, 4, 15),
        listing: DateTime(2026, 4, 18),
      );

      final changed = await repo.autoTransition(
        catalog: [ipo],
        now: DateTime(2026, 4, 20),
      );

      expect(changed, 0);
      final list = await repo.watch().first;
      expect(list.first.status, SubscriptionStatus.sold);
    });

    test('catalog에 없는 고아 기록은 무시', () async {
      await repo.add(baseSub(ipoId: 'ghost'));
      final changed = await repo.autoTransition(
        catalog: const [],
        now: DateTime(2026, 4, 20),
      );
      expect(changed, 0);
    });
  });
}
