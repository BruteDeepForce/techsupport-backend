import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import 'admin_home_page.dart';
import 'admin_tickets_page.dart';
import 'admin_devices_page.dart';
import 'admin_team_page.dart';
import 'inventory_management_page.dart';

class AdminWorkOrdersPage extends StatelessWidget {
  const AdminWorkOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearPageShell(
      title: 'İş Emirleri',
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
          LinearTabItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Talepler',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          const LinearTabItem(
            icon: Icons.assignment_rounded, 
            label: 'İş Emri',
            active: true,
          ),
          LinearTabItem(
            icon: Icons.devices_other_outlined, 
            label: 'Cihazlar',
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
        // ── Action Banner ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hızlı İş Emri', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Bekleyen taleplerden hemen bir iş emri oluşturun.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.accent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
                ),
                child: const Text('Oluştur', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Status Filter ────────────────────────────────────────
        const LinearFilterTabs(
          labels: ['Aktif', 'Bekleyen', 'Biten', 'İptal'],
          selectedIndex: 0,
        ),

        const SizedBox(height: 16),

        // ── Work Order Listing ─────────────────────────────────────
        const LinearSection(title: 'Aktif İş Emirleri', count: 3),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _WorkOrderRow(
                id: 'WO-102',
                title: 'MacBook Pro Screen Repair',
                tech: 'Ahmet Mert',
                status: 'Aktif',
                statusColor: AppColors.statusGreen,
              ),
              _WorkOrderRow(
                id: 'WO-103',
                title: 'Network Switch Config',
                tech: 'Buse Yılmaz',
                status: 'Parça Bekleniyor',
                statusColor: AppColors.statusOrange,
              ),
              _WorkOrderRow(
                id: 'WO-104',
                title: 'Printer Toner Replacement',
                tech: 'Can Erkan',
                status: 'Bitirilemedi',
                statusColor: AppColors.statusRed,
                showDivider: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const LinearSection(title: 'Tamamlananlar'),
        LinearCard(
          padding: EdgeInsets.zero,
          child: const _WorkOrderRow(
            id: 'WO-101',
            title: 'Keyboard cleaning for Dell XPS',
            tech: 'Ahmet Mert',
            status: 'Bitti',
            statusColor: AppColors.statusBlue,
            showDivider: false,
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _WorkOrderRow extends StatelessWidget {
  const _WorkOrderRow({required this.id, required this.title, required this.tech, required this.status, required this.statusColor, this.showDivider = true});
  final String id;
  final String title;
  final String tech;
  final String status;
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
            child: Icon(Icons.build_circle_outlined, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(id, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    LinearBadge(label: status, color: statusColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Teknisyen: $tech', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.border, size: 20),
        ],
      ),
    );
  }
}
