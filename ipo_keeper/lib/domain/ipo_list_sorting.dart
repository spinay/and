import '../data/models/ipo.dart';

/// D-day 기준으로 IPO 리스트를 정렬한다.
/// - 먼 미래(위) → 가까운 미래 → 오늘 → 최근 과거 → 먼 과거(아래)
/// - 기준 날짜는 subscriptionStart, 없으면 listingDate, 없으면 refundDate
/// - 위 3개 모두 null이면 맨 아래로 정렬
List<IPO> sortByDDay(List<IPO> list, DateTime today) {
  final base = DateTime(today.year, today.month, today.day);

  int score(IPO ipo) {
    final d = ipo.subscriptionStart ?? ipo.listingDate ?? ipo.refundDate;
    if (d == null) return -999999;
    return d.difference(base).inDays;
  }

  final sorted = List<IPO>.from(list);
  sorted.sort((a, b) => score(b).compareTo(score(a)));
  return sorted;
}

/// 오늘과 가장 가까운 (절댓값 최소) IPO의 인덱스를 찾는다.
/// 리스트가 비어있으면 0을 반환.
int findClosestDDayIndex(List<IPO> sorted, DateTime today) {
  if (sorted.isEmpty) return 0;
  final base = DateTime(today.year, today.month, today.day);

  int bestIdx = 0;
  int bestAbs = 999999;
  for (int i = 0; i < sorted.length; i++) {
    final d = sorted[i].subscriptionStart ??
        sorted[i].listingDate ??
        sorted[i].refundDate;
    if (d == null) continue;
    final diff = d.difference(base).inDays.abs();
    if (diff < bestAbs) {
      bestAbs = diff;
      bestIdx = i;
    }
  }
  return bestIdx;
}

/// IPO list 탭의 필터 라벨.
enum IPOListFilter { all, subscribing, upcoming, listed }

extension IPOListFilterLabel on IPOListFilter {
  String get label {
    switch (this) {
      case IPOListFilter.all:
        return '전체';
      case IPOListFilter.subscribing:
        return '청약중';
      case IPOListFilter.upcoming:
        return '청약예정';
      case IPOListFilter.listed:
        return '상장완료';
    }
  }

  bool matches(IPO ipo) {
    switch (this) {
      case IPOListFilter.all:
        return true;
      case IPOListFilter.subscribing:
        return ipo.status == IPOStatus.subscribing;
      case IPOListFilter.upcoming:
        return ipo.status == IPOStatus.upcoming ||
            ipo.status == IPOStatus.forecasting;
      case IPOListFilter.listed:
        return ipo.status == IPOStatus.listed ||
            ipo.status == IPOStatus.closed;
    }
  }
}
