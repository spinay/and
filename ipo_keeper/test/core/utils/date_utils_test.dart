import 'package:flutter_test/flutter_test.dart';
import 'package:ipo_keeper/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils.isSameDay', () {
    test('같은 날짜', () {
      final a = DateTime(2026, 4, 23, 9, 0);
      final b = DateTime(2026, 4, 23, 23, 59);
      expect(AppDateUtils.isSameDay(a, b), isTrue);
    });

    test('다른 날짜', () {
      expect(
        AppDateUtils.isSameDay(
          DateTime(2026, 4, 23),
          DateTime(2026, 4, 24),
        ),
        isFalse,
      );
    });

    test('다른 월', () {
      expect(
        AppDateUtils.isSameDay(
          DateTime(2026, 4, 1),
          DateTime(2026, 5, 1),
        ),
        isFalse,
      );
    });
  });

  group('AppDateUtils.daysDiff', () {
    test('미래 날짜는 양수', () {
      final today = DateTime(2026, 4, 23);
      final future = DateTime(2026, 4, 26);
      expect(AppDateUtils.daysDiff(today, future), 3);
    });

    test('과거 날짜는 음수', () {
      final today = DateTime(2026, 4, 23);
      final past = DateTime(2026, 4, 20);
      expect(AppDateUtils.daysDiff(today, past), -3);
    });

    test('같은 날은 0', () {
      final today = DateTime(2026, 4, 23, 14);
      final same = DateTime(2026, 4, 23, 2);
      expect(AppDateUtils.daysDiff(today, same), 0);
    });
  });

  group('AppDateUtils.formatMD / formatYMD', () {
    test('월/일 포맷', () {
      expect(AppDateUtils.formatMD(DateTime(2026, 4, 7)), '4/7');
      expect(AppDateUtils.formatMD(DateTime(2026, 12, 31)), '12/31');
    });

    test('YYYY.MM.DD 포맷 (0 패딩)', () {
      expect(AppDateUtils.formatYMD(DateTime(2026, 4, 7)), '2026.04.07');
      expect(AppDateUtils.formatYMD(DateTime(2026, 12, 31)), '2026.12.31');
    });
  });
}
