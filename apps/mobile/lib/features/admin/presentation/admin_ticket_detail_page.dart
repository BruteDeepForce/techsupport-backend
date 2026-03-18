import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';

class AdminTicketDetailPage extends StatelessWidget {
  const AdminTicketDetailPage({
    super.key,
    required this.id,
    required this.title,
    required this.statusLabel,
    required this.statusColor,
  });

  final String id;
  final String title;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Talep Detayı',
      subtitle: id,
      showBack: true,
      tabBar: const SizedBox.shrink(),
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 18),
      ),
      children: [
        // ── Main Content Loop ──────────────────────────────────
        LinearCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LinearBadge(label: statusLabel, color: statusColor),
                  const Text('18 Mar 2026, 10:45', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Text(
                'Cihaz açılmıyor, güç düğmesine basıldığında herhangi bir tepki vermiyor. Şarj aleti denendi ancak sonuç değişmedi.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const LinearSection(title: 'Cihaz ve Kullanıcı Bilgisi'),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _DetailRow(icon: Icons.person_outline_rounded, label: 'Talep Eden', value: 'Ahmet Yılmaz'),
              _DetailRow(icon: Icons.laptop_mac_rounded, label: 'Cihaz', value: 'MacBook Pro 14" (SN: ABC-12345)'),
              _DetailRow(icon: Icons.location_on_outlined, label: 'Konum', value: 'Merkez Ofis - Kat 3', showDivider: false),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Actions ──────────────────────────────────────────
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Action: Approve & Create Work Order
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                ),
                child: const Text('Talebi Onayla (İş Emri Oluştur)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  // Action: Reject
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.statusRed),
                  foregroundColor: AppColors.statusRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                ),
                child: const Text('Talebi Reddet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        
        // ── History / Timeline (Optional SaaS touch) ──────────
        const LinearSection(title: 'İşlem Geçmişi'),
        LinearCard(
          child: Column(
            children: const [
              _HistoryItem(label: 'Talep oluşturuldu', time: '10:45', isFirst: true),
              _HistoryItem(label: 'Admin tarafından inceleniyor', time: '11:15', isLast: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value, this.showDivider = true});
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.label, required this.time, this.isFirst = false, this.isLast = false});
  final String label;
  final String time;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: isFirst ? AppColors.accent : AppColors.border, shape: BoxShape.circle),
            ),
            if (!isLast) Container(width: 2, height: 20, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
