import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/data/models/subscription.dart';

void main() {
  group('SubscriptionStatus 순서', () {
    test('index 순서가 기대한 생애주기와 일치', () {
      expect(SubscriptionStatus.applied.index, 0);
      expect(SubscriptionStatus.allocated.index, 1);
      expect(SubscriptionStatus.refunded.index, 2);
      expect(SubscriptionStatus.listed.index, 3);
      expect(SubscriptionStatus.sold.index, 4);
    });
  });

  group('SubscriptionStatus label/nextAction', () {
    test('각 상태 한글 라벨', () {
      expect(SubscriptionStatus.applied.label, '청약완료');
      expect(SubscriptionStatus.allocated.label, '배정확인');
      expect(SubscriptionStatus.refunded.label, '환불완료');
      expect(SubscriptionStatus.listed.label, '상장대기');
      expect(SubscriptionStatus.sold.label, '매도완료');
    });

    test('nextAction이 다음 단계를 안내', () {
      expect(SubscriptionStatus.applied.nextAction, contains('배정'));
      expect(SubscriptionStatus.allocated.nextAction, contains('환불'));
      expect(SubscriptionStatus.refunded.nextAction, contains('상장'));
      expect(SubscriptionStatus.listed.nextAction, contains('매도'));
      expect(SubscriptionStatus.sold.nextAction, '완료');
    });
  });

  group('Subscription.copyWith', () {
    test('전달된 필드만 갱신', () {
      final original = Subscription(
        id: 1,
        ipoId: 'x',
        ipoName: 'A',
        broker: '미래에셋',
        appliedQty: 10,
        depositAmount: 50000,
        status: SubscriptionStatus.applied,
        createdAt: DateTime(2026, 4, 1),
      );
      final updated = original.copyWith(
        allocatedQty: 3,
        status: SubscriptionStatus.allocated,
      );

      expect(updated.id, 1);
      expect(updated.broker, '미래에셋');
      expect(updated.appliedQty, 10);
      expect(updated.allocatedQty, 3);
      expect(updated.status, SubscriptionStatus.allocated);
    });
  });
}
