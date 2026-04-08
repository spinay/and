import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_utils.dart';
import '../../data/models/subscription.dart';
import '../../data/repositories/subscription_repository.dart';

class ProfitScreen extends ConsumerWidget {
  const ProfitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs =
        ref.watch(subscriptionListProvider).valueOrNull ?? const <Subscription>[];
    final sold = subs.where((s) => s.status == SubscriptionStatus.sold).toList();
    final totalProfit = sold.fold(0, (sum, s) => sum + (s.profitAmount ?? 0));
    final totalCount = subs.length;
    final avgProfit = sold.isEmpty ? 0 : totalProfit ~/ sold.length;

    return Scaffold(
      appBar: AppBar(title: const Text('수익')),
      body: sold.isEmpty
          ? _EmptyProfit()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryCard(totalProfit: totalProfit, totalCount: totalCount, avgProfit: avgProfit),
                  const SizedBox(height: 16),
                  _MonthlyChart(subs: sold),
                  const SizedBox(height: 16),
                  _ProfitList(subs: sold),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int totalProfit;
  final int totalCount;
  final int avgProfit;
  const _SummaryCard({required this.totalProfit, required this.totalCount, required this.avgProfit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('누적 수익', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '${totalProfit >= 0 ? '+' : ''}${CurrencyUtils.format(totalProfit)}',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem('참여 횟수', '$totalCount건'),
              const SizedBox(width: 24),
              _StatItem('평균 수익', CurrencyUtils.formatShort(avgProfit)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final List<Subscription> subs;
  const _MonthlyChart({required this.subs});

  @override
  Widget build(BuildContext context) {
    // 최근 6개월 집계
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - 5 + i, 1));
    final data = months.map((m) {
      final profit = subs
          .where((s) => s.createdAt.year == m.year && s.createdAt.month == m.month)
          .fold(0, (sum, s) => sum + (s.profitAmount ?? 0));
      return BarChartGroupData(
        x: m.month,
        barRods: [BarChartRodData(toY: profit.toDouble(), color: profit >= 0 ? AppColors.profit : AppColors.loss, width: 20, borderRadius: BorderRadius.circular(4))],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('월별 수익', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(BarChartData(
              barGroups: data,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}월', style: AppTextStyles.caption),
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class _ProfitList extends StatelessWidget {
  final List<Subscription> subs;
  const _ProfitList({required this.subs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('종목별 수익', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          ...subs.map((s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(s.ipoName, style: AppTextStyles.body1)),
                Text(
                  '${(s.profitAmount ?? 0) >= 0 ? '+' : ''}${CurrencyUtils.format(s.profitAmount ?? 0)}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: (s.profitAmount ?? 0) >= 0 ? AppColors.profit : AppColors.loss),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _EmptyProfit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 12),
          Text('매도 완료된 종목이 없어요', style: AppTextStyles.body1),
          SizedBox(height: 4),
          Text('청약 후 매도 기록을 남겨보세요', style: AppTextStyles.body2),
        ],
      ),
    );
  }
}
