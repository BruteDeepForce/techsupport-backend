import 'package:flutter/material.dart';

import '../../admin/presentation/admin_home_page.dart';
import '../../customer/presentation/customer_home_page.dart';
import '../../technician/presentation/technician_home_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key, this.initialRole});

  final String? initialRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final normalizedRole = initialRole?.toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Demo merkezi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // Intro card removed per request — role cards start immediately
          _RoleCard(
            eyebrow: 'Admin Görünümü',
            icon: Icons.dashboard_customize_outlined,
            accent: const Color(0xFF7C3AED),
            subtitle: normalizedRole == 'admin'
                ? 'Seçili demo akışı: admin. Operasyon ritmi ve ekip görünürlüğüyle doğrudan başlıyorsun.'
                : 'Operasyon ritmi, ekip durumu ve günlük karar noktaları üst düzey görünürlükle sunulur.',
            bullets: const ['KPI özetleri', 'Operasyon akışı', 'Ekip yükü'],
            cta: 'Admin görünümünü aç',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AdminHomePage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _RoleCard(
            eyebrow: 'Müşteri Görünümü',
            icon: Icons.person_outline_rounded,
            accent: const Color(0xFF0F766E),
            subtitle: normalizedRole == 'customer'
                ? 'Seçili demo akışı: customer. Ticket ve cihaz görünümüyle müşteri deneyimi öne çıkarılıyor.'
                : 'Operasyonların durumu, cihaz süreci ve teknisyen bilgisi sakin ve anlaşılır bir dille gösterilir.',
            bullets: const [
              'Operasyon özeti',
              'Cihaz bilgisi',
              'Teslim görünürlüğü'
            ],
            cta: 'Müşteri görünümünü aç',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const CustomerHomePage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _RoleCard(
            eyebrow: 'Teknisyen Görünümü',
            icon: Icons.engineering_outlined,
            accent: colorScheme.primary,
            subtitle: normalizedRole == 'technician'
                ? 'Seçili demo akışı: technician. Görev kuyruğu ve saha çalışma görünümü öne alındı.'
                : 'Atanmış operasyon, cihaz özeti, hazırlık notu ve saha aksiyonları tek yerde toplanır.',
            bullets: const [
              'Görev listesi',
              'Hazırlık görünümü',
              'Saha aksiyonları'
            ],
            cta: 'Teknisyen görünümünü aç',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const TechnicianHomePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.eyebrow,
    required this.icon,
    required this.accent,
    required this.subtitle,
    required this.bullets,
    required this.cta,
    required this.onTap,
  });

  final String eyebrow;
  final IconData icon;
  final Color accent;
  final String subtitle;
  final List<String> bullets;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // title removed; eyebrow provides the header text
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(subtitle, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    bullets.map((item) => Chip(label: Text(item))).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(cta),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
