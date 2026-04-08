import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ipo.dart';
import 'catalog_repository.dart';

/// IPO 데이터 조회 진입점.
///
/// [CatalogRepository]의 메모리 캐시를 sync하게 노출한다. 화면 코드는
/// 이 클래스만 알면 되고, 데이터 출처(JSON/네트워크/캐시)는 신경 쓰지 않는다.
class IPORepository {
  IPORepository(this._catalog);

  final CatalogRepository _catalog;

  List<IPO> getAll() => _catalog.cache;

  IPO? getById(String id) {
    for (final ipo in _catalog.cache) {
      if (ipo.id == id) return ipo;
    }
    return null;
  }

  List<IPO> getByStatus(IPOStatus status) =>
      _catalog.cache.where((e) => e.status == status).toList();

  List<IPO> getTodayEvents(DateTime date) {
    bool sameDay(DateTime? d) =>
        d != null &&
        d.year == date.year &&
        d.month == date.month &&
        d.day == date.day;

    return _catalog.cache.where((ipo) {
      return sameDay(ipo.subscriptionStart) ||
          sameDay(ipo.subscriptionEnd) ||
          sameDay(ipo.refundDate) ||
          sameDay(ipo.listingDate);
    }).toList();
  }
}

final ipoRepositoryProvider = Provider<IPORepository>((ref) {
  return IPORepository(ref.watch(catalogRepositoryProvider));
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
