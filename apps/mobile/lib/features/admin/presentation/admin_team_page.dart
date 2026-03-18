import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import 'admin_home_page.dart';
import 'admin_tickets_page.dart';
import 'admin_devices_page.dart';
import 'admin_work_orders_page.dart';
import 'inventory_management_page.dart';

class AdminTeamPage extends StatelessWidget {
  const AdminTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearPageShell(
      title: 'Ekip',
      subtitle: 'Admin Portal',
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
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
          const LinearTabItem(
            icon: Icons.group_outlined, 
            label: 'Ekip',
            active: true,
          ),
        ],
      ),
      children: [
        // ── Active Technicians ────────────────────────────────────
        const LinearSection(title: 'Aktif Teknisyenler', count: 4),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _TeamMemberRow(name: 'Ahmet Mert', role: 'Kıdemli Teknisyen', tasks: 3, status: 'Müsait Değil', statusColor: AppColors.statusOrange),
              _TeamMemberRow(name: 'Buse Yılmaz', role: 'Donanım Uzmanı', tasks: 1, status: 'Aktif', statusColor: AppColors.statusGreen),
              _TeamMemberRow(name: 'Can Erkan', role: 'Ağ Sistemleri', tasks: 0, status: 'Aktif', statusColor: AppColors.statusGreen),
              _TeamMemberRow(name: 'Deniz Ak', role: 'Stajyer Teknisyen', tasks: 2, status: 'Aktif', statusColor: AppColors.statusGreen, showDivider: false),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Performance Metrics ───────────────────────────────────
        const LinearSection(title: 'Haftalık Performans'),
        Row(
          children: [
            _StatCard(label: 'Çözülen', value: '24', icon: Icons.check_circle_outline_rounded, color: AppColors.statusGreen),
            const SizedBox(width: 12),
            _StatCard(label: 'Geciken', value: '2', icon: Icons.access_time_rounded, color: AppColors.statusRed),
          ],
        ),
        
        const SizedBox(height: 16),

        // ── Working Hours Summary ─────────────────────────────────
        LinearCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ekip Doluluk Oranı', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.7,
                        minHeight: 8,
                        backgroundColor: AppColors.bg,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('70%', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamMemberRow extends StatelessWidget {
  const _TeamMemberRow({required this.name, required this.role, required this.tasks, required this.status, required this.statusColor, this.showDivider = true});
  final String name;
  final String role;
  final int tasks;
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
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(name.substring(0, 1), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(role, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$tasks Görev', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LinearCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
