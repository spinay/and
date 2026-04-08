import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'personal_db.g.dart';

/// 사용자 개인 데이터 (관심종목, 청약기록).
///
/// 설계 원칙:
/// - catalog 데이터(공모주 목록)와는 완전히 분리된다.
/// - 모든 테이블은 [canonicalKey](예: `2026-04-14_클라우드원`)로
///   catalog를 참조한다. 실제 FK는 없음 — catalog가 원격 JSON이기 때문.
/// - catalog JSON이 재배포돼도 이 DB의 레코드는 그대로 유지돼야 한다.

/// 관심종목: canonical_key 한 개 컬럼 테이블.
@DataClassName('WatchlistItem')
class WatchlistItems extends Table {
  TextColumn get canonicalKey => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {canonicalKey};
}

/// 청약기록: [Subscription] 모델과 1:1 매핑.
/// ipoName은 스냅샷 — catalog에서 종목이 바뀌어도 당시 이름을 유지.
@DataClassName('SubscriptionRow')
class SubscriptionRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ipoId => text()(); // canonical_key
  TextColumn get ipoName => text()();

  // 청약 단계
  TextColumn get broker => text().nullable()();
  IntColumn get appliedQty => integer().nullable()();
  IntColumn get depositAmount => integer().nullable()();

  // 배정 단계
  IntColumn get allocatedQty => integer().nullable()();
  IntColumn get refundAmount => integer().nullable()();

  // 매도 단계
  IntColumn get sellPrice => integer().nullable()();
  IntColumn get sellQty => integer().nullable()();
  IntColumn get profitAmount => integer().nullable()();
  RealColumn get profitRate => real().nullable()();

  /// [SubscriptionStatus.name] 값 그대로 저장
  TextColumn get status => text()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [WatchlistItems, SubscriptionRecords])
class PersonalDb extends _$PersonalDb {
  PersonalDb() : super(_openConnection());

  /// 테스트에서 in-memory DB로 주입할 수 있도록 열어둔 생성자.
  PersonalDb.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ─── Watchlist ───────────────────────────────────────────

  Stream<Set<String>> watchWatchlist() {
    return (select(watchlistItems)).watch().map(
          (rows) => rows.map((r) => r.canonicalKey).toSet(),
        );
  }

  Future<Set<String>> getWatchlist() async {
    final rows = await select(watchlistItems).get();
    return rows.map((r) => r.canonicalKey).toSet();
  }

  Future<void> addWatch(String canonicalKey) async {
    await into(watchlistItems).insertOnConflictUpdate(
      WatchlistItemsCompanion.insert(canonicalKey: canonicalKey),
    );
  }

  Future<void> removeWatch(String canonicalKey) async {
    await (delete(watchlistItems)
          ..where((t) => t.canonicalKey.equals(canonicalKey)))
        .go();
  }

  // ─── Subscriptions ───────────────────────────────────────

  Stream<List<SubscriptionRow>> watchSubscriptions() {
    return (select(subscriptionRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertSubscription(SubscriptionRecordsCompanion row) {
    return into(subscriptionRecords).insert(row);
  }

  Future<void> updateSubscription(SubscriptionRow row) async {
    await update(subscriptionRecords).replace(row);
  }

  Future<void> deleteSubscription(int id) async {
    await (delete(subscriptionRecords)..where((t) => t.id.equals(id))).go();
  }
}

QueryExecutor _openConnection() {
  // drift_flutter가 앱 document 디렉토리에 파일을 만들어준다.
  return driftDatabase(name: 'personal_db');
}
