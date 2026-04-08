import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _subscriptionNotify = true;
  bool _refundNotify = true;
  bool _listingNotify = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          _SectionHeader('알림 설정'),
          _SwitchTile('청약일 알림', '청약 시작/마감일 알림', _subscriptionNotify, (v) => setState(() => _subscriptionNotify = v)),
          _SwitchTile('환불일 알림', '환불금 입금 전날, 당일', _refundNotify, (v) => setState(() => _refundNotify = v)),
          _SwitchTile('상장일 알림', '상장 전날, 당일 오전 8시', _listingNotify, (v) => setState(() => _listingNotify = v)),
          const Divider(),
          _SectionHeader('데이터'),
          _ActionTile('내 청약 기록 초기화', Icons.delete_outline, AppColors.profit, () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('초기화'),
                content: const Text('모든 청약 기록이 삭제됩니다. 계속하시겠어요?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('삭제', style: TextStyle(color: AppColors.profit))),
                ],
              ),
            );
          }),
          const Divider(),
          _SectionHeader('앱 정보'),
          _InfoTile('버전', '1.0.0'),
          _InfoTile('문의', 'support@ipokeeper.app'),
        ],
      ),
    );
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
