import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../data/models/ipo.dart';
import '../../data/models/subscription.dart';
import '../../data/repositories/ipo_repository.dart';
import '../../data/repositories/subscription_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final ipos = ref.watch(ipoListProvider);
    final subscriptions =
        ref.watch(subscriptionListProvider).valueOrNull ?? const <Subscription>[];
    final todayEvents = _getTodayActions(ipos, subscriptions, today);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(today, todayEvents.length)),
            if (todayEvents.isNotEmpty) ...[
              SliverToBoxAdapter(child: _sectionTitle('오늘 할 일', todayEvents.length)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _ActionCard(action: todayEvents[i]),
                  childCount: todayEvents.length,
                ),
              ),
            ] else
              SliverToBoxAdapter(child: _emptyToday()),
            SliverToBoxAdapter(child: _sectionTitle('이번 주 일정', null)),
            SliverToBoxAdapter(child: _WeekPreview(ipos: ipos, today: today)),
            SliverToBoxAdapter(child: _sectionTitle('내 청약 현황', subscriptions.length)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _MySubscriptionCard(sub: subscriptions[i]),
                childCount: subscriptions.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime today, int actionCount) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final wd = weekdays[today.weekday - 1];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${today.month}월 ${today.day}일 ($wd)', style: AppTextStyles.body2),
          const SizedBox(height: 4),
          Text(
            actionCount > 0 ? '오늘 해야 할 일이 $actionCount건 있어요' : '오늘은 예정된 일정이 없어요',
            style: AppTextStyles.heading2,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, int? count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.heading3),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyToday() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text('오늘은 공모주 이벤트가 없어요 🎉', style: AppTextStyles.body2),
      ),
    );
  }

  List<_TodayAction> _getTodayActions(List<IPO> ipos, List<Subscription> subs, DateTime today) {
    final actions = <_TodayAction>[];
    bool same(DateTime? d) => d != null && AppDateUtils.isSameDay(d, today);

    for (final ipo in ipos) {
      if (same(ipo.demandForecastStart)) {
        actions.add(_TodayAction(ipo: ipo, type: _ActionType.demandForecast));
      }
      if (same(ipo.subscriptionStart)) {
        actions.add(_TodayAction(ipo: ipo, type: _ActionType.subscriptionStart));
      }
      if (same(ipo.subscriptionEnd)) {
        actions.add(_TodayAction(ipo: ipo, type: _ActionType.subscriptionEnd));
      }
    }
    for (final sub in subs) {
      // catalog에 없는 고아 청약 기록은 skip (절대 ipos.first로 fallback하지 않는다)
      IPO? ipo;
      for (final i in ipos) {
        if (i.id == sub.ipoId) {
          ipo = i;
          break;
        }
      }
      if (ipo == null) continue;
      if (same(ipo.refundDate)) {
        actions.add(_TodayAction(ipo: ipo, type: _ActionType.refund, sub: sub));
      }
      if (same(ipo.listingDate)) {
        actions.add(_TodayAction(ipo: ipo, type: _ActionType.listing, sub: sub));
      }
    }
    return actions;
  }
}

enum _ActionType { demandForecast, subscriptionStart, subscriptionEnd, refund, listing }

class _TodayAction {
  final IPO ipo;
  final _ActionType type;
  final Subscription? sub;
  _TodayAction({required this.ipo, required this.type, this.sub});

  String get title {
    switch (type) {
      case _ActionType.demandForecast: return '수요예측 시작';
      case _ActionType.subscriptionStart: return '청약 시작';
      case _ActionType.subscriptionEnd: return '청약 마감';
      case _ActionType.refund: return '환불일';
      case _ActionType.listing: return '상장일';
    }
  }

  Color get color {
    switch (type) {
      case _ActionType.demandForecast: return AppColors.forecast;
      case _ActionType.subscriptionStart:
      case _ActionType.subscriptionEnd: return AppColors.subscription;
      case _ActionType.refund: return AppColors.refund;
      case _ActionType.listing: return AppColors.listing;
    }
  }

  String get ctaLabel {
    switch (type) {
      case _ActionType.demandForecast: return '상세 보기';
      case _ActionType.subscriptionStart: return '청약하러 가기';
      case _ActionType.subscriptionEnd: return '청약 마감 확인';
      case _ActionType.refund: return '환불금 기록하기';
      case _ActionType.listing: return '매도 기록하기';
    }
  }

  /// CTA가 눌렸을 때 이동할 경로.
  String get ctaRoute {
    switch (type) {
      case _ActionType.demandForecast:
        return '/detail/${ipo.id}';
      case _ActionType.subscriptionStart:
        return '/subscription/new?ipoId=${Uri.encodeComponent(ipo.id)}';
      case _ActionType.subscriptionEnd:
        return '/detail/${ipo.id}';
      case _ActionType.refund:
        final id = sub?.id;
        return id != null
            ? '/subscription/edit/$id?focus=allocation'
            : '/detail/${ipo.id}';
      case _ActionType.listing:
        final id = sub?.id;
        return id != null
            ? '/subscription/edit/$id?focus=sale'
            : '/detail/${ipo.id}';
    }
  }
}

class _ActionCard extends ConsumerWidget {
  final _TodayAction action;
  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: action.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(action.title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: action.color)),
                ),
                const SizedBox(height: 4),
                Text(action.ipo.companyName, style: AppTextStyles.heading3),
                if (action.ipo.confirmedPrice != null)
                  Text('공모가 ${CurrencyUtils.format(action.ipo.confirmedPrice!)}', style: AppTextStyles.body2),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(action.ctaRoute),
            child: Text(action.ctaLabel, style: TextStyle(color: action.color, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _WeekPreview extends StatelessWidget {
  final List<IPO> ipos;
  final DateTime today;
  const _WeekPreview({required this.ipos, required this.today});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (ctx, i) {
          final date = today.add(Duration(days: i));
          final hasEvent = ipos.any((ipo) {
            bool same(DateTime? d) => d != null && AppDateUtils.isSameDay(d, date);
            return same(ipo.demandForecastStart) ||
                same(ipo.subscriptionStart) || same(ipo.subscriptionEnd) ||
                same(ipo.refundDate) || same(ipo.listingDate);
          });
          final isToday = i == 0;
          final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
          return Container(
            width: 48,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isToday ? AppColors.primary : AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(weekdays[date.weekday - 1], style: TextStyle(fontSize: 11, color: isToday ? Colors.white70 : AppColors.textTertiary)),
                const SizedBox(height: 4),
                Text('${date.day}', style: TextStyle(fontWeight: FontWeight.w700, color: isToday ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 4),
                if (hasEvent)
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.white : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MySubscriptionCard extends ConsumerWidget {
  final Subscription sub;
  const _MySubscriptionCard({required this.sub});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(sub.status);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sub.ipoName, style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(sub.status.nextAction, style: AppTextStyles.body2),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(sub.status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(SubscriptionStatus s) {
    switch (s) {
      case SubscriptionStatus.applied: return AppColors.applied;
      case SubscriptionStatus.allocated: return AppColors.allocated;
      case SubscriptionStatus.refunded: return AppColors.refunded;
      case SubscriptionStatus.listed: return AppColors.listed;
      case SubscriptionStatus.sold: return AppColors.sold;
    }
  }
}
