import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistRepository extends StateNotifier<Set<String>> {
  WatchlistRepository() : super({'ipo_2026_001', 'ipo_2026_002'});

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
