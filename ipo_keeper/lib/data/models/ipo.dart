import '../../core/utils/currency_utils.dart';

enum IPOStatus {
  upcoming,        // 청약 예정
  forecasting,     // 수요예측 중
  subscribing,     // 청약 중
  waitingListing,  // 상장 대기
  listed,          // 상장 완료
  closed,          // 종료
}

extension IPOStatusJson on IPOStatus {
  String get jsonValue => name;

  static IPOStatus fromJson(String? raw) {
    if (raw == null) return IPOStatus.upcoming;
    for (final s in IPOStatus.values) {
      if (s.name == raw) return s;
    }
    return IPOStatus.upcoming;
  }
}

class IPO {
  /// canonical_key. 형식: 'YYYY-MM-DD_종목명'
  /// 청약 기록과 영구적으로 연결되는 키. JSON 갱신 후에도 안정적.
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

  /// data-pipeline이 만든 JSON에서 IPO를 만든다.
  /// JSON은 snake_case, Dart는 camelCase.
  factory IPO.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? v) {
      if (v == null) return null;
      if (v is! String || v.isEmpty) return null;
      return DateTime.tryParse(v);
    }

    int? parseInt(Object? v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    double? parseDouble(Object? v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    List<String> parseUnderwriters(Object? v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    return IPO(
      id: json['canonical_key'] as String,
      companyName: json['company_name'] as String,
      sector: (json['sector'] as String?) ?? '',
      businessSummary: (json['business_summary'] as String?) ?? '',
      demandForecastStart: parseDate(json['demand_start']),
      demandForecastEnd: parseDate(json['demand_end']),
      subscriptionStart: parseDate(json['subscription_start']),
      subscriptionEnd: parseDate(json['subscription_end']),
      refundDate: parseDate(json['refund_date']),
      listingDate: parseDate(json['listing_date']),
      priceBandLow: parseInt(json['price_band_low']),
      priceBandHigh: parseInt(json['price_band_high']),
      confirmedPrice: parseInt(json['confirmed_price']),
      minSubscriptionQty: parseInt(json['min_subscription_qty']) ?? 10,
      depositRatio: parseDouble(json['deposit_ratio']) ?? 0.5,
      competitionRate: parseDouble(json['competition_rate']),
      leadUnderwriters: parseUnderwriters(json['underwriters']),
      status: IPOStatusJson.fromJson(json['status'] as String?),
    );
  }
}
