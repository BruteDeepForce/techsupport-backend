import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import 'technician_signature_page.dart';

class TechnicianPaymentPage extends StatefulWidget {
  const TechnicianPaymentPage(
      {super.key, required this.operationId, this.title});

  final String operationId;
  final String? title;

  @override
  State<TechnicianPaymentPage> createState() => _TechnicianPaymentPageState();
}

class _TechnicianPaymentPageState extends State<TechnicianPaymentPage> {
  final TextEditingController _amountController =
      TextEditingController(text: '');
  final TextEditingController _noteController = TextEditingController();

  String _method = 'card';
  bool _confirmed = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double? get _amount {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null || value <= 0) return null;
    return value;
  }

  bool get _canContinue => _confirmed && _amount != null;

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Ödeme Al',
      subtitle: 'İş Emri Tamamlama',
      showBack: true,
      tabBar: const SizedBox.shrink(),
      children: [
        LinearCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accentBg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.payments_outlined,
                        color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title?.isNotEmpty == true
                              ? widget.title!
                              : 'İş Emri #${_shortId(widget.operationId)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ödeme bilgilerini tamamlayınız',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionTitle('Ödeme Tutarı'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Örn. 1500,00',
                  prefixIcon: const Icon(Icons.currency_lira_rounded),
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LinearCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Ödeme Yöntemi'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MethodChip(
                    label: 'Kart',
                    icon: Icons.credit_card_rounded,
                    active: _method == 'card',
                    onTap: () => setState(() => _method = 'card'),
                  ),
                  _MethodChip(
                    label: 'Nakit',
                    icon: Icons.payments_rounded,
                    active: _method == 'cash',
                    onTap: () => setState(() => _method = 'cash'),
                  ),
                  _MethodChip(
                    label: 'Havale',
                    icon: Icons.account_balance_rounded,
                    active: _method == 'transfer',
                    onTap: () => setState(() => _method = 'transfer'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionTitle('Not (Opsiyonel)'),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ödeme ile ilgili kısa not...',
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LinearCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Onay'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ödeme alındı ve müşteriye teslim edilecek.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _confirmed,
                    onChanged: (v) => setState(() => _confirmed = v),
                    activeColor: AppColors.statusGreen,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded,
                        size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _amount == null
                            ? 'Tutar girilmedi'
                            : 'Toplam: ${_amount!.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      _methodLabel(_method),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Vazgeç'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _canContinue
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => TechnicianSignaturePage(
                              workOrderId: _shortId(widget.operationId),
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Ödemeyi Al'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accentBg : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: active ? AppColors.accent : AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _methodLabel(String value) {
  switch (value) {
    case 'cash':
      return 'Nakit';
    case 'transfer':
      return 'Havale';
    default:
      return 'Kart';
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
