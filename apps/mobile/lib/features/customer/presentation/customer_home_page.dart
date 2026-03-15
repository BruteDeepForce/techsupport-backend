import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      bottomNavBar: AppBottomNavBar(
        items: [
          AppBottomNavItemData(
              icon: Icons.grid_view_rounded, label: 'Ana Sayfa', active: true),
          AppBottomNavItemData(
              icon: Icons.confirmation_number_outlined, label: 'Taleplerim'),
          AppBottomNavItemData(
              icon: Icons.devices_other_outlined, label: 'Cihazlarım'),
          AppBottomNavItemData(icon: Icons.logout_rounded, label: 'Çıkış Yap'),
        ],
      ),
      children: [
        AppBrandHeader(
          title: 'Panel',
          subtitle: 'Yönetici Portalı > Panel',
          trailingText: 'AM',
        ),
        SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: 'Açık Talepler',
                value: '3',
                icon: Icons.confirmation_number_outlined,
                leadingColor: AppColors.brand,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: MetricTile(
                title: 'Cihazlarım',
                value: '2',
                icon: Icons.devices_other_outlined,
                leadingColor: Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
        SizedBox(height: 26),
        AppSectionHeader(title: 'Son Talepler'),
        SizedBox(height: 12),
        CustomerTicketCard(
          title: 'Laptop screen flickering randomly',
          subtitle:
              'The screen of Office Laptop #1 flickers every few minutes...',
          device: 'Office Laptop #1',
          severityLabel: 'HIGH',
          severityBg: Color(0xFFFDE7D6),
          severityFg: Color(0xFFF97316),
          stateLabel: 'Açık',
          stateBg: AppColors.infoSoft,
          stateFg: AppColors.brand,
          accent: Color(0xFFF97316),
        ),
        SizedBox(height: 12),
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
          stateFg: Color(0xFFC26A00),
          accent: AppColors.critical,
        ),
        SizedBox(height: 12),
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
          stateFg: Color(0xFF0D9A5C),
          accent: AppColors.info,
        ),
        SizedBox(height: 22),
        AppSectionHeader(title: 'Cihazlarım'),
        SizedBox(height: 12),
        DeviceInventoryCard(
          title: 'Office Laptop #1',
          subtitle: 'Dell XPS 15',
          serialNumber: 'DXP15-001-2024',
          owner: 'Alice Morgan',
          statusLabel: 'Aktif',
          statusBg: AppColors.successSoft,
          statusFg: Color(0xFF0D9A5C),
          iconTint: AppColors.success,
        ),
        SizedBox(height: 12),
        DeviceInventoryCard(
          title: 'Reception Printer',
          subtitle: 'HP LaserJet Pro',
          serialNumber: 'HPL-REC-2023',
          owner: 'Alice Morgan',
          statusLabel: 'Tamir/Bakım Devam Ediyor',
          statusBg: AppColors.warningSoft,
          statusFg: Color(0xFFE56D00),
          iconTint: AppColors.warning,
        ),
      ],
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
