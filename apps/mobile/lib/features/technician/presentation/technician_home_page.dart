import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import 'technician_signature_page.dart';

class TechnicianHomePage extends StatelessWidget {
  const TechnicianHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Teknisyen',
      subtitle: 'Teknisyen Portalı',
      trailing: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text('TJ',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
      ),
      tabBar: const LinearTabBar(
        items: [
          LinearTabItem(
              icon: Icons.assignment_outlined,
              label: 'İş Emirleri',
              active: true,
              count: 2),
          LinearTabItem(
              icon: Icons.confirmation_number_outlined, label: 'Talepler'),
          LinearTabItem(
              icon: Icons.devices_other_outlined, label: 'Cihazlar'),
          LinearTabItem(icon: Icons.logout_rounded, label: 'Çıkış'),
        ],
      ),
      children: [
        // ── Metrics ──────────────────────────────────────────────
        Row(
          children: const [
            Expanded(
                child: LinearStatPill(
                    value: '2',
                    label: 'Aktif',
                    color: AppColors.statusBlue)),
            SizedBox(width: 8),
            Expanded(
                child: LinearStatPill(
                    value: '0',
                    label: 'Çözülen',
                    color: AppColors.statusGreen)),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: LinearCommand(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Cihaz Tara',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LinearCommand(
                icon: Icons.playlist_add_check_circle_rounded,
                label: 'İş Al',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        const LinearFilterTabs(
          labels: ['Sıradaki İşler', 'Atanmamış'],
          selectedIndex: 0,
        ),

        const SizedBox(height: 14),

        // ── Operation cards ──────────────────────────────────────
        _OpCard(
          id: 'TS-2',
          title: 'Printer not responding to print jobs',
          subtitle:
              'The reception printer stopped working after a large print batch...',
          customer: 'Alice Morgan',
          device: 'Reception Printer',
          priority: AppColors.statusRed,
          status: 'Devam Ediyor',
          time: '1 saat önce',
        ),
        const SizedBox(height: 8),
        _OpCard(
          id: 'TS-5',
          title: 'Need to migrate data from old server',
          subtitle:
              'Old Dell server has important data that needs to be moved...',
          customer: 'Bob Williams',
          device: 'Old Server',
          priority: AppColors.statusRed,
          status: 'Devam Ediyor',
          time: '3 saat önce',
        ),
      ],
    );
  }
}

class _OpCard extends StatelessWidget {
  const _OpCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.customer,
    required this.device,
    required this.priority,
    required this.status,
    required this.time,
  });

  final String id;
  final String title;
  final String subtitle;
  final String customer;
  final String device;
  final Color priority;
  final String status;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LinearPriority(color: priority),
              const SizedBox(width: 8),
              Text(id,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textTertiary)),
              const Spacer(),
              LinearBadge(label: status, color: AppColors.statusYellow),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 10),
          Row(
            children: [
              _Tag(Icons.devices_other_outlined, device),
              const SizedBox(width: 8),
              _Tag(Icons.person_outline_rounded, customer),
              const Spacer(),
              Text(time,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textTertiary, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Detay'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TechnicianSignaturePage(workOrderId: id),
                      ),
                    );
                  },
                  child: const Text('Tamamla'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
