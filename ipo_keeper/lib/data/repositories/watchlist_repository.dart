import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/personal_db.dart';
import 'personal_db_provider.dart';

/// 관심종목 저장소 (Drift 기반).
///
/// 기존의 StateNotifier 인터페이스는 더 이상 아니지만, 화면 코드가 보는
/// provider 이름([watchlistProvider], [isWatchedProvider])은 그대로 유지된다.
class WatchlistRepository {
  WatchlistRepository(this._db);

  final PersonalDb _db;

  Stream<Set<String>> watch() => _db.watchWatchlist();

  Future<void> toggle(String ipoId) async {
    final current = await _db.getWatchlist();
    if (current.contains(ipoId)) {
      await _db.removeWatch(ipoId);
    } else {
      await _db.addWatch(ipoId);
    }
  }

  Future<void> add(String ipoId) => _db.addWatch(ipoId);
  Future<void> remove(String ipoId) => _db.removeWatch(ipoId);
}

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepository(ref.watch(personalDbProvider));
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
