import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistRepository extends StateNotifier<Set<String>> {
  WatchlistRepository()
      : super({
          '2026-04-14_클라우드원',
          '2026-04-16_바이오넥스트',
        });

  void toggle(String ipoId) {
    if (state.contains(ipoId)) {
      state = {...state}..remove(ipoId);
    } else {
      state = {...state, ipoId};
    }
  }

  bool isWatched(String ipoId) => state.contains(ipoId);
}

final watchlistProvider =
    StateNotifierProvider<WatchlistRepository, Set<String>>(
  (ref) => WatchlistRepository(),
);

final isWatchedProvider = Provider.family<bool, String>((ref, ipoId) {
  return ref.watch(watchlistProvider).contains(ipoId);
});
