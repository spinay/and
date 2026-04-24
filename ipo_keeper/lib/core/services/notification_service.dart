import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/ipo.dart';

/// 알림 스케줄러 인터페이스.
///
/// WatchlistRepository 등 다른 레이어가 실제 구현과 분리되도록 둔다.
/// 테스트에서는 [NoopNotificationScheduler] 등을 주입할 수 있다.
abstract class IpoNotificationScheduler {
  Future<void> scheduleForIpo(IPO ipo);
  Future<void> cancelForIpo(IPO ipo);
}

/// 아무 일도 하지 않는 구현 (테스트용).
class NoopNotificationScheduler implements IpoNotificationScheduler {
  const NoopNotificationScheduler();
  @override
  Future<void> scheduleForIpo(IPO ipo) async {}
  @override
  Future<void> cancelForIpo(IPO ipo) async {}
}

/// 로컬 알림 서비스.
///
/// 관심종목에 대해 3종 알림을 스케줄한다:
///  1. 청약 시작 D-1 오전 9시 — "내일 청약 시작"
///  2. 환불일 당일 오전 9시 — "오늘 환불금 확인"
///  3. 상장일 당일 오전 9시 — "오늘 상장일"
///
/// 알림 ID는 `ipo.id.hashCode * 10 + offset` 형태로 종목당 3개까지 사용.
class NotificationService implements IpoNotificationScheduler {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 알림 유형별 on/off. 기본값은 모두 true.
  /// SharedPreferences에서 먼저 읽어오도록 [applyPrefs]로 갱신한다.
  bool _notifySubscription = true;
  bool _notifyRefund = true;
  bool _notifyListing = true;

  void applyPrefs({
    required bool subscription,
    required bool refund,
    required bool listing,
  }) {
    _notifySubscription = subscription;
    _notifyRefund = refund;
    _notifyListing = listing;
  }

  /// 초기화. 앱 시작 시 한 번만 호출.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// 안드로이드 13+ POST_NOTIFICATIONS 런타임 권한 요청.
  /// iOS는 init 시 이미 요청했다. 반환값: 유저가 허용했는지 (null/unknown = true).
  Future<bool> requestPermissions() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final ok = await android.requestNotificationsPermission();
      if (ok == false) return false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final ok = await ios.requestPermissions(alert: true, badge: true, sound: true);
      if (ok == false) return false;
    }
    return true;
  }

  /// 해당 IPO에 대한 알림을 스케줄한다.
  /// 과거 날짜는 자동으로 건너뛴다.
  @override
  Future<void> scheduleForIpo(IPO ipo) async {
    // flutter_local_notifications가 요구하는 32bit 정수 범위로 제한.
    // hashCode는 64bit까지 나올 수 있으므로 1억으로 mod.
    // id = base * 10 + offset → 최대 1,000,000,009 < 2^31 (안전).
    final base = ipo.id.hashCode.abs() % 100000000;

    // 1. 청약 시작 D-1
    if (_notifySubscription && ipo.subscriptionStart != null) {
      final d = ipo.subscriptionStart!.subtract(const Duration(days: 1));
      await _scheduleAt(
        id: base * 10 + 1,
        date: d,
        title: '내일 청약 시작',
        body: '${ipo.companyName} 청약이 내일 시작돼요',
      );
    }

    // 2. 환불일 당일
    if (_notifyRefund && ipo.refundDate != null) {
      await _scheduleAt(
        id: base * 10 + 2,
        date: ipo.refundDate!,
        title: '오늘 환불금 확인',
        body: '${ipo.companyName} 환불금을 확인하세요',
      );
    }

    // 3. 상장일 당일
    if (_notifyListing && ipo.listingDate != null) {
      await _scheduleAt(
        id: base * 10 + 3,
        date: ipo.listingDate!,
        title: '오늘 상장일',
        body: '${ipo.companyName}이 오늘 상장해요',
      );
    }
  }

  /// 해당 IPO의 알림을 모두 취소한다.
  @override
  Future<void> cancelForIpo(IPO ipo) async {
    final base = ipo.id.hashCode.abs() % 100000000;
    await _plugin.cancel(base * 10 + 1);
    await _plugin.cancel(base * 10 + 2);
    await _plugin.cancel(base * 10 + 3);
  }

  /// 모든 알림 취소.
  Future<void> cancelAll() => _plugin.cancelAll();

  // ─── private ─────────────────────────────────────────────

  Future<void> _scheduleAt({
    required int id,
    required DateTime date,
    required String title,
    required String body,
  }) async {
    // 오전 9시로 고정
    final scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      9,
    );

    // 과거 날짜는 건너뛴다
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'ipo_events',
        '공모주 일정',
        channelDescription: '청약·환불·상장 일정 알림',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }
}
