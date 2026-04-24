import '../data/models/subscription.dart';

/// 수익 화면에서 쓰는 집계 결과.
class ProfitSummary {
  /// 매도 완료된 건의 총 수익 (세전).
  final int totalProfit;

  /// 모든 청약 건의 총 납입 증거금.
  final int totalDeposit;

  /// 청약 총 건수 (진행중 + 완료).
  final int totalCount;

  /// 매도 완료된 건의 건당 평균 수익.
  final int avgProfit;

  /// 매도 완료 건 중 수익 > 0 인 비율 (0~100).
  final double winRate;

  /// 매도 완료 건수.
  final int soldCount;

  /// 진행중(아직 매도 안 한) 건수.
  final int activeCount;

  /// 진행중 건의 납입 증거금 합계.
  final int activeDeposit;

  const ProfitSummary({
    required this.totalProfit,
    required this.totalDeposit,
    required this.totalCount,
    required this.avgProfit,
    required this.winRate,
    required this.soldCount,
    required this.activeCount,
    required this.activeDeposit,
  });

  /// [subscriptions] 리스트로부터 요약을 계산한다.
  factory ProfitSummary.from(List<Subscription> subscriptions) {
    final sold = subscriptions
        .where((s) => s.status == SubscriptionStatus.sold)
        .toList();
    final active = subscriptions
        .where((s) => s.status != SubscriptionStatus.sold)
        .toList();

    final totalProfit = sold.fold(0, (sum, s) => sum + (s.profitAmount ?? 0));
    final totalDeposit =
        subscriptions.fold(0, (sum, s) => sum + (s.depositAmount ?? 0));
    final winCount = sold.where((s) => (s.profitAmount ?? 0) > 0).length;
    final winRate = sold.isEmpty ? 0.0 : (winCount / sold.length) * 100;
    final avgProfit = sold.isEmpty ? 0 : totalProfit ~/ sold.length;
    final activeDeposit =
        active.fold(0, (sum, s) => sum + (s.depositAmount ?? 0));

    return ProfitSummary(
      totalProfit: totalProfit,
      totalDeposit: totalDeposit,
      totalCount: subscriptions.length,
      avgProfit: avgProfit,
      winRate: winRate,
      soldCount: sold.length,
      activeCount: active.length,
      activeDeposit: activeDeposit,
    );
  }
}
