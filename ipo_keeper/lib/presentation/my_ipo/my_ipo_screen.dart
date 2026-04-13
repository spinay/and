import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/ipo.dart';
import '../../data/models/subscription.dart';
import '../../data/repositories/ipo_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/watchlist_repository.dart';

class MyIPOScreen extends ConsumerStatefulWidget {
  const MyIPOScreen({super.key});

  @override
  ConsumerState<MyIPOScreen> createState() => _MyIPOScreenState();
}

class _MyIPOScreenState extends ConsumerState<MyIPOScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 청약'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: '관심'), Tab(text: '진행중'), Tab(text: '완료')],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/subscription/new'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('청약 추가',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _WatchlistTab(),
          _SubscriptionList(showActive: true),
          _SubscriptionList(showActive: false),
        ],
      ),
    );
  }
}

// ─── 관심 탭 ─────────────────────────────────────────────

class _WatchlistTab extends ConsumerWidget {
  const _WatchlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watched = ref.watch(watchlistProvider).valueOrNull ?? const <String>{};
    final ipos = ref.watch(ipoListProvider);
    final watchedIpos = ipos.where((e) => watched.contains(e.id)).toList();

    if (watchedIpos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            const Text('아직 관심종목이 없어요', style: AppTextStyles.body2),
            const SizedBox(height: 4),
            const Text(
              '공모주 탭에서 ⭐을 눌러 추가해보세요',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: watchedIpos.length,
      itemBuilder: (ctx, i) => _WatchlistCard(ipo: watchedIpos[i]),
    );
  }
}

class _WatchlistCard extends ConsumerWidget {
  final IPO ipo;
  const _WatchlistCard({required this.ipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (statusLabel, statusColor) = switch (ipo.status) {
      IPOStatus.subscribing => ('청약중', AppColors.subscription),
      IPOStatus.forecasting => ('수요예측', AppColors.forecast),
      IPOStatus.upcoming => ('청약예정', AppColors.textSecondary),
      IPOStatus.waitingListing => ('상장대기', AppColors.listed),
      IPOStatus.listed => ('상장완료', AppColors.sold),
      IPOStatus.closed => ('종료', AppColors.sold),
    };

    // 청약 시작이 가까우면 CTA 보여주기
    final canSubscribe = ipo.status == IPOStatus.subscribing ||
        ipo.status == IPOStatus.upcoming ||
        ipo.status == IPOStatus.forecasting;

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
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor)),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            ref.read(watchlistRepositoryProvider).toggle(ipo.id),
                        icon: const Icon(Icons.star,
                            color: Color(0xFFF59E0B), size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (ipo.confirmedPrice != null)
                      Text('공모가 ${CurrencyUtils.format(ipo.confirmedPrice!)}',
                          style: AppTextStyles.body2)
                    else
                      Text('공모가 ${ipo.priceBandText}', style: AppTextStyles.body2),
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
                if (canSubscribe) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push(
                          '/subscription/new?ipoId=${Uri.encodeComponent(ipo.id)}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('청약 기록하기',
                          style:
                              TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 진행중 / 완료 탭 ─────────────────────────────────────

class _SubscriptionList extends ConsumerWidget {
  final bool showActive;
  const _SubscriptionList({required this.showActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(subscriptionListProvider).valueOrNull ??
        const <Subscription>[];
    final items = showActive
        ? all.where((s) => s.status != SubscriptionStatus.sold).toList()
        : all.where((s) => s.status == SubscriptionStatus.sold).toList();

    if (items.isEmpty) {
      return Center(
        child: Text(
          showActive ? '진행중인 청약이 없어요' : '완료된 청약이 없어요',
          style: AppTextStyles.body2,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _SubscriptionCard(sub: items[i]),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription sub;
  const _SubscriptionCard({required this.sub});

  void _openEdit(BuildContext context) {
    final id = sub.id;
    if (id == null) return;
    context.push('/subscription/edit/$id');
  }

  Color get _statusColor {
    switch (sub.status) {
      case SubscriptionStatus.applied:
        return AppColors.applied;
      case SubscriptionStatus.allocated:
        return AppColors.allocated;
      case SubscriptionStatus.refunded:
        return AppColors.refunded;
      case SubscriptionStatus.listed:
        return AppColors.listed;
      case SubscriptionStatus.sold:
        return AppColors.sold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openEdit(context),
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
                    child:
                        Text(sub.ipoName, style: AppTextStyles.heading3)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(sub.status.label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (sub.broker != null) _Row('증권사', sub.broker!),
            if (sub.appliedQty != null) _Row('청약 수량', '${sub.appliedQty}주'),
            if (sub.depositAmount != null)
              _Row('납입 증거금', CurrencyUtils.format(sub.depositAmount!)),
            if (sub.allocatedQty != null)
              _Row('배정 수량', '${sub.allocatedQty}주'),
            if (sub.refundAmount != null)
              _Row('환불 금액', CurrencyUtils.format(sub.refundAmount!)),
            if (sub.profitAmount != null) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('수익',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(
                    '${sub.profitAmount! >= 0 ? '+' : ''}${CurrencyUtils.format(sub.profitAmount!)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: sub.profitAmount! >= 0
                          ? AppColors.profit
                          : AppColors.loss,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sub.status.nextAction,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2),
          Text(value,
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
