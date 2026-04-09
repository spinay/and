import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_utils.dart';
import '../../data/models/ipo.dart';
import '../../data/models/subscription.dart';
import '../../data/repositories/ipo_repository.dart';
import '../../data/repositories/subscription_repository.dart';

/// 청약 기록 추가/수정 폼.
///
/// - 신규(`editingId == null`): IPO를 선택한 뒤 증권사/수량/증거금을 입력
/// - 수정: 기존 레코드를 불러와서 편집, 상태별 추가 필드가 펼쳐진다
///
/// [initialFocus]는 home 카드의 CTA에서 넘겨준다. 예를 들어 '환불일'
/// 카드를 누르면 `SubscriptionFormFocus.refund`로 진입해 환불 필드로
/// 초기 스크롤하고, 저장 시 상태를 `refunded`로 자동 승격시킨다.
class SubscriptionFormScreen extends ConsumerStatefulWidget {
  const SubscriptionFormScreen({
    super.key,
    this.editingId,
    this.initialIpoId,
    this.initialFocus = SubscriptionFormFocus.basic,
  });

  /// 수정 모드라면 기존 Subscription.id. 신규면 null.
  final int? editingId;

  /// 신규 생성 시 종목을 미리 고정할 수 있다 (상세 화면에서 진입할 때).
  final String? initialIpoId;

  /// 진입 직후 포커스해야 할 섹션.
  final SubscriptionFormFocus initialFocus;

  @override
  ConsumerState<SubscriptionFormScreen> createState() =>
      _SubscriptionFormScreenState();
}

enum SubscriptionFormFocus { basic, allocation, sale }

class _SubscriptionFormScreenState
    extends ConsumerState<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 폼 필드
  IPO? _selectedIpo;
  final _brokerCtrl = TextEditingController();
  final _appliedQtyCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _allocatedQtyCtrl = TextEditingController();
  final _refundCtrl = TextEditingController();
  final _sellPriceCtrl = TextEditingController();
  final _sellQtyCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  SubscriptionStatus _status = SubscriptionStatus.applied;

  bool _loadedEditing = false;

  @override
  void dispose() {
    _brokerCtrl.dispose();
    _appliedQtyCtrl.dispose();
    _depositCtrl.dispose();
    _allocatedQtyCtrl.dispose();
    _refundCtrl.dispose();
    _sellPriceCtrl.dispose();
    _sellQtyCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.editingId != null;

  /// 섹션을 어디까지 펼쳐 보일지 결정하는 로직.
  /// - 신규: initialFocus에 따라 기본/배정/매도까지
  /// - 수정: 현재 status와 initialFocus 중 더 뒤쪽
  bool get _showAllocation =>
      _status.index >= SubscriptionStatus.allocated.index ||
      widget.initialFocus != SubscriptionFormFocus.basic;

  bool get _showSale =>
      _status.index >= SubscriptionStatus.listed.index ||
      widget.initialFocus == SubscriptionFormFocus.sale;

  @override
  Widget build(BuildContext context) {
    // 수정 모드라면 첫 빌드에서 기존 값 로드
    if (_isEditing && !_loadedEditing) {
      _tryLoadEditing();
    }

    // initialIpoId가 있으면 해당 IPO를 선택 상태로
    if (!_isEditing && _selectedIpo == null && widget.initialIpoId != null) {
      final ipos = ref.read(ipoListProvider);
      for (final ipo in ipos) {
        if (ipo.id == widget.initialIpoId) {
          _selectedIpo = ipo;
          _onIpoChanged(ipo);
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? '청약 기록 수정' : '청약 기록 추가'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.loss,
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('기본 정보', [
              _ipoPicker(),
              const SizedBox(height: 12),
              _textField(
                controller: _brokerCtrl,
                label: '증권사',
                hint: '예: 미래에셋증권',
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _appliedQtyCtrl,
                label: '청약 수량 (주)',
                hint: '예: 20',
                keyboardType: TextInputType.number,
                onChanged: (_) => _recomputeDeposit(),
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _depositCtrl,
                label: '납입 증거금 (원)',
                hint: '예: 550000',
                keyboardType: TextInputType.number,
              ),
            ]),
            if (_showAllocation) ...[
              const SizedBox(height: 16),
              _section('배정 단계', [
                _textField(
                  controller: _allocatedQtyCtrl,
                  label: '배정 수량 (주)',
                  hint: '예: 3',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recomputeRefund(),
                ),
                const SizedBox(height: 12),
                _textField(
                  controller: _refundCtrl,
                  label: '환불 금액 (원)',
                  hint: '자동 계산됨',
                  keyboardType: TextInputType.number,
                ),
              ]),
            ],
            if (_showSale) ...[
              const SizedBox(height: 16),
              _section('매도 단계', [
                _textField(
                  controller: _sellPriceCtrl,
                  label: '매도 가격 (원)',
                  hint: '주당',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _textField(
                  controller: _sellQtyCtrl,
                  label: '매도 수량 (주)',
                  hint: '예: 3',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _profitPreview(),
              ]),
            ],
            const SizedBox(height: 16),
            _section('메모', [
              _textField(
                controller: _memoCtrl,
                label: '',
                hint: '자유롭게 기록',
                maxLines: 3,
              ),
            ]),
            const SizedBox(height: 16),
            _statusPicker(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isEditing ? '저장' : '추가',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── 섹션/필드 빌더 ────────────────────────────────────────

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _ipoPicker() {
    final ipos = ref.watch(ipoListProvider);
    return InkWell(
      onTap: _isEditing ? null : () => _showIpoSheet(ipos),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('종목',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    _selectedIpo?.companyName ?? '종목을 선택해주세요',
                    style: _selectedIpo != null
                        ? AppTextStyles.body1
                            .copyWith(fontWeight: FontWeight.w600)
                        : AppTextStyles.body2,
                  ),
                ],
              ),
            ),
            if (!_isEditing)
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label.isEmpty ? null : label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _profitPreview() {
    final preview = _computeProfit();
    if (preview == null) {
      return const SizedBox.shrink();
    }
    final positive = preview.amount >= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (positive ? AppColors.profit : AppColors.loss)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('예상 수익',
              style:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(
            '${positive ? '+' : ''}${CurrencyUtils.format(preview.amount)}'
            '  (${preview.rate.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: positive ? AppColors.profit : AppColors.loss,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('진행 상태', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SubscriptionStatus.values.map((s) {
              final selected = _status == s;
              return ChoiceChip(
                label: Text(s.label),
                selected: selected,
                onSelected: (_) => setState(() => _status = s),
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── 동작 ────────────────────────────────────────────────

  void _showIpoSheet(List<IPO> ipos) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('종목 선택',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: ipos.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final ipo = ipos[i];
                      return ListTile(
                        title: Text(ipo.companyName),
                        subtitle: Text(
                            '${ipo.sector}  •  ${_dateLabel(ipo.subscriptionStart)}'),
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedIpo = ipo;
                            _onIpoChanged(ipo);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 종목이 선택되면 증거금/수량의 힌트를 IPO 정보로부터 자동 채운다.
  void _onIpoChanged(IPO ipo) {
    if (_appliedQtyCtrl.text.isEmpty) {
      _appliedQtyCtrl.text = ipo.minSubscriptionQty.toString();
    }
    _recomputeDeposit();
  }

  /// 청약 수량 * 공모가 * 증거금 비율
  void _recomputeDeposit() {
    final ipo = _selectedIpo;
    if (ipo == null) return;
    final qty = int.tryParse(_appliedQtyCtrl.text);
    final price = ipo.confirmedPrice ?? ipo.priceBandHigh;
    if (qty == null || price == null) return;
    final deposit = (qty * price * ipo.depositRatio).round();
    _depositCtrl.text = deposit.toString();
  }

  /// 배정 수량 * 공모가 - 청약 증거금 (→ 환불액)
  void _recomputeRefund() {
    final ipo = _selectedIpo;
    if (ipo == null) return;
    final deposit = int.tryParse(_depositCtrl.text);
    final allocQty = int.tryParse(_allocatedQtyCtrl.text);
    final price = ipo.confirmedPrice ?? ipo.priceBandHigh;
    if (deposit == null || allocQty == null || price == null) return;
    final paid = allocQty * price;
    final refund = deposit - paid;
    if (refund >= 0) {
      _refundCtrl.text = refund.toString();
    }
  }

  _ProfitPreview? _computeProfit() {
    final ipo = _selectedIpo;
    if (ipo == null) return null;
    final sellPrice = int.tryParse(_sellPriceCtrl.text);
    final sellQty = int.tryParse(_sellQtyCtrl.text);
    final buyPrice = ipo.confirmedPrice ?? ipo.priceBandHigh;
    if (sellPrice == null || sellQty == null || buyPrice == null) return null;
    final cost = buyPrice * sellQty;
    final revenue = sellPrice * sellQty;
    final profit = revenue - cost;
    final rate = cost == 0 ? 0.0 : (profit / cost) * 100;
    return _ProfitPreview(amount: profit, rate: rate);
  }

  void _tryLoadEditing() {
    final list = ref.read(subscriptionListProvider).valueOrNull;
    if (list == null) return; // 아직 스트림이 안 올라옴 — 다음 프레임에 재시도
    final id = widget.editingId!;
    Subscription? target;
    for (final s in list) {
      if (s.id == id) {
        target = s;
        break;
      }
    }
    if (target == null) return;

    final ipos = ref.read(ipoListProvider);
    IPO? ipo;
    for (final e in ipos) {
      if (e.id == target.ipoId) {
        ipo = e;
        break;
      }
    }

    _selectedIpo = ipo;
    _brokerCtrl.text = target.broker ?? '';
    _appliedQtyCtrl.text = target.appliedQty?.toString() ?? '';
    _depositCtrl.text = target.depositAmount?.toString() ?? '';
    _allocatedQtyCtrl.text = target.allocatedQty?.toString() ?? '';
    _refundCtrl.text = target.refundAmount?.toString() ?? '';
    _sellPriceCtrl.text = target.sellPrice?.toString() ?? '';
    _sellQtyCtrl.text = target.sellQty?.toString() ?? '';
    _memoCtrl.text = target.memo ?? '';
    _status = target.status;
    _loadedEditing = true;
  }

  Future<void> _save() async {
    final ipo = _selectedIpo;
    if (ipo == null) {
      _snack('종목을 먼저 선택해주세요');
      return;
    }

    final repo = ref.read(subscriptionRepositoryProvider);

    // initialFocus에 따라 상태 자동 승격 (아직 사용자가 수동으로 내리지 않은 경우)
    var finalStatus = _status;
    if (widget.initialFocus == SubscriptionFormFocus.allocation &&
        finalStatus.index < SubscriptionStatus.refunded.index) {
      finalStatus = SubscriptionStatus.refunded;
    }
    if (widget.initialFocus == SubscriptionFormFocus.sale &&
        finalStatus.index < SubscriptionStatus.sold.index) {
      finalStatus = SubscriptionStatus.sold;
    }

    final profit = _computeProfit();

    final model = Subscription(
      id: widget.editingId,
      ipoId: ipo.id,
      ipoName: ipo.companyName,
      broker: _brokerCtrl.text.trim().isEmpty ? null : _brokerCtrl.text.trim(),
      appliedQty: int.tryParse(_appliedQtyCtrl.text),
      depositAmount: int.tryParse(_depositCtrl.text),
      allocatedQty: int.tryParse(_allocatedQtyCtrl.text),
      refundAmount: int.tryParse(_refundCtrl.text),
      sellPrice: int.tryParse(_sellPriceCtrl.text),
      sellQty: int.tryParse(_sellQtyCtrl.text),
      profitAmount: profit?.amount,
      profitRate: profit?.rate,
      status: finalStatus,
      memo: _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim(),
      createdAt: _isEditing
          ? (ref.read(subscriptionListProvider).valueOrNull?.firstWhere(
                    (s) => s.id == widget.editingId,
                    orElse: () => _fallbackCreatedAt(ipo.id),
                  )
                  .createdAt ??
              DateTime.now())
          : DateTime.now(),
    );

    if (_isEditing) {
      await repo.update(model);
    } else {
      await repo.add(model);
    }

    if (!mounted) return;
    _snack(_isEditing ? '저장했어요' : '청약 기록을 추가했어요');
    context.pop();
  }

  Subscription _fallbackCreatedAt(String ipoId) => Subscription(
        ipoId: ipoId,
        ipoName: '',
        status: SubscriptionStatus.applied,
        createdAt: DateTime.now(),
      );

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('청약 기록 삭제'),
        content: const Text('정말 삭제할까요? 복구할 수 없어요.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.loss),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(subscriptionRepositoryProvider).delete(widget.editingId!);
    if (!mounted) return;
    _snack('삭제했어요');
    context.pop();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  String _dateLabel(DateTime? d) {
    if (d == null) return '일정 미정';
    return '${d.month}/${d.day}';
  }
}

class _ProfitPreview {
  final int amount;
  final double rate;
  _ProfitPreview({required this.amount, required this.rate});
}
