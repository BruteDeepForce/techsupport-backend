import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import 'admin_home_page.dart';
import 'admin_devices_page.dart';
import 'admin_team_page.dart';
import 'admin_work_orders_page.dart';
import 'inventory_management_page.dart';
import 'admin_ticket_detail_page.dart';

class AdminTicketsPage extends StatelessWidget {
  const AdminTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearPageShell(
      title: 'Talepler',
      subtitle: 'Admin Portal',
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 18),
      ),
      tabBar: LinearTabBar(
        items: [
          LinearTabItem(
            icon: Icons.grid_view_rounded,
            label: 'Bakış',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminHomePage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          const LinearTabItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Talep',
            count: 6,
            active: true,
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
        // ── Ticket Metrics ──────────────────────────────────────
        LinearCard(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              children: [
                _TicketMetric(value: '3', label: 'Açık', color: AppColors.statusYellow),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                _TicketMetric(value: '2', label: 'Devam', color: AppColors.statusBlue),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                _TicketMetric(value: '1', label: 'Çözüldü', color: AppColors.statusGreen),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Navigation & Filters ──────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Talep no veya başlık ara...',
                          style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 18),
            ),
          ],
        ),

        const SizedBox(height: 16),
        
        const LinearFilterTabs(
          labels: ['Hepsi', 'Acil', 'Kritik', 'Düşük'],
          selectedIndex: 0,
        ),

        const SizedBox(height: 16),

        // ── Ticket List ──────────────────────────────────────────
        const LinearSection(title: 'Aktif Talepler', count: 6),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTicketDetailPage(id: 'TS-1', title: 'Laptop screen flickering', statusLabel: 'Açık', statusColor: AppColors.statusBlue))),
                child: const LinearIssueRow(
                  id: 'TS-1',
                  title: 'Laptop screen flickering',
                  priority: AppColors.statusOrange,
                  statusColor: AppColors.statusBlue,
                  label: 'Açık',
                  labelColor: AppColors.statusBlue,
                  assignee: 'AM',
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTicketDetailPage(id: 'TS-2', title: 'Printer not responding', statusLabel: 'Devam', statusColor: AppColors.statusYellow))),
                child: const LinearIssueRow(
                  id: 'TS-2',
                  title: 'Printer not responding',
                  priority: AppColors.statusRed,
                  statusColor: AppColors.statusYellow,
                  label: 'Devam',
                  labelColor: AppColors.statusYellow,
                  assignee: 'AM',
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTicketDetailPage(id: 'TS-4', title: 'Wi-Fi connectivity issues', statusLabel: 'Açık', statusColor: AppColors.statusBlue))),
                child: const LinearIssueRow(
                  id: 'TS-4',
                  title: 'Wi-Fi connectivity issues in Room 302',
                  priority: AppColors.statusBlue,
                  statusColor: AppColors.statusBlue,
                  label: 'Açık',
                  labelColor: AppColors.statusBlue,
                  assignee: 'BW',
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTicketDetailPage(id: 'TS-5', title: 'VPN Access request', statusLabel: 'Açık', statusColor: AppColors.statusBlue))),
                child: const LinearIssueRow(
                  id: 'TS-5',
                  title: 'VPN Access request for new hire',
                  priority: AppColors.statusGray,
                  statusColor: AppColors.statusBlue,
                  label: 'Açık',
                  labelColor: AppColors.statusBlue,
                  assignee: 'AM',
                  showDivider: false,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        const LinearSection(title: 'Tamamlananlar'),
        LinearCard(
          padding: EdgeInsets.zero,
          child: const LinearIssueRow(
            id: 'TS-3',
            title: 'Software installation request',
            priority: AppColors.statusBlue,
            statusColor: AppColors.statusGreen,
            label: 'Çözüldü',
            labelColor: AppColors.statusGreen,
            assignee: 'BW',
            showDivider: false,
          ),
        ),
      ],
    );
  }
}

class _TicketMetric extends StatelessWidget {
  const _TicketMetric({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
