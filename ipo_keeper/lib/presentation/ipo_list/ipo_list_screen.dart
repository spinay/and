import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/ipo.dart';
import '../../data/repositories/ipo_repository.dart';
import '../../data/repositories/watchlist_repository.dart';

class IPOListScreen extends ConsumerStatefulWidget {
  const IPOListScreen({super.key});

  @override
  ConsumerState<IPOListScreen> createState() => _IPOListScreenState();
}

class _IPOListScreenState extends ConsumerState<IPOListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ipos = ref.watch(ipoListProvider);
    final watched = ref.watch(watchlistProvider).valueOrNull ?? const <String>{};

    final tabs = <String, List<IPO>>{
      '전체': ipos,
      '관심': ipos.where((e) => watched.contains(e.id)).toList(),
      '청약중': ipos.where((e) => e.status == IPOStatus.subscribing).toList(),
      '청약예정': ipos.where((e) => e.status == IPOStatus.upcoming || e.status == IPOStatus.forecasting).toList(),
      '상장완료': ipos.where((e) => e.status == IPOStatus.listed || e.status == IPOStatus.closed).toList(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('공모주'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: tabs.keys.map((t) => Tab(text: t)).toList(),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.entries
            .map((e) => _IPOListView(
                  ipos: e.value,
                  isWatchlistTab: e.key == '관심',
                ))
            .toList(),
      ),
    );
  }
}

class _IPOListView extends ConsumerWidget {
  final List<IPO> ipos;
  final bool isWatchlistTab;
  const _IPOListView({required this.ipos, this.isWatchlistTab = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ipos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isWatchlistTab ? Icons.star_outline : Icons.inbox_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              isWatchlistTab ? '아직 관심종목이 없어요' : '해당하는 공모주가 없어요',
              style: AppTextStyles.body2,
            ),
            if (isWatchlistTab) ...[
              const SizedBox(height: 4),
              const Text(
                '전체 탭에서 ⭐을 눌러 추가해보세요',
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: ipos.length,
      itemBuilder: (ctx, i) => _IPOCard(ipo: ipos[i]),
    );
  }
}

class _IPOCard extends ConsumerWidget {
  final IPO ipo;
  const _IPOCard({required this.ipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWatched = ref.watch(isWatchedProvider(ipo.id));

    return GestureDetector(
      onTap: () => context.push('/detail/${ipo.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
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
                GestureDetector(
                  onTap: () => ref.read(watchlistRepositoryProvider).toggle(ipo.id),
                  child: Icon(
                    isWatched ? Icons.star : Icons.star_outline,
                    color: isWatched ? const Color(0xFFF59E0B) : AppColors.textTertiary,
                    size: 22,
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
                    ipo.subscriptionStart != null
                        ? AppDateUtils.dDayLabel(ipo.subscriptionStart!)
                        : '',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ],
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
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _InfoChip({required this.label, required this.value, this.highlight = false});

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
