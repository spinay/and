import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ipo.dart';
import 'catalog_repository.dart';

/// IPO 데이터 조회 진입점.
///
/// [CatalogRepository]의 state(`List<IPO>`)를 받아 화면이 쓰기 좋은 형태로
/// 노출한다. catalog가 갱신되면 이 provider들도 자동으로 다시 계산된다.
class IPORepository {
  IPORepository(this._all);

  final List<IPO> _all;

  List<IPO> getAll() => _all;

  IPO? getById(String id) {
    for (final ipo in _all) {
      if (ipo.id == id) return ipo;
    }
    return null;
  }

  List<IPO> getByStatus(IPOStatus status) =>
      _all.where((e) => e.status == status).toList();

  List<IPO> getTodayEvents(DateTime date) {
    bool sameDay(DateTime? d) =>
        d != null &&
        d.year == date.year &&
        d.month == date.month &&
        d.day == date.day;

    return _all.where((ipo) {
      return sameDay(ipo.subscriptionStart) ||
          sameDay(ipo.subscriptionEnd) ||
          sameDay(ipo.refundDate) ||
          sameDay(ipo.listingDate);
    }).toList();
  }
}

final ipoRepositoryProvider = Provider<IPORepository>((ref) {
  final all = ref.watch(catalogRepositoryProvider);
  return IPORepository(all);
});

final ipoListProvider = Provider<List<IPO>>((ref) {
  return ref.watch(ipoRepositoryProvider).getAll();
});

final ipoByStatusProvider = Provider.family<List<IPO>, IPOStatus>((ref, status) {
  return ref.watch(ipoRepositoryProvider).getByStatus(status);
});

final ipoDetailProvider = Provider.family<IPO?, String>((ref, id) {
  return ref.watch(ipoRepositoryProvider).getById(id);
});
