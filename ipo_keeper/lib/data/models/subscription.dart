enum SubscriptionStatus {
  applied,    // 청약완료
  allocated,  // 배정확인
  refunded,   // 환불완료
  listed,     // 상장됨
  sold,       // 매도완료
}

extension SubscriptionStatusExt on SubscriptionStatus {
  String get label {
    switch (this) {
      case SubscriptionStatus.applied: return '청약완료';
      case SubscriptionStatus.allocated: return '배정확인';
      case SubscriptionStatus.refunded: return '환불완료';
      case SubscriptionStatus.listed: return '상장대기';
      case SubscriptionStatus.sold: return '매도완료';
    }
  }

  String get nextAction {
    switch (this) {
      case SubscriptionStatus.applied: return '배정 수량 입력하기';
      case SubscriptionStatus.allocated: return '환불금 확인 후 입력하기';
      case SubscriptionStatus.refunded: return '상장일 확인하기';
      case SubscriptionStatus.listed: return '매도 후 수익 기록하기';
      case SubscriptionStatus.sold: return '완료';
    }
  }
}

class Subscription {
  final int? id;
  final String ipoId;
  final String ipoName; // 조인 없이 표시용

  // 청약 단계
  final String? broker;
  final int? appliedQty;
  final int? depositAmount;

  // 배정 단계
  final int? allocatedQty;
  final int? refundAmount;

  // 매도 단계
  final int? sellPrice;
  final int? sellQty;
  final int? profitAmount;
  final double? profitRate;

  final SubscriptionStatus status;
  final String? memo;
  final DateTime createdAt;

  const Subscription({
    this.id,
    required this.ipoId,
    required this.ipoName,
    this.broker,
    this.appliedQty,
    this.depositAmount,
    this.allocatedQty,
    this.refundAmount,
    this.sellPrice,
    this.sellQty,
    this.profitAmount,
    this.profitRate,
    required this.status,
    this.memo,
    required this.createdAt,
  });

  Subscription copyWith({
    int? allocatedQty,
    int? refundAmount,
    int? sellPrice,
    int? sellQty,
    int? profitAmount,
    double? profitRate,
    SubscriptionStatus? status,
    String? memo,
  }) {
    return Subscription(
      id: id,
      ipoId: ipoId,
      ipoName: ipoName,
      broker: broker,
      appliedQty: appliedQty,
      depositAmount: depositAmount,
      allocatedQty: allocatedQty ?? this.allocatedQty,
      refundAmount: refundAmount ?? this.refundAmount,
      sellPrice: sellPrice ?? this.sellPrice,
      sellQty: sellQty ?? this.sellQty,
      profitAmount: profitAmount ?? this.profitAmount,
      profitRate: profitRate ?? this.profitRate,
      status: status ?? this.status,
      memo: memo ?? this.memo,
      createdAt: createdAt,
    );
  }
}
