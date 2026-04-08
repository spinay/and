import '../../core/utils/currency_utils.dart';

enum IPOStatus {
  upcoming,        // 청약 예정
  forecasting,     // 수요예측 중
  subscribing,     // 청약 중
  waitingListing,  // 상장 대기
  listed,          // 상장 완료
  closed,          // 종료
}

class IPO {
  final String id;
  final String companyName;
  final String sector;
  final String businessSummary;

  // 일정
  final DateTime? demandForecastStart;
  final DateTime? demandForecastEnd;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final DateTime? refundDate;
  final DateTime? listingDate;

  // 공모가
  final int? priceBandLow;
  final int? priceBandHigh;
  final int? confirmedPrice;

  // 청약 정보
  final int minSubscriptionQty;
  final double depositRatio; // 증거금 비율 (0.5 = 50%)

  // 경쟁률 / 주간사
  final double? competitionRate;
  final List<String> leadUnderwriters;

  final IPOStatus status;
  final DateTime? createdAt;

  const IPO({
    required this.id,
    required this.companyName,
    required this.sector,
    required this.businessSummary,
    this.demandForecastStart,
    this.demandForecastEnd,
    this.subscriptionStart,
    this.subscriptionEnd,
    this.refundDate,
    this.listingDate,
    this.priceBandLow,
    this.priceBandHigh,
    this.confirmedPrice,
    required this.minSubscriptionQty,
    required this.depositRatio,
    this.competitionRate,
    this.leadUnderwriters = const [],
    required this.status,
    this.createdAt,
  });

  /// 최소 청약 가능 금액 (확정가 기준)
  int? get minSubscriptionAmount {
    if (confirmedPrice == null) return null;
    return CurrencyUtils.calcMinSubscriptionAmount(
      confirmedPrice: confirmedPrice!,
      minQty: minSubscriptionQty,
      depositRatio: depositRatio,
    );
  }

  /// 공모가 밴드 텍스트
  String get priceBandText {
    if (confirmedPrice != null) {
      return '${CurrencyUtils.format(confirmedPrice!)} (확정)';
    }
    if (priceBandLow != null && priceBandHigh != null) {
      return '${CurrencyUtils.format(priceBandLow!)} ~ ${CurrencyUtils.format(priceBandHigh!)}';
    }
    return '미정';
  }
}
