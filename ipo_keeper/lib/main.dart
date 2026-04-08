import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/local/personal_db.dart';
import 'data/models/subscription.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/personal_db_provider.dart';
import 'data/repositories/subscription_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Catalog를 한 번 로드한다.
  //    - SharedPreferences 캐시가 있으면 그걸 우선 사용 (즉시)
  //    - 없으면 assets 번들을 폴백 (즉시)
  //    네트워크는 여기서 기다리지 않는다 — 백그라운드에서 새로 받음.
  final catalog = CatalogRepository();
  await catalog.load();

  // 네트워크 갱신은 fire-and-forget. UI를 막지 않는다.
  // state가 바뀌면 StateNotifierProvider를 watch하는 화면이 자동 재빌드된다.
  // ignore: unawaited_futures
  catalog.refresh();

  // 2. PersonalDb를 열고 첫 실행이면 더미 데이터를 시드한다.
  final personalDb = PersonalDb();
  await _seedIfEmpty(personalDb);

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

/// 빈 DB라면 기존 더미 데이터를 한 번만 넣는다.
/// 이 블록은 1C에서 "정식 청약 기록 추가" UX가 들어오면 제거한다.
Future<void> _seedIfEmpty(PersonalDb db) async {
  final existing = await db.getWatchlist();
  if (existing.isEmpty) {
    await db.addWatch('2026-04-14_클라우드원');
    await db.addWatch('2026-04-16_바이오넥스트');
  }

  final subsRepo = SubscriptionRepository(db);
  final subs = await db.watchSubscriptions().first;
  if (subs.isEmpty) {
    await subsRepo.add(Subscription(
      ipoId: '2026-04-07_그린에너지솔루션',
      ipoName: '그린에너지솔루션',
      broker: '미래에셋증권',
      appliedQty: 20,
      depositAmount: 55000,
      allocatedQty: 3,
      refundAmount: 22000,
      status: SubscriptionStatus.refunded,
      createdAt: DateTime(2026, 4, 7),
    ));
    await subsRepo.add(Subscription(
      ipoId: '2026-04-14_클라우드원',
      ipoName: '클라우드원',
      broker: 'NH투자증권',
      appliedQty: 10,
      depositAmount: 67500,
      status: SubscriptionStatus.applied,
      createdAt: DateTime(2026, 4, 14),
    ));
  }
}
