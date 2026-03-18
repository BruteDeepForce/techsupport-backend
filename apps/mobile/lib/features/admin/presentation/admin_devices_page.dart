import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import 'admin_home_page.dart';
import 'admin_tickets_page.dart';
import 'admin_team_page.dart';
import 'admin_work_orders_page.dart';
import 'inventory_management_page.dart';

class AdminDevicesPage extends StatelessWidget {
  const AdminDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearPageShell(
      title: 'Cihazlar',
      subtitle: 'Admin Portal',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Yeni Cihaz', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
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
          const LinearTabItem(
            icon: Icons.devices_other_outlined, 
            label: 'Cihaz',
            active: true,
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
                      child: Text('Seri no veya model ara...',
                          style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textSecondary, size: 18),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        const LinearFilterTabs(
          labels: ['Tümü', 'Masaüstü', 'Dizüstü', 'Yazıcı'],
          selectedIndex: 0,
        ),

        const SizedBox(height: 16),

        // ── Category List ──────────────────────────────────────────
        const LinearSection(title: 'Demirbaş Durumu'),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _DeviceRow(title: 'MacBook Pro M1 (14")', id: 'SN: ABC-12345', statusLabel: 'Aktif', statusColor: AppColors.statusGreen),
              _DeviceRow(title: 'MacBook Air M2 (13")', id: 'SN: GHI-67890', statusLabel: 'Aktif', statusColor: AppColors.statusGreen),
              _DeviceRow(title: 'HP LaserJet Pro M404', id: 'SN: DEF-24680', statusLabel: 'Bakımda', statusColor: AppColors.statusYellow),
              _DeviceRow(title: 'Dell UltraSharp 27"', id: 'SN: XYZ-13579', statusLabel: 'Aktif', statusColor: AppColors.statusGreen),
              _DeviceRow(title: 'Cisco Catalyst Switch', id: 'SN: JKL-11111', statusLabel: 'Arızalı', statusColor: AppColors.statusRed, showDivider: false),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        const LinearSection(title: 'Hızlı İşlemler'),
        Row(
          children: [
            _QuickAction(icon: Icons.assignment_returned_outlined, label: 'Cihaz İade', color: AppColors.statusBlue),
            const SizedBox(width: 12),
            _QuickAction(icon: Icons.assignment_late_outlined, label: 'Arıza Kaydı', color: AppColors.statusOrange),
          ],
        ),
      ],
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.title, required this.id, required this.statusLabel, required this.statusColor, this.showDivider = true});
  final String title;
  final String id;
  final String statusLabel;
  final Color statusColor;
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(AppRadius.xs)),
            child: const Icon(Icons.laptop_mac_rounded, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(id, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          LinearBadge(label: statusLabel, color: statusColor),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LinearCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
