import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      bottomNavBar: const AppBottomNavBar(
        items: [
          AppBottomNavItemData(
            icon: Icons.grid_view_rounded,
            label: 'Ana Sayfa',
            active: true,
          ),
          AppBottomNavItemData(
            icon: Icons.confirmation_number_outlined,
            label: 'Taleplerim',
          ),
          AppBottomNavItemData(
            icon: Icons.devices_other_outlined,
            label: 'Cihazlarım',
          ),
          AppBottomNavItemData(
            icon: Icons.logout_rounded,
            label: 'Çıkış Yap',
          ),
        ],
      ),
      children: [
        const AppBrandHeader(
          title: 'Panel',
          subtitle: 'Müşteri Portalı > Panel',
          trailingText: 'AM',
        ),
        const SizedBox(height: 18),

        // KPI grid (denser + more “tech” feel)
        Row(
          children: [
            Expanded(
              child: AppTechStatCard(
                label: 'Açık Talepler',
                value: '3',
                icon: Icons.confirmation_number_outlined,
                tint: AppColors.infoSoft,
                accent: AppColors.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTechStatCard(
                label: 'Devam Eden',
                value: '1',
                icon: Icons.sync_rounded,
                tint: AppColors.warningSoft,
                accent: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTechStatCard(
                label: 'Çözülen',
                value: '12',
                icon: Icons.verified_rounded,
                tint: AppColors.successSoft,
                accent: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTechStatCard(
                label: 'Cihazlarım',
                value: '2',
                icon: Icons.devices_other_outlined,
                tint: AppColors.headerTint,
                accent: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        AppSurfaceCard(
          minHeight: 96,
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Yeni Talep',
                  subtitle: 'Hızlı destek iste',
                  tint: AppColors.infoSoft,
                  accent: AppColors.brand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.search_rounded,
                  title: 'Takip Et',
                  subtitle: 'Talep durumunu gör',
                  tint: AppColors.headerTint,
                  accent: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),
        const AppSectionHeader(title: 'Son Talepler'),
        const SizedBox(height: 12),
        CustomerTicketCard(
          title: 'Laptop screen flickering randomly',
          subtitle:
              'The screen of Office Laptop #1 flickers every few minutes...',
          device: 'Office Laptop #1',
          severityLabel: 'HIGH',
          severityBg: const Color(0xFFFDE7D6),
          severityFg: const Color(0xFFF97316),
          stateLabel: 'Açık',
          stateBg: AppColors.infoSoft,
          stateFg: AppColors.brand,
          accent: const Color(0xFFF97316),
        ),
        const SizedBox(height: 12),
        CustomerTicketCard(
          title: 'Printer not responding to print jobs',
          subtitle:
              'The reception printer stopped working after a print job...',
          device: 'Reception Printer',
          severityLabel: 'CRITICAL',
          severityBg: AppColors.criticalSoft,
          severityFg: AppColors.critical,
          stateLabel: 'Devam Ediyor',
          stateBg: AppColors.warningSoft,
          stateFg: const Color(0xFFC26A00),
          accent: AppColors.critical,
        ),
        const SizedBox(height: 12),
        CustomerTicketCard(
          title: 'Software installation request',
          subtitle:
              'Need Adobe Acrobat Pro installed on Office Laptop for the finance team...',
          device: 'Office Laptop #1',
          severityLabel: 'MEDIUM',
          severityBg: AppColors.infoSoft,
          severityFg: AppColors.brand,
          stateLabel: 'Çözüldü',
          stateBg: AppColors.successSoft,
          stateFg: const Color(0xFF0D9A5C),
          accent: AppColors.info,
        ),
        const SizedBox(height: 22),
        const AppSectionHeader(title: 'Cihazlarım'),
        const SizedBox(height: 12),
        DeviceInventoryCard(
          title: 'Office Laptop #1',
          subtitle: 'Dell XPS 15',
          serialNumber: 'DXP15-001-2024',
          owner: 'Alice Morgan',
          statusLabel: 'Aktif',
          statusBg: AppColors.successSoft,
          statusFg: const Color(0xFF0D9A5C),
          iconTint: AppColors.success,
        ),
        const SizedBox(height: 12),
        DeviceInventoryCard(
          title: 'Reception Printer',
          subtitle: 'HP LaserJet Pro',
          serialNumber: 'HPL-REC-2023',
          owner: 'Alice Morgan',
          statusLabel: 'Tamir/Bakım Devam Ediyor',
          statusBg: AppColors.warningSoft,
          statusFg: const Color(0xFFE56D00),
          iconTint: AppColors.warning,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class CustomerTicketCard extends StatelessWidget {
  const CustomerTicketCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.device,
    required this.severityLabel,
    required this.severityBg,
    required this.severityFg,
    required this.stateLabel,
    required this.stateBg,
    required this.stateFg,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String device;
  final String severityLabel;
  final Color severityBg;
  final Color severityFg;
  final String stateLabel;
  final Color stateBg;
  final Color stateFg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      minHeight: 182,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            width: 5,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xxl),
                bottomLeft: Radius.circular(AppRadius.xxl),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(title,
                              style: theme.textTheme.headlineSmall)),
                      StatusChip(
                          label: severityLabel,
                          background: severityBg,
                          foreground: severityFg),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text('yaklaşık 1 saat önce',
                              style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _MetaChip(
                          label: device, icon: Icons.devices_other_outlined),
                      const Spacer(),
                      StatusChip(
                          label: stateLabel,
                          background: stateBg,
                          foreground: stateFg),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceInventoryCard extends StatelessWidget {
  const DeviceInventoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.serialNumber,
    required this.owner,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
    required this.iconTint,
  });

  final String title;
  final String subtitle;
  final String serialNumber;
  final String owner;
  final String statusLabel;
  final Color statusBg;
  final Color statusFg;
  final Color iconTint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      minHeight: 176,
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconTint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.devices_other_outlined,
                    color: iconTint, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(subtitle, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text('SN :  $serialNumber',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  owner,
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              StatusChip(
                  label: statusLabel,
                  background: statusBg,
                  foreground: statusFg),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child:
                Text('Updated Mar 13, 2026', style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
