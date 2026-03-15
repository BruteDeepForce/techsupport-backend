import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';

class TechnicianHomePage extends StatelessWidget {
  const TechnicianHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      bottomNavBar: AppBottomNavBar(
        items: [
          AppBottomNavItemData(
              icon: Icons.assignment_outlined,
              label: 'Sıradaki İşler',
              active: true),
          AppBottomNavItemData(
              icon: Icons.inventory_2_outlined, label: 'Atanmamış İşler'),
          AppBottomNavItemData(
              icon: Icons.confirmation_number_outlined, label: 'Tüm Talepler'),
          AppBottomNavItemData(
              icon: Icons.devices_other_outlined, label: 'Cihazlar'),
          AppBottomNavItemData(icon: Icons.logout_rounded, label: 'Çıkış Yap'),
        ],
      ),
      children: [
        AppBrandHeader(
          title: 'Teknisyen Çalışma Alanı',
          subtitle: 'Teknisyen Portalı > Kuyruğum',
          trailingText: 'TJ',
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _QueueStat(
                    value: '2',
                    label: 'Aktif Görevler',
                    tint: AppColors.infoSoft,
                    accent: AppColors.brand,
                    icon: Icons.assignment_outlined)),
            SizedBox(width: 10),
            Expanded(
                child: _QueueStat(
                    value: '0',
                    label: 'Çözülen (Toplam)',
                    tint: AppColors.successSoft,
                    accent: AppColors.success,
                    icon: Icons.check_circle_outline_rounded)),
          ],
        ),
        SizedBox(height: 20),
        FilterSegment(
          labels: ['Sıradaki İşler', 'Atanmamış İşler'],
          selectedIndex: 0,
        ),
        SizedBox(height: 16),
        _TechnicianOperationCard(
          title: 'Printer not responding to print jobs',
          subtitle:
              'The reception printer stopped working after a large print batch...',
          customer: 'Alice Morgan',
          device: 'Reception Printer',
          statusLabel: 'CRITICAL',
          statusBg: AppColors.criticalSoft,
          statusFg: AppColors.critical,
          queueState: 'Devam Ediyor',
          accent: AppColors.critical,
        ),
        SizedBox(height: 12),
        _TechnicianOperationCard(
          title: 'Need to migrate data from old server',
          subtitle:
              'Old Dell server has important data that needs to be moved to the new machine...',
          customer: 'Bob Williams',
          device: 'Old Server',
          statusLabel: 'CRITICAL',
          statusBg: AppColors.criticalSoft,
          statusFg: AppColors.critical,
          queueState: 'Devam Ediyor',
          accent: AppColors.critical,
        ),
      ],
    );
  }
}

class _TechnicianOperationCard extends StatelessWidget {
  const _TechnicianOperationCard({
    required this.title,
    required this.subtitle,
    required this.customer,
    required this.device,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
    required this.queueState,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String customer;
  final String device;
  final String statusLabel;
  final Color statusBg;
  final Color statusFg;
  final String queueState;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      minHeight: 196,
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
                          label: statusLabel,
                          background: statusBg,
                          foreground: statusFg),
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
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Tag(text: device, icon: Icons.devices_other_outlined),
                      const SizedBox(width: 10),
                      _Tag(text: customer, icon: Icons.person_outline_rounded),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppShadows.card,
                    ),
                    child: Text(queueState,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500)),
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

class _QueueStat extends StatelessWidget {
  const _QueueStat({
    required this.value,
    required this.label,
    required this.tint,
    required this.accent,
    required this.icon,
  });

  final String value;
  final String label;
  final Color tint;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppTechStatCard(
      tint: tint,
      accent: accent,
      icon: icon,
      value: value,
      label: label,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
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
            Expanded(
                child: Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge)),
          ],
        ),
      ),
    );
  }
}
