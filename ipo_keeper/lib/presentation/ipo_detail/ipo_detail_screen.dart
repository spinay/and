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

class IPODetailScreen extends ConsumerWidget {
  final String ipoId;
  const IPODetailScreen({super.key, required this.ipoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ipo = ref.watch(ipoDetailProvider(ipoId));
    if (ipo == null) return const Scaffold(body: Center(child: Text('종목을 찾을 수 없어요')));

    final isWatched = ref.watch(isWatchedProvider(ipoId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(ipo.companyName),
        actions: [
          IconButton(
            onPressed: () => ref.read(watchlistRepositoryProvider).toggle(ipoId),
            icon: Icon(
              isWatched ? Icons.star : Icons.star_outline,
              color: isWatched ? const Color(0xFFF59E0B) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _CompanyCard(ipo: ipo),
            const SizedBox(height: 12),
            _TimelineCard(ipo: ipo),
            const SizedBox(height: 12),
            _SubscriptionInfoCard(ipo: ipo),
            const SizedBox(height: 12),
            _UnderwriterCard(ipo: ipo),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _BottomCTA(ipo: ipo, isWatched: isWatched, ref: ref),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final IPO ipo;
  const _CompanyCard({required this.ipo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                child: Text(ipo.sector, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('기업 소개', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(ipo.businessSummary, style: AppTextStyles.body1),
          if (ipo.competitionRate != null) ...[
            const SizedBox(height: 12),
            _StatRow('수요예측 경쟁률', '${ipo.competitionRate!.toStringAsFixed(1)} : 1'),
          ],
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final IPO ipo;
  const _TimelineCard({required this.ipo});

  @override
  Widget build(BuildContext context) {
    final events = [
      if (ipo.demandForecastStart != null) _TimelineEvent('수요예측', ipo.demandForecastStart!, ipo.demandForecastEnd, AppColors.forecast),
      if (ipo.subscriptionStart != null) _TimelineEvent('청약', ipo.subscriptionStart!, ipo.subscriptionEnd, AppColors.subscription),
      if (ipo.refundDate != null) _TimelineEvent('환불일', ipo.refundDate!, null, AppColors.refund),
      if (ipo.listingDate != null) _TimelineEvent('상장일', ipo.listingDate!, null, AppColors.listing),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('일정', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          ...events.asMap().entries.map((e) => _TimelineRow(event: e.value, isLast: e.key == events.length - 1)),
        ],
      ),
    );
  }
}

class _TimelineEvent {
  final String label;
  final DateTime start;
  final DateTime? end;
  final Color color;
  _TimelineEvent(this.label, this.start, this.end, this.color);
}

class _TimelineRow extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast;
  const _TimelineRow({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isPast = event.start.isBefore(today) && (event.end == null || event.end!.isBefore(today));

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: isPast ? AppColors.border : event.color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                children: [
                  Text(event.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isPast ? AppColors.textTertiary : AppColors.textPrimary)),
                  const Spacer(),
                  Text(
                    event.end != null
                        ? '${AppDateUtils.formatMD(event.start)} ~ ${AppDateUtils.formatMD(event.end!)}'
                        : AppDateUtils.formatYMD(event.start),
                    style: TextStyle(fontSize: 13, color: isPast ? AppColors.textTertiary : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionInfoCard extends StatelessWidget {
  final IPO ipo;
  const _SubscriptionInfoCard({required this.ipo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('청약 정보', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          _StatRow('공모가', ipo.priceBandText),
          const SizedBox(height: 8),
          _StatRow('최소 청약 수량', '${ipo.minSubscriptionQty}주'),
          const SizedBox(height: 8),
          _StatRow('증거금 비율', '${(ipo.depositRatio * 100).toInt()}%'),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('최소 청약 가능 금액', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(
                ipo.minSubscriptionAmount != null
                    ? CurrencyUtils.format(ipo.minSubscriptionAmount!)
                    : '확정 전',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnderwriterCard extends StatelessWidget {
  final IPO ipo;
  const _UnderwriterCard({required this.ipo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('주간사', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ipo.leadUnderwriters.map((u) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Text(u, style: AppTextStyles.body2),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body2),
        Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _BottomCTA extends StatelessWidget {
  final IPO ipo;
  final bool isWatched;
  final WidgetRef ref;
  const _BottomCTA({required this.ipo, required this.isWatched, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => ref.read(watchlistRepositoryProvider).toggle(ipo.id),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(isWatched ? '관심 해제' : '관심 등록', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => context.push(
                  '/subscription/new?ipoId=${Uri.encodeComponent(ipo.id)}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('청약 기록하기', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
