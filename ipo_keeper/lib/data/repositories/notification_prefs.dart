import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용자 알림 토글 (청약 / 환불 / 상장 3종).
///
/// SharedPreferences에 저장된다.
class NotificationPrefs {
  final bool subscription;
  final bool refund;
  final bool listing;

  const NotificationPrefs({
    this.subscription = true,
    this.refund = true,
    this.listing = true,
  });

  NotificationPrefs copyWith({
    bool? subscription,
    bool? refund,
    bool? listing,
  }) {
    return NotificationPrefs(
      subscription: subscription ?? this.subscription,
      refund: refund ?? this.refund,
      listing: listing ?? this.listing,
    );
  }
}

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier() : super(const NotificationPrefs()) {
    _load();
  }

  static const _keySub = 'notify.subscription';
  static const _keyRefund = 'notify.refund';
  static const _keyListing = 'notify.listing';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = NotificationPrefs(
        subscription: prefs.getBool(_keySub) ?? true,
        refund: prefs.getBool(_keyRefund) ?? true,
        listing: prefs.getBool(_keyListing) ?? true,
      );
    } catch (_) {}
  }

  Future<void> setSubscription(bool v) async {
    state = state.copyWith(subscription: v);
    await _save();
  }

  Future<void> setRefund(bool v) async {
    state = state.copyWith(refund: v);
    await _save();
  }

  Future<void> setListing(bool v) async {
    state = state.copyWith(listing: v);
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySub, state.subscription);
      await prefs.setBool(_keyRefund, state.refund);
      await prefs.setBool(_keyListing, state.listing);
    } catch (_) {}
  }
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  (ref) => NotificationPrefsNotifier(),
);
