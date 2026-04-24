import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/core/services/notification_service.dart';
import 'package:ipo_keeper/data/local/personal_db.dart';
import 'package:ipo_keeper/data/models/ipo.dart';
import 'package:ipo_keeper/data/repositories/watchlist_repository.dart';

class _RecordingScheduler implements IpoNotificationScheduler {
  final scheduled = <String>[];
  final canceled = <String>[];
  @override
  Future<void> scheduleForIpo(IPO ipo) async => scheduled.add(ipo.id);
  @override
  Future<void> cancelForIpo(IPO ipo) async => canceled.add(ipo.id);
}

IPO _ipo(String id) => IPO(
      id: id,
      companyName: id.toUpperCase(),
      sector: '',
      businessSummary: '',
      minSubscriptionQty: 10,
      depositRatio: 0.5,
      status: IPOStatus.upcoming,
    );

void main() {
  late PersonalDb db;
  late WatchlistRepository repo;
  late _RecordingScheduler scheduler;

  final catalog = [_ipo('a'), _ipo('b')];

  setUp(() {
    db = PersonalDb.forTesting(NativeDatabase.memory());
    scheduler = _RecordingScheduler();
    repo = WatchlistRepository(
      db: db,
      catalogLookup: () => catalog,
      notifications: scheduler,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('비어있을 땐 toggle이 add로 작동 + 알림 스케줄', () async {
    await repo.toggle('a');
    final set = await repo.watch().first;
    expect(set, {'a'});
    expect(scheduler.scheduled, ['a']);
  });

  test('이미 있을 땐 toggle이 remove로 작동 + 알림 취소', () async {
    await repo.add('a');
    await repo.toggle('a');
    final set = await repo.watch().first;
    expect(set, isEmpty);
    expect(scheduler.canceled, ['a']);
  });

  test('여러 건 add/remove', () async {
    await repo.add('a');
    await repo.add('b');
    await repo.remove('a');
    final set = await repo.watch().first;
    expect(set, {'b'});
    expect(scheduler.scheduled, ['a', 'b']);
    expect(scheduler.canceled, ['a']);
  });

  test('중복 add는 무시 (unique key)', () async {
    await repo.add('a');
    await repo.add('a');
    final set = await repo.watch().first;
    expect(set, {'a'});
  });

  test('catalog에 없는 id는 알림 호출 skip, DB만 반영', () async {
    await repo.add('ghost');
    expect(scheduler.scheduled, isEmpty);
    final set = await repo.watch().first;
    expect(set, {'ghost'});
  });
}
