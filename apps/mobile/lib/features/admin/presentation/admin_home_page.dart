import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import 'admin_tickets_page.dart';
import 'admin_devices_page.dart';
import 'admin_team_page.dart';
import 'admin_work_orders_page.dart';
import 'admin_ai_autonomous_page.dart';
import 'inventory_management_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearPageShell(
      title: 'Genel Bakış',
      subtitle: 'Admin Portal',
      trailing: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text('AU',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
      ),
      tabBar: LinearTabBar(
        items: [
          const LinearTabItem(
              icon: Icons.grid_view_rounded,
              label: 'Bakış',
              active: true),
          LinearTabItem(
              icon: Icons.confirmation_number_outlined,
              label: 'Talep',
              count: 6,
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
          LinearTabItem(
              icon: Icons.assignment_rounded, 
              label: 'İş Emri',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminWorkOrdersPage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
          LinearTabItem(
              icon: Icons.devices_other_outlined, 
              label: 'Cihaz',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminDevicesPage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
          LinearTabItem(
              icon: Icons.inventory_2_outlined,
              label: 'Stok',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const InventoryManagementPage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
          LinearTabItem(
              icon: Icons.group_outlined, 
              label: 'Ekip',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminTeamPage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
        ],
      ),
      children: [
        // ── AI Autonomous Mode Card (Corporate Blue Edition) ───────────────
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAIAutonomousPage())),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Otonom Yönetim', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Otomasyon ve Akıllı Servis Merkezi', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Unified metrics strip (Separated Cards) ────────────────
        LinearCard(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              children: [
                _MetricCell(value: '6', label: 'Toplam', color: AppColors.accent),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(value: '16.7%', label: 'Çözüm Oranı', color: AppColors.textPrimary),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(value: '0', label: 'Kritik', color: AppColors.statusGreen),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        LinearCard(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              children: [
                _MetricCell(value: '3', label: 'Açık', color: AppColors.statusYellow),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(value: '2', label: 'Devam', color: AppColors.statusBlue),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(value: '1', label: 'Çözüldü', color: AppColors.statusGreen),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        LinearCard(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              children: [
                _MetricCell(value: '4', label: 'Cihaz', color: AppColors.textPrimary),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(value: '1', label: 'Bakımda', color: AppColors.statusOrange),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(value: '4', label: 'Personel', color: AppColors.textPrimary),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Recent issues ────────────────────────────────────────
        LinearSection(
          title: 'Son Talepler',
          trailing: GestureDetector(
            child: Text('Tümü',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.accent)),
          ),
        ),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              LinearIssueRow(
                id: 'TS-1',
                title: 'Laptop screen flickering',
                priority: AppColors.statusOrange,
                statusColor: AppColors.statusBlue,
                label: 'Açık',
                labelColor: AppColors.statusBlue,
                assignee: 'AM',
                onTap: () => Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                    transitionDuration: Duration.zero,
                  ),
                ),
              ),
              LinearIssueRow(
                id: 'TS-2',
                title: 'Printer not responding',
                priority: AppColors.statusRed,
                statusColor: AppColors.statusYellow,
                label: 'Devam',
                labelColor: AppColors.statusYellow,
                assignee: 'AM',
                onTap: () => Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                    transitionDuration: Duration.zero,
                  ),
                ),
              ),
              LinearIssueRow(
                id: 'TS-3',
                title: 'Software installation request',
                priority: AppColors.statusBlue,
                statusColor: AppColors.statusGreen,
                label: 'Çözüldü',
                labelColor: AppColors.statusGreen,
                assignee: 'BW',
                showDivider: false,
                onTap: () => Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                    transitionDuration: Duration.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Device status ────────────────────────────────────────
        const LinearSection(title: 'Cihaz Durumu'),
        LinearCard(
          child: Column(
            children: const [
              _ProgressRow(
                  label: 'Aktif', count: '2', color: AppColors.statusGreen, pct: 0.5),
              SizedBox(height: 12),
              _ProgressRow(
                  label: 'Bakımda',
                  count: '1',
                  color: AppColors.statusYellow,
                  pct: 0.25),
              SizedBox(height: 12),
              _ProgressRow(
                  label: 'Pasif',
                  count: '1',
                  color: AppColors.statusGray,
                  pct: 0.25),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Inventory Status ─────────────────────────────────────
        const LinearSection(title: 'Stok Yönetimi'),
        LinearCard(
          child: Column(
            children: const [
              _ProgressRow(
                  label: 'Yedek Parça', count: '142', color: AppColors.accent, pct: 0.75),
              SizedBox(height: 12),
              _ProgressRow(
                  label: 'Kritik Seviye',
                  count: '3',
                  color: AppColors.statusRed,
                  pct: 0.1),
              SizedBox(height: 12),
              _ProgressRow(
                  label: 'Yolda',
                  count: '12',
                  color: AppColors.statusBlue,
                  pct: 0.15),
            ],
          ),
        ),


      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.count,
    required this.color,
    required this.pct,
  });

  final String label;
  final String count;
  final Color color;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
            ),
            const SizedBox(width: 8),
            Expanded(
                child: Text(label, style: theme.textTheme.titleMedium)),
            Text(count, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 4,
            backgroundColor: AppColors.bgElevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
