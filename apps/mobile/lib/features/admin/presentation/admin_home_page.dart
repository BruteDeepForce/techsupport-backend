import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      bottomNavBar: AppBottomNavBar(
        items: [
          AppBottomNavItemData(
              icon: Icons.grid_view_rounded,
              label: 'Genel Bakış',
              active: true),
          AppBottomNavItemData(
              icon: Icons.confirmation_number_outlined, label: 'Tüm Talepler'),
          AppBottomNavItemData(
              icon: Icons.devices_other_outlined, label: 'Cihazlar'),
          AppBottomNavItemData(
              icon: Icons.build_outlined, label: 'Teknisyenler'),
          AppBottomNavItemData(icon: Icons.logout_rounded, label: 'Çıkış Yap'),
        ],
      ),
      children: [
        AppBrandHeader(
          title: 'Platform Overview',
          subtitle: 'Admin Portal > Platform Overview',
          trailingText: 'AU',
        ),
        const SizedBox(height: 18),

        // Top KPI grid (more visual, "tech" feel)
        Row(
          children: const [
            Expanded(
              child: AppTechStatCard(
                tint: AppColors.infoSoft,
                accent: AppColors.info,
                icon: Icons.show_chart_rounded,
                value: '6',
                label: 'Toplam Talepler',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AppTechStatCard(
                tint: AppColors.warningSoft,
                accent: AppColors.warning,
                icon: Icons.warning_amber_rounded,
                value: '3',
                label: 'Açık Talepler',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: AppTechStatCard(
                tint: Color(0xFFEEF2FF),
                accent: Color(0xFF6366F1),
                icon: Icons.timelapse_rounded,
                value: '2',
                label: 'Devam Ediyor',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AppTechStatCard(
                tint: AppColors.successSoft,
                accent: AppColors.success,
                icon: Icons.check_circle_outline_rounded,
                value: '1',
                label: 'Çözüldü',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
                child: _MiniMetric(
                    title: 'Total Devices',
                    value: '4',
                    accent: Color(0xFF64748B),
                    icon: Icons.devices_other_outlined)),
            SizedBox(width: 12),
            Expanded(
                child: _MiniMetric(
                    title: 'Tamir/Bakım Devam Ediyor',
                    value: '1',
                    accent: AppColors.warning,
                    icon: Icons.build_circle_outlined)),
            SizedBox(width: 12),
            Expanded(
                child: _MiniMetric(
                    title: 'Toplam Personel',
                    value: '4',
                    accent: AppColors.purple,
                    icon: Icons.group_outlined)),
          ],
        ),
        const SizedBox(height: 18),
        _RecentTicketsSection(),
        const SizedBox(height: 18),
        _DeviceStatusSection(),
        const SizedBox(height: 18),
        _SystemHealthSection(),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric(
      {required this.title,
      required this.value,
      required this.accent,
      required this.icon});

  final String title;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      minHeight: 124,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _RecentTicketsSection extends StatelessWidget {
  const _RecentTicketsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: AppSectionHeader(
              title: 'Son Talepler',
              trailing: Text('Tümünü Gör',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.brand)),
            ),
          ),
          const Divider(height: 1),
          const _TicketTableHeader(),
          const Divider(height: 1),
          const _TicketRow(
              id: '#0001',
              subject: 'Laptop screen flickering randomly',
              customer: 'Alice Morgan',
              status: 'Open',
              statusBg: AppColors.infoSoft,
              statusFg: AppColors.brand),
          const Divider(height: 1),
          const _TicketRow(
              id: '#0002',
              subject: 'Printer not responding to print jobs',
              customer: 'Alice Morgan',
              status: 'Devam Ediyor',
              statusBg: AppColors.warningSoft,
              statusFg: Color(0xFFC26A00)),
          const Divider(height: 1),
          const _TicketRow(
              id: '#0003',
              subject: 'Software installation request',
              customer: 'Bob Williams',
              status: 'Çözüldü',
              statusBg: AppColors.successSoft,
              statusFg: Color(0xFF0D9A5C)),
        ],
      ),
    );
  }
}

class _TicketTableHeader extends StatelessWidget {
  const _TicketTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text('Ticket #')),
          Expanded(child: Text('Subject')),
          SizedBox(width: 120, child: Text('Status')),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.id,
    required this.subject,
    required this.customer,
    required this.status,
    required this.statusBg,
    required this.statusFg,
  });

  final String id;
  final String subject;
  final String customer;
  final String status;
  final Color statusBg;
  final Color statusFg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                  width: 70, child: Text(id, style: theme.textTheme.bodyLarge)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(customer, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              SizedBox(
                width: 120,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: StatusChip(
                      label: status,
                      background: statusBg,
                      foreground: statusFg),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceStatusSection extends StatelessWidget {
  const _DeviceStatusSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      minHeight: 192,
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cihaz Durumu', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          const _StatusBarRow(
              label: 'Active',
              count: '2',
              color: AppColors.success,
              progress: 0.50),
          const SizedBox(height: 18),
          const _StatusBarRow(
              label: 'Tamir/Bakım Devam Ediyor',
              count: '1',
              color: AppColors.warning,
              progress: 0.25),
          const SizedBox(height: 18),
          const _StatusBarRow(
              label: 'Inactive',
              count: '1',
              color: Color(0xFF94A3B8),
              progress: 0.25),
        ],
      ),
    );
  }
}

class _StatusBarRow extends StatelessWidget {
  const _StatusBarRow(
      {required this.label,
      required this.count,
      required this.color,
      required this.progress});

  final String label;
  final String count;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w500))),
            Text(count, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFE6EBF3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _SystemHealthSection extends StatelessWidget {
  const _SystemHealthSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      minHeight: 164,
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sistem Sağlığı', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: _HealthBox(
                  title: 'Çözüm Oranı',
                  value: '16.7%',
                  background: Color(0xFFF7F9FC),
                  foreground: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _HealthBox(
                  title: 'Açık Kritik',
                  value: '0',
                  background: Color(0xFFFFF2F2),
                  foreground: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthBox extends StatelessWidget {
  const _HealthBox({
    required this.title,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String title;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.bodyLarge?.copyWith(color: foreground)),
          const SizedBox(height: 10),
          Text(value,
              style:
                  theme.textTheme.headlineSmall?.copyWith(color: foreground)),
        ],
      ),
    );
  }
}
