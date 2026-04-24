import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/ipo.dart';
import '../../data/repositories/ipo_repository.dart';
import '../../data/repositories/watchlist_repository.dart';
import '../../domain/ipo_list_sorting.dart';

class IPOListScreen extends ConsumerStatefulWidget {
  const IPOListScreen({super.key});

  @override
  ConsumerState<IPOListScreen> createState() => _IPOListScreenState();
}

class _IPOListScreenState extends ConsumerState<IPOListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공모주'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '목록'), Tab(text: '캘린더')],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _IPOListTab(),
          _CalendarTab(),
        ],
      ),
    );
  }
}

// ─── 목록 탭 ─────────────────────────────────────────────

class _IPOListTab extends ConsumerStatefulWidget {
  const _IPOListTab();

  @override
  ConsumerState<_IPOListTab> createState() => _IPOListTabState();
}

class _IPOListTabState extends ConsumerState<_IPOListTab> {
  IPOListFilter _filter = IPOListFilter.all;
  final ScrollController _scrollController = ScrollController();
  bool _didInitialScroll = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCenter(List<IPO> sorted) {
    if (_didInitialScroll || sorted.isEmpty) return;
    _didInitialScroll = true;

    final idx = findClosestDDayIndex(sorted, DateTime.now());
    const cardHeight = 130.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final offset = (idx * cardHeight - screenHeight / 2 + cardHeight)
        .clamp(0.0, double.infinity);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ipos = ref.watch(ipoListProvider);
    final filtered =
        ipos.where(_filter.matches).toList(growable: false);
    final sorted = sortByDDay(filtered, DateTime.now());

    _scrollToCenter(sorted);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              for (final f in IPOListFilter.values)
                _FilterChip(
                  label: f.label,
                  selected: _filter == f,
                  onTap: () => setState(() {
                    _filter = f;
                    _didInitialScroll = false;
                  }),
                ),
            ],
          ),
        ),
        Expanded(
          child: sorted.isEmpty
              ? const Center(
                  child: Text('해당하는 공모주가 없어요', style: AppTextStyles.body2),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: sorted.length,
                  itemBuilder: (ctx, i) => _IPOCard(ipo: sorted[i]),
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _IPOCard extends ConsumerWidget {
  final IPO ipo;
  const _IPOCard({required this.ipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWatched = ref.watch(isWatchedProvider(ipo.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/detail/${ipo.id}'),
          child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ipo.companyName, style: AppTextStyles.heading3),
                      const SizedBox(height: 2),
                      Text(ipo.sector, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                _StatusBadge(ipo: ipo),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => ref.read(watchlistRepositoryProvider).toggle(ipo.id),
                    icon: Icon(
                      isWatched ? Icons.star : Icons.star_outline,
                      color: isWatched ? const Color(0xFFF59E0B) : AppColors.textTertiary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(label: '공모가', value: ipo.priceBandText),
                const SizedBox(width: 16),
                _InfoChip(
                  label: '최소 청약금',
                  value: ipo.minSubscriptionAmount != null
                      ? CurrencyUtils.formatShort(ipo.minSubscriptionAmount!)
                      : '확정 전',
                  highlight: true,
                ),
                if (ipo.subscriptionStart != null) ...[
                  const Spacer(),
                  Text(
                    AppDateUtils.dDayLabel(ipo.subscriptionStart!),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IPO ipo;
  const _StatusBadge({required this.ipo});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (ipo.status) {
      IPOStatus.subscribing => ('청약중', AppColors.subscription),
      IPOStatus.forecasting => ('수요예측', AppColors.forecast),
      IPOStatus.upcoming => ('청약예정', AppColors.textSecondary),
      IPOStatus.waitingListing => ('상장대기', AppColors.listed),
      IPOStatus.listed => ('상장완료', AppColors.sold),
      IPOStatus.closed => ('종료', AppColors.sold),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _InfoChip(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── 캘린더 탭 ─────────────────────────────────────────────

class _CalendarTab extends ConsumerStatefulWidget {
  const _CalendarTab();

  @override
  ConsumerState<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<_CalendarTab> {
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

    final selectedKey =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final selectedEvents = eventMap[selectedKey] ?? [];

    return Column(
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
            selectedDecoration:
                BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            todayDecoration:
                BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            todayTextStyle:
                TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            markersMaxCount: 3,
            markerDecoration:
                BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
              ? const Center(
                  child:
                      Text('이 날은 일정이 없어요', style: AppTextStyles.body2))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: selectedEvents.length,
                  itemBuilder: (ctx, i) =>
                      _EventTile(event: selectedEvents[i]),
                ),
        ),
        _Legend(),
      ],
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
            Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(
                child: Text(event.ipo.companyName, style: AppTextStyles.body1)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(event.label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: event.color)),
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
      decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items
            .map((e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: e.$2, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(e.$1, style: AppTextStyles.caption),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
