import 'package:flutter/material.dart';

import '../../auth/presentation/role_selection_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EEFB),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.hub_outlined,
                              color: Color(0xFF3056D3)),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TechSupport',
                                style: theme.textTheme.titleLarge),
                            Text('Service Operations Suite',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E3A8A),
                            Color(0xFF3056D3),
                            Color(0xFF6C8DFF)
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Field service • Customer care • Technician ops',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Kurumsal servis operasyonlarını tek mobil yüzeyde topla.',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Operasyon görünürlüğü, cihaz süreci takibi ve ekip koordinasyonu için daha net, daha güven veren bir mobil deneyim.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.90),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _MetricPill(
                                  title: 'SLA görünürlüğü', value: '%98'),
                              _MetricPill(
                                  title: 'Aktif operasyon', value: '126'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Öne çıkan deneyimler',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const _FeatureTile(
                      title: 'Müşteri görünümü',
                      subtitle:
                          'Cihaz, operasyon ve atanan teknisyen bilgisini sade biçimde takip eder.',
                    ),
                    const SizedBox(height: 12),
                    const _FeatureTile(
                      title: 'Teknisyen görünümü',
                      subtitle:
                          'Göreve çıkmadan önce cihaz özeti, hazırlık notu ve lokasyonu görür.',
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                              builder: (_) => const RoleSelectionPage()),
                        );
                      },
                      child: const Text('Demo deneyimi aç'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          const SizedBox(height: 2),
          Text(title,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.88))),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EDF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF3056D3)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
