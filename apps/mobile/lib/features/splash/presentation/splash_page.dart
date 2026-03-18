import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../auth/presentation/role_selection_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return VercelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    right: 16,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    border: const Border(
                        bottom: BorderSide(color: Colors.white24, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        alignment: Alignment.center,
                        child: const LinearLogo(size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text('Lineer Destek',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          )),
                    ],
                  ),
                ),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero ─────────────────────────────────────────
                  LinearCard(
                    padding: const EdgeInsets.all(20),
                    color: AppColors.accentBg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearBadge(
                          label: 'Enterprise Service',
                          color: AppColors.accent,
                          bgColor: AppColors.bgElevated,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Servis operasyonlarını\ntek yüzeyde topla.',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Operasyon görünürlüğü, cihaz takibi ve ekip koordinasyonu.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const LinearStatPill(
                                value: '%98',
                                label: 'SLA',
                                color: AppColors.statusGreen),
                            const SizedBox(width: 8),
                            const LinearStatPill(
                                value: '126',
                                label: 'Aktif Op.',
                                color: AppColors.accent),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const LinearSection(title: 'Öne çıkanlar'),

                  LinearCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _FeatureRow(
                          icon: Icons.person_outline_rounded,
                          title: 'Müşteri görünümü',
                          subtitle: 'Cihaz ve operasyon takibi',
                        ),
                        _FeatureRow(
                          icon: Icons.engineering_outlined,
                          title: 'Teknisyen görünümü',
                          subtitle: 'Görev kuyruğu ve saha aksiyonları',
                        ),
                        _FeatureRow(
                          icon: Icons.dashboard_outlined,
                          title: 'Admin dashboard',
                          subtitle: 'KPI ve operasyon analizi',
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                              builder: (_) => const RoleSelectionPage()),
                        );
                      },
                      child: const Text('Demo deneyimi aç'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom:
                    BorderSide(color: AppColors.borderSubtle, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
