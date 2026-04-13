import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'data/local/personal_db.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/personal_db_provider.dart';
import 'data/models/ipo.dart';
import 'data/repositories/subscription_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Catalog를 한 번 로드한다.
  final catalog = CatalogRepository();
  await catalog.load();

  // 네트워크 갱신은 fire-and-forget.
  // ignore: unawaited_futures
  catalog.refresh();

  // 2. PersonalDb 오픈.
  final personalDb = PersonalDb();

  // 3. 날짜 기반 상태 자동 전이 — 실패해도 앱은 띄운다.
  try {
    final subsRepo = SubscriptionRepository(personalDb);
    await subsRepo.autoTransition(catalog: catalog.cache)
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    // DB 초기화 지연이나 에러 시 skip
  }

  // 4. 로컬 알림 초기화 + 관심종목 일정 스케줄 — 실패해도 앱은 띄운다.
  try {
    await NotificationService.instance.init()
        .timeout(const Duration(seconds: 5));
    await _scheduleWatchlistNotifications(personalDb, catalog.cache)
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    // 알림 초기화 실패 시 skip — 알림만 안 갈 뿐 앱 동작에 지장 없음
  }

  runApp(
    ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWith((_) => catalog),
        personalDbProvider.overrideWithValue(personalDb),
      ],
      child: const IPOKeeperApp(),
    ),
  );
}

/// 관심종목의 알림을 스케줄한다 (기존 알림 초기화 후 재등록).
Future<void> _scheduleWatchlistNotifications(
  PersonalDb db,
  List<IPO> catalog,
) async {
  final ns = NotificationService.instance;
  await ns.cancelAll();

  final watched = await db.getWatchlist();
  for (final ipo in catalog) {
    if (watched.contains(ipo.id)) {
      await ns.scheduleForIpo(ipo);
    }
  }
}
