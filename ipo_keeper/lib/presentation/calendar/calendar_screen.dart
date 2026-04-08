import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/ipo.dart';
import '../../data/repositories/ipo_repository.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ipos = ref.watch(ipoListProvider);

    Map<DateTime, List<_CalEvent>> eventMap = {};
    for (final ipo in ipos) {
      void add(DateTime? d, String label, Color color) {
        if (d == null) return;
        final key = DateTime(d.year, d.month, d.day);
        eventMap.putIfAbsent(key, () => []);
        eventMap[key]!.add(_CalEvent(ipo: ipo, label: label, color: color));
      }
      add(ipo.subscriptionStart, '청약시작', AppColors.subscription);
      add(ipo.subscriptionEnd, '청약마감', AppColors.subscription);
      add(ipo.refundDate, '환불일', AppColors.refund);
      add(ipo.listingDate, '상장일', AppColors.listing);
    }

    final selectedKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final selectedEvents = eventMap[selectedKey] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('캘린더')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2025, 1, 1),
            lastDay: DateTime(2027, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            onDaySelected: (sel, foc) => setState(() {
              _selectedDay = sel;
              _focusedDay = foc;
            }),
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return eventMap[key] ?? [];
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppTextStyles.heading3,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: selectedEvents.isEmpty
                ? const Center(child: Text('이 날은 일정이 없어요', style: AppTextStyles.body2))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedEvents.length,
                    itemBuilder: (ctx, i) => _EventTile(event: selectedEvents[i]),
                  ),
          ),
          _Legend(),
        ],
      ),
    );
  }
}

class _CalEvent {
  final IPO ipo;
  final String label;
  final Color color;
  _CalEvent({required this.ipo, required this.label, required this.color});
}

class _EventTile extends StatelessWidget {
  final _CalEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/detail/${event.ipo.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 36, decoration: BoxDecoration(color: event.color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(child: Text(event.ipo.companyName, style: AppTextStyles.body1)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: event.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(event.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: event.color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('수요예측', AppColors.forecast),
      ('청약', AppColors.subscription),
      ('환불', AppColors.refund),
      ('상장', AppColors.listing),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((e) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: e.$2, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(e.$1, style: AppTextStyles.caption),
          ],
        )).toList(),
      ),
    );
  }
}
