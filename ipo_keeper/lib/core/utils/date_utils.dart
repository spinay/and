class AppDateUtils {
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int daysDiff(DateTime from, DateTime to) =>
      to.difference(DateTime(from.year, from.month, from.day)).inDays;

  static String dDayLabel(DateTime target) {
    final today = DateTime.now();
    final diff = daysDiff(today, target);
    if (diff == 0) return 'D-Day';
    if (diff > 0) return 'D-$diff';
    return 'D+${diff.abs()}';
  }

  static String formatMD(DateTime date) =>
      '${date.month}/${date.day}';

  static String formatYMD(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}
