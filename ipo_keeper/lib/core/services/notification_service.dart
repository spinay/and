import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/ipo.dart';

/// 로컬 알림 서비스.
///
/// 관심종목에 대해 3종 알림을 스케줄한다:
///  1. 청약 시작 D-1 오전 9시 — "내일 청약 시작"
///  2. 환불일 당일 오전 9시 — "오늘 환불금 확인"
///  3. 상장일 당일 오전 9시 — "오늘 상장일"
///
/// 알림 ID는 `ipo.id.hashCode * 10 + offset` 형태로 종목당 3개까지 사용.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

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

  /// 해당 IPO에 대한 알림을 스케줄한다.
  /// 과거 날짜는 자동으로 건너뛴다.
  Future<void> scheduleForIpo(IPO ipo) async {
    final base = ipo.id.hashCode.abs();

    // 1. 청약 시작 D-1
    if (ipo.subscriptionStart != null) {
      final d = ipo.subscriptionStart!.subtract(const Duration(days: 1));
      await _scheduleAt(
        id: base * 10 + 1,
        date: d,
        title: '내일 청약 시작',
        body: '${ipo.companyName} 청약이 내일 시작돼요',
      );
    }

    // 2. 환불일 당일
    if (ipo.refundDate != null) {
      await _scheduleAt(
        id: base * 10 + 2,
        date: ipo.refundDate!,
        title: '오늘 환불금 확인',
        body: '${ipo.companyName} 환불금을 확인하세요',
      );
    }

    // 3. 상장일 당일
    if (ipo.listingDate != null) {
      await _scheduleAt(
        id: base * 10 + 3,
        date: ipo.listingDate!,
        title: '오늘 상장일',
        body: '${ipo.companyName}이 오늘 상장해요',
      );
    }
  }

  /// 해당 IPO의 알림을 모두 취소한다.
  Future<void> cancelForIpo(IPO ipo) async {
    final base = ipo.id.hashCode.abs();
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
