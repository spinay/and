import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/notification_prefs.dart';
import '../../data/repositories/personal_db_provider.dart';
import '../../data/repositories/watchlist_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);

    Future<void> rescheduleAll() async {
      // prefs → NotificationService에 즉시 반영 + 관심종목 전체 재스케줄
      NotificationService.instance.applyPrefs(
        subscription: prefs.subscription,
        refund: prefs.refund,
        listing: prefs.listing,
      );
      final db = ref.read(personalDbProvider);
      final catalog = ref.read(catalogRepositoryProvider);
      final watched = await db.getWatchlist();
      await NotificationService.instance.cancelAll();
      for (final ipo in catalog) {
        if (watched.contains(ipo.id)) {
          await NotificationService.instance.scheduleForIpo(ipo);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const _SectionHeader('알림 설정'),
          _SwitchTile(
            '청약 시작 D-1 알림',
            '관심종목 청약 시작 전날 오전 9시',
            prefs.subscription,
            (v) async {
              await notifier.setSubscription(v);
              await rescheduleAll();
            },
          ),
          _SwitchTile(
            '환불일 알림',
            '환불 당일 오전 9시',
            prefs.refund,
            (v) async {
              await notifier.setRefund(v);
              await rescheduleAll();
            },
          ),
          _SwitchTile(
            '상장일 알림',
            '상장 당일 오전 9시',
            prefs.listing,
            (v) async {
              await notifier.setListing(v);
              await rescheduleAll();
            },
          ),
          const Divider(),
          const _SectionHeader('데이터'),
          _ActionTile(
            '내 청약 기록 초기화',
            Icons.delete_outline,
            AppColors.loss,
            () => _confirmWipeSubscriptions(context, ref),
          ),
          _ActionTile(
            '관심종목 모두 해제',
            Icons.star_outline,
            AppColors.textSecondary,
            () => _confirmClearWatchlist(context, ref),
          ),
          const Divider(),
          const _SectionHeader('앱 정보'),
          const _InfoTile('버전', '1.0.0'),
          const _InfoTile('문의', 'support@ipokeeper.app'),
        ],
      ),
    );
  }

  Future<void> _confirmWipeSubscriptions(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('청약 기록 초기화'),
        content: const Text('모든 청약 기록이 삭제됩니다. 복구할 수 없어요. 계속하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.loss),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final db = ref.read(personalDbProvider);
    final list = await db.watchSubscriptions().first;
    for (final row in list) {
      await db.deleteSubscription(row.id);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('청약 기록을 모두 삭제했어요')),
      );
    }
  }

  Future<void> _confirmClearWatchlist(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('관심종목 초기화'),
        content: const Text('등록된 관심종목이 모두 해제되고, 예약된 알림도 함께 취소됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('해제'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final repo = ref.read(watchlistRepositoryProvider);
    final set = await repo.watch().first;
    for (final id in set) {
      await repo.remove(id);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관심종목을 모두 해제했어요')),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: AppTextStyles.label),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile(this.title, this.subtitle, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.body1),
      subtitle: Text(subtitle, style: AppTextStyles.body2),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primaryLight,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile(this.title, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(color: color)),
      leading: Icon(icon, color: color),
      onTap: onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: AppTextStyles.body1),
      trailing: Text(value, style: AppTextStyles.body2),
    );
  }
}
