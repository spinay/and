import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/data/local/personal_db.dart';
import 'package:ipo_keeper/data/models/ipo.dart';
import 'package:ipo_keeper/data/repositories/catalog_repository.dart';
import 'package:ipo_keeper/data/repositories/personal_db_provider.dart';
import 'package:ipo_keeper/presentation/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedCatalog extends CatalogRepository {
  _FixedCatalog() {
    state = const <IPO>[];
  }
  @override
  Future<void> load() async {}
  @override
  Future<bool> refresh() async => false;
}

void main() {
  late PersonalDb db;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    db = PersonalDb.forTesting(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  testWidgets('설정 화면 필수 항목이 모두 표시된다', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWith((_) => _FixedCatalog()),
        personalDbProvider.overrideWithValue(db),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('청약 시작 D-1 알림'), findsOneWidget);
    expect(find.text('환불일 알림'), findsOneWidget);
    expect(find.text('상장일 알림'), findsOneWidget);
    expect(find.text('내 청약 기록 초기화'), findsOneWidget);
    expect(find.text('관심종목 모두 해제'), findsOneWidget);
    expect(find.text('버전'), findsOneWidget);
  });
}
