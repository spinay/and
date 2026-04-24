import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/notification_service.dart';
import '../local/personal_db.dart';
import '../models/ipo.dart';
import 'catalog_repository.dart';
import 'personal_db_provider.dart';

/// 관심종목 저장소 (Drift 기반).
///
/// - DB에 관심종목 set을 저장
/// - 토글/추가/삭제 시 [NotificationService]로 알림 스케줄을 즉시 반영
///   (과거 시점: 앱 재시작 때만 반영되던 문제 해결)
class WatchlistRepository {
  WatchlistRepository({
    required PersonalDb db,
    required List<IPO> Function() catalogLookup,
    IpoNotificationScheduler? notifications,
  })  : _db = db,
        _catalogLookup = catalogLookup,
        _notifications = notifications ?? NotificationService.instance;

  final PersonalDb _db;
  final List<IPO> Function() _catalogLookup;
  final IpoNotificationScheduler _notifications;

  Stream<Set<String>> watch() => _db.watchWatchlist();

  Future<void> toggle(String ipoId) async {
    final current = await _db.getWatchlist();
    if (current.contains(ipoId)) {
      await remove(ipoId);
    } else {
      await add(ipoId);
    }
  }

  Future<void> add(String ipoId) async {
    await _db.addWatch(ipoId);
    final ipo = _findIpo(ipoId);
    if (ipo != null) {
      // 첫 관심 등록 시점에 알림 권한 요청 (Android 13+ 필수).
      // NotificationService가 아닐 땐 no-op.
      final ns = _notifications;
      if (ns is NotificationService) {
        await ns.requestPermissions();
      }
      await _notifications.scheduleForIpo(ipo);
    }
  }

  Future<void> remove(String ipoId) async {
    await _db.removeWatch(ipoId);
    final ipo = _findIpo(ipoId);
    if (ipo != null) {
      await _notifications.cancelForIpo(ipo);
    }
  }

  IPO? _findIpo(String id) {
    for (final ipo in _catalogLookup()) {
      if (ipo.id == id) return ipo;
    }
    return null;
  }
}

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepository(
    db: ref.watch(personalDbProvider),
    catalogLookup: () => ref.read(catalogRepositoryProvider),
  );
});

/// 관심종목 set을 스트림으로 노출. Drift 변경 시 자동 재빌드.
final watchlistProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(watchlistRepositoryProvider).watch();
});

/// 특정 IPO가 관심종목인지. 화면에서 family로 사용.
final isWatchedProvider = Provider.family<bool, String>((ref, ipoId) {
  final async = ref.watch(watchlistProvider);
  return async.maybeWhen(
    data: (set) => set.contains(ipoId),
    orElse: () => false,
  );
});
