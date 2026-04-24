import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/data/models/ipo.dart';
import 'package:ipo_keeper/domain/ipo_list_sorting.dart';

IPO _ipo(
  String id, {
  DateTime? sub,
  DateTime? listing,
  DateTime? refund,
  IPOStatus status = IPOStatus.upcoming,
}) {
  return IPO(
    id: id,
    companyName: id,
    sector: '',
    businessSummary: '',
    subscriptionStart: sub,
    listingDate: listing,
    refundDate: refund,
    minSubscriptionQty: 10,
    depositRatio: 0.5,
    status: status,
  );
}

void main() {
  final today = DateTime(2026, 4, 23);

  group('sortByDDay', () {
    test('미래가 위, 가까운 미래가 아래, 과거가 맨 아래', () {
      final list = [
        _ipo('today', sub: today),
        _ipo('far_future', sub: DateTime(2026, 5, 20)),
        _ipo('past', sub: DateTime(2026, 4, 10)),
        _ipo('near_future', sub: DateTime(2026, 4, 25)),
      ];
      final sorted = sortByDDay(list, today);
      expect(
        sorted.map((e) => e.id).toList(),
        ['far_future', 'near_future', 'today', 'past'],
      );
    });

    test('subscriptionStart 없으면 listingDate, 없으면 refundDate 사용', () {
      final list = [
        _ipo('A', refund: DateTime(2026, 5, 1)),
        _ipo('B', listing: DateTime(2026, 4, 30)),
        _ipo('C', sub: DateTime(2026, 4, 25)),
      ];
      final sorted = sortByDDay(list, today);
      expect(sorted.map((e) => e.id), ['A', 'B', 'C']);
    });

    test('일정 완전 없으면 맨 아래', () {
      final list = [_ipo('nodate'), _ipo('has', sub: today)];
      final sorted = sortByDDay(list, today);
      expect(sorted.first.id, 'has');
      expect(sorted.last.id, 'nodate');
    });
  });

  group('findClosestDDayIndex', () {
    test('오늘에 가장 가까운 항목 인덱스 반환', () {
      final list = [
        _ipo('far', sub: DateTime(2026, 5, 20)),
        _ipo('near', sub: DateTime(2026, 4, 25)),
        _ipo('today', sub: today),
      ];
      expect(findClosestDDayIndex(list, today), 2);
    });

    test('과거/미래 중 더 가까운 쪽', () {
      final list = [
        _ipo('past3', sub: DateTime(2026, 4, 20)),
        _ipo('future10', sub: DateTime(2026, 5, 3)),
      ];
      expect(findClosestDDayIndex(list, today), 0); // past3이 |diff|=3으로 더 가까움
    });

    test('빈 리스트 → 0', () {
      expect(findClosestDDayIndex(const [], today), 0);
    });
  });

  group('IPOListFilter', () {
    test('label 한글', () {
      expect(IPOListFilter.all.label, '전체');
      expect(IPOListFilter.subscribing.label, '청약중');
      expect(IPOListFilter.upcoming.label, '청약예정');
      expect(IPOListFilter.listed.label, '상장완료');
    });

    test('matches: subscribing만 청약중', () {
      final sub = _ipo('a', status: IPOStatus.subscribing);
      final up = _ipo('b', status: IPOStatus.upcoming);
      expect(IPOListFilter.subscribing.matches(sub), isTrue);
      expect(IPOListFilter.subscribing.matches(up), isFalse);
    });

    test('matches: upcoming에는 forecasting도 포함', () {
      expect(
        IPOListFilter.upcoming.matches(_ipo('a', status: IPOStatus.forecasting)),
        isTrue,
      );
      expect(
        IPOListFilter.upcoming.matches(_ipo('a', status: IPOStatus.upcoming)),
        isTrue,
      );
      expect(
        IPOListFilter.upcoming.matches(_ipo('a', status: IPOStatus.subscribing)),
        isFalse,
      );
    });

    test('matches: listed에는 closed도 포함', () {
      expect(
        IPOListFilter.listed.matches(_ipo('a', status: IPOStatus.listed)),
        isTrue,
      );
      expect(
        IPOListFilter.listed.matches(_ipo('a', status: IPOStatus.closed)),
        isTrue,
      );
    });

    test('matches: all은 항상 true', () {
      for (final s in IPOStatus.values) {
        expect(IPOListFilter.all.matches(_ipo('x', status: s)), isTrue);
      }
    });
  });
}
