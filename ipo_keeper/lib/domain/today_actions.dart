import '../core/utils/date_utils.dart';
import '../data/models/ipo.dart';
import '../data/models/subscription.dart';

/// 홈 화면에 오늘 표시할 액션 타입.
enum TodayActionType {
  demandForecast,      // 수요예측 시작
  subscriptionStart,   // 청약 시작
  subscriptionEnd,     // 청약 마감
  refund,              // 환불일 (내 청약)
  listing,             // 상장일 (내 청약)
}

/// 홈 화면 "오늘 할 일" 한 건.
class TodayAction {
  final IPO ipo;
  final TodayActionType type;
  final Subscription? sub;
  const TodayAction({required this.ipo, required this.type, this.sub});
}

/// [today] 기준 "오늘 할 일" 목록을 계산한다.
///
/// - 관심·전체 IPO: 수요예측/청약 시작·마감
/// - 내 청약 기록이 있는 IPO: 환불·상장일
///
/// catalog에 없는 고아 청약 기록은 skip.
List<TodayAction> computeTodayActions({
  required List<IPO> ipos,
  required List<Subscription> subscriptions,
  required DateTime today,
}) {
  final actions = <TodayAction>[];
  bool same(DateTime? d) => d != null && AppDateUtils.isSameDay(d, today);

  for (final ipo in ipos) {
    if (same(ipo.demandForecastStart)) {
      actions.add(TodayAction(ipo: ipo, type: TodayActionType.demandForecast));
    }
    if (same(ipo.subscriptionStart)) {
      actions.add(
        TodayAction(ipo: ipo, type: TodayActionType.subscriptionStart),
      );
    }
    if (same(ipo.subscriptionEnd)) {
      actions.add(
        TodayAction(ipo: ipo, type: TodayActionType.subscriptionEnd),
      );
    }
  }

  for (final sub in subscriptions) {
    IPO? ipo;
    for (final i in ipos) {
      if (i.id == sub.ipoId) {
        ipo = i;
        break;
      }
    }
    if (ipo == null) continue;
    if (same(ipo.refundDate)) {
      actions.add(TodayAction(ipo: ipo, type: TodayActionType.refund, sub: sub));
    }
    if (same(ipo.listingDate)) {
      actions.add(
        TodayAction(ipo: ipo, type: TodayActionType.listing, sub: sub),
      );
    }
  }
  return actions;
}
