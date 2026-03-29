import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearPageShell(
      title: 'Müşteri',
      subtitle: 'Müşteri Portalı',
      trailing: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text('AM',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
      ),
      tabBar: const LinearTabBar(
        items: [
          LinearTabItem(
              icon: Icons.grid_view_rounded,
              label: 'Ana Sayfa',
              active: true),
          LinearTabItem(
              icon: Icons.confirmation_number_outlined,
              label: 'Talepler',
              count: 3),
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
                    value: '3',
                    label: 'Açık',
                    color: AppColors.statusBlue)),
            SizedBox(width: 8),
            Expanded(
                child: LinearStatPill(
                    value: '1',
                    label: 'Devam Eden',
                    color: AppColors.statusYellow)),
            SizedBox(width: 8),
            Expanded(
                child: LinearStatPill(
                    value: '12',
                    label: 'Çözülen',
                    color: AppColors.statusGreen)),
          ],
        ),

        const SizedBox(height: 12),

        // ── Quick actions ────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: LinearCommand(
                icon: Icons.add_rounded,
                label: 'Yeni Talep',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LinearCommand(
                icon: Icons.search_rounded,
                label: 'Takip Et',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Issues ──────────────────────────────────────────────
        const LinearSection(title: 'Son Talepler', count: 3),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              LinearIssueRow(
                id: 'TS-1',
                title: 'Laptop screen flickering randomly',
                priority: AppColors.statusOrange,
                statusColor: AppColors.statusBlue,
                label: 'HIGH',
                labelColor: AppColors.statusOrange,
                assignee: 'TJ',
              ),
              LinearIssueRow(
                id: 'TS-2',
                title: 'Printer not responding to print jobs',
                priority: AppColors.statusRed,
                statusColor: AppColors.statusYellow,
                label: 'CRITICAL',
                labelColor: AppColors.statusRed,
                assignee: 'TJ',
              ),
              LinearIssueRow(
                id: 'TS-3',
                title: 'Software installation request',
                priority: AppColors.statusBlue,
                statusColor: AppColors.statusGreen,
                label: 'MEDIUM',
                labelColor: AppColors.statusBlue,
                showDivider: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Devices ──────────────────────────────────────────────
        const LinearSection(title: 'Cihazlarım', count: 2),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _DeviceRow(
                title: 'Office Laptop #1',
                subtitle: 'Dell XPS 15  ·  DXP15-001-2024',
                status: 'Aktif',
                statusColor: AppColors.statusGreen,
              ),
              _DeviceRow(
                title: 'Reception Printer',
                subtitle: 'HP LaserJet Pro  ·  HPL-REC-2023',
                status: 'Bakımda',
                statusColor: AppColors.statusYellow,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom:
                    BorderSide(color: AppColors.borderSubtle, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          const Icon(Icons.devices_other_outlined,
              color: AppColors.textTertiary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          LinearBadge(label: status, color: statusColor),
        ],
      ),
    );
  }
}
