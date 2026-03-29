import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../admin/presentation/admin_home_page.dart';
import '../../customer/presentation/customer_home_page.dart';
import '../../technician/presentation/technician_home_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key, this.initialRole});

  final String? initialRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return VercelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                bottom: 10,
              ),
              decoration: const BoxDecoration(
                color: AppColors.bgSurface,
                border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Demo Merkezi', style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  )),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const LinearSection(title: 'Rol seçin', count: 3),
                _RoleTile(
                  icon: Icons.dashboard_customize_outlined,
                  color: AppColors.statusPurple,
                  title: 'Admin',
                  subtitle:
                      'KPI özetleri, operasyon akışı, ekip yükü',
                  metric: '6 talep',
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const AdminHomePage())),
                ),
                const SizedBox(height: 8),
                _RoleTile(
                  icon: Icons.person_outline_rounded,
                  color: AppColors.statusGreen,
                  title: 'Müşteri',
                  subtitle:
                      'Operasyon özeti, cihaz bilgisi, teslim görünürlüğü',
                  metric: '3 açık',
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const CustomerHomePage())),
                ),
                const SizedBox(height: 8),
                _RoleTile(
                  icon: Icons.engineering_outlined,
                  color: AppColors.statusOrange,
                  title: 'Teknisyen',
                  subtitle:
                      'Görev listesi, hazırlık görünümü, saha aksiyonları',
                  metric: '2 aktif',
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const TechnicianHomePage())),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.metric,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String metric;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: LinearCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(title,
                              style: theme.textTheme.titleMedium)),
                      LinearBadge(label: metric, color: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
