import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/repositories/catalog_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 앱 시작 전에 catalog를 한 번 로드한다.
  // - SharedPreferences 캐시가 있으면 그걸 우선 사용 (즉시)
  // - 없으면 assets 번들을 폴백 (즉시)
  // 네트워크는 여기서 기다리지 않는다 — 백그라운드에서 새로 받음.
  final catalog = CatalogRepository();
  await catalog.load();

  // 네트워크 갱신은 fire-and-forget. UI를 막지 않는다.
  // 첫 화면이 뜬 직후 결과가 도착하면 다음 빌드에서 자연스럽게 반영된다.
  // (1B-2에서 Riverpod state로 정식 연결 예정)
  // ignore: unawaited_futures
  catalog.refresh();

  runApp(
    ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(catalog),
      ],
      child: const IPOKeeperApp(),
    ),
  );
}
