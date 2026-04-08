import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/personal_db.dart';

/// 앱 전역의 [PersonalDb] 단일 인스턴스.
///
/// 앱 기동 시 `main.dart`에서 시드를 주입하기 위해 override된다.
/// (override 없이 읽으면 빈 DB가 생성된다)
final personalDbProvider = Provider<PersonalDb>((ref) {
  final db = PersonalDb();
  ref.onDispose(db.close);
  return db;
});
