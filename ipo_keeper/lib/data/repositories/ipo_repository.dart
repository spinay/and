import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/local/dummy_data.dart';
import '../models/ipo.dart';

class IPORepository {
  // MVP: 더미 데이터 사용. 이후 Supabase 연동으로 교체
  List<IPO> getAll() => dummyIPOs;

  IPO? getById(String id) {
    try {
      return dummyIPOs.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<IPO> getByStatus(IPOStatus status) =>
      dummyIPOs.where((e) => e.status == status).toList();

  List<IPO> getTodayEvents(DateTime date) {
    return dummyIPOs.where((ipo) {
      final sub = ipo.subscriptionStart;
      final end = ipo.subscriptionEnd;
      final ref = ipo.refundDate;
      final lst = ipo.listingDate;
      bool sameDay(DateTime? d) =>
          d != null && d.year == date.year && d.month == date.month && d.day == date.day;
      return sameDay(sub) || sameDay(end) || sameDay(ref) || sameDay(lst);
    }).toList();
  }
}

final ipoRepositoryProvider = Provider<IPORepository>((ref) => IPORepository());

final ipoListProvider = Provider<List<IPO>>((ref) {
  return ref.watch(ipoRepositoryProvider).getAll();
});

final ipoByStatusProvider = Provider.family<List<IPO>, IPOStatus>((ref, status) {
  return ref.watch(ipoRepositoryProvider).getByStatus(status);
});

final ipoDetailProvider = Provider.family<IPO?, String>((ref, id) {
  return ref.watch(ipoRepositoryProvider).getById(id);
});
