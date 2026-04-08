import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_utils.dart';
import '../../data/models/subscription.dart';
import '../../data/repositories/subscription_repository.dart';

class MyIPOScreen extends ConsumerStatefulWidget {
  const MyIPOScreen({super.key});

  @override
  ConsumerState<MyIPOScreen> createState() => _MyIPOScreenState();
}

class _MyIPOScreenState extends ConsumerState<MyIPOScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all =
        ref.watch(subscriptionListProvider).valueOrNull ?? const <Subscription>[];
    final active = all.where((s) => s.status != SubscriptionStatus.sold).toList();
    final done = all.where((s) => s.status == SubscriptionStatus.sold).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 청약'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: '진행중'), Tab(text: '완료')],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('청약 추가 기능 준비 중')));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('청약 추가', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _SubscriptionList(items: active),
          _SubscriptionList(items: done),
        ],
      ),
    );
  }
}

class _SubscriptionList extends StatelessWidget {
  final List<Subscription> items;
  const _SubscriptionList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('청약 기록이 없어요', style: AppTextStyles.body2));
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

  Color get _statusColor {
    switch (sub.status) {
      case SubscriptionStatus.applied: return AppColors.applied;
      case SubscriptionStatus.allocated: return AppColors.allocated;
      case SubscriptionStatus.refunded: return AppColors.refunded;
      case SubscriptionStatus.listed: return AppColors.listed;
      case SubscriptionStatus.sold: return AppColors.sold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Expanded(child: Text(sub.ipoName, style: AppTextStyles.heading3)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(sub.status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (sub.broker != null) _Row('증권사', sub.broker!),
          if (sub.appliedQty != null) _Row('청약 수량', '${sub.appliedQty}주'),
          if (sub.depositAmount != null) _Row('납입 증거금', CurrencyUtils.format(sub.depositAmount!)),
          if (sub.allocatedQty != null) _Row('배정 수량', '${sub.allocatedQty}주'),
          if (sub.refundAmount != null) _Row('환불 금액', CurrencyUtils.format(sub.refundAmount!)),
          if (sub.profitAmount != null) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('수익', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(
                  '${sub.profitAmount! >= 0 ? '+' : ''}${CurrencyUtils.format(sub.profitAmount!)}',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: sub.profitAmount! >= 0 ? AppColors.profit : AppColors.loss,
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _statusColor),
            ),
          ),
        ],
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
          Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
