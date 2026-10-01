import 'package:flutter/material.dart';

import '../../../../core/design/app_design.dart';
import '../../data/site_contact.dart';
import 'landing_actions.dart';

/// Landing sayfasındaki fiyatlandırma bölümü.
///
/// Paket fiyatları demo amaçlıdır; canlı fiyatlandırma eklenene kadar
/// "bizimle iletişime geçin" akışına yönlendirir.
class PricingSection extends StatelessWidget {
  const PricingSection({super.key, required this.onScrollToFaq});

  final VoidCallback onScrollToFaq;

  static const List<_Plan> _plans = [
    _Plan(
      name: 'Başlangıç',
      tagline: 'Küçük ekipler için temel operasyon yönetimi',
      price: '₺2.490',
      period: '/ ay',
      features: [
        '5 teknisyen kullanıcısı',
        'İş emeri ve cihaz takibi',
        'Müşteri ve cihaz kayıtları',
        'Temel raporlama',
        'E-posta desteği',
      ],
      highlighted: false,
    ),
    _Plan(
      name: 'Kurumsal',
      tagline: 'Büyüyen servis ekipleri için tam operasyon',
      price: '₺5.990',
      period: '/ ay',
      features: [
        'Sınırsız teknisyen kullanıcısı',
        'Lineer AI ile akıllı iş atama',
        'Stok ve depo yönetimi',
        'Teknisyen performans analitiği',
        'Vardiya / mesai planlama',
        'Öncelikli destek',
      ],
      highlighted: true,
    ),
    _Plan(
      name: 'Kurumsal Plus',
      tagline: 'Çok şubeli operasyonlar için özel çözüm',
      price: 'Özel',
      period: '',
      features: [
        'Kurumsal Plus içindeki tüm özellikler',
        'Muhasebe ve faturalama entegrasyonu',
        'Müşteri portalı',
        'API ve özel entegrasyon',
        'Dedicated destek ekibi',
        'SLA garantili çalışma süresi',
      ],
      highlighted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isCompact = size.width < 700;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(vertical: isCompact ? 64 : 100, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PricingSectionHeader(),
              SizedBox(height: isCompact ? 36 : 56),
              if (isDesktop)
                // Row, dikeyde sınırsız yükseklikte konumlandığı için
                // CrossAxisAlignment.stretch doğrudan kullanılamaz;
                // IntrinsicHeight en yüksek kart yüksekliğini hesaplayıp
                // üç kartı eşit yükseklikte hizalar.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _plans.length; i++) ...[
                        if (i > 0) const SizedBox(width: 20),
                        Expanded(child: _PlanCard(plan: _plans[i])),
                      ],
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (var i = 0; i < _plans.length; i++) ...[
                      if (i > 0) const SizedBox(height: 20),
                      _PlanCard(plan: _plans[i]),
                    ],
                  ],
                ),
              const SizedBox(height: 28),
              Center(
                child: TextButton.icon(
                  onPressed: onScrollToFaq,
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label:
                      const Text('Fiyatlandırma hakkında sık sorulan sorular'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PricingSectionHeader extends StatelessWidget {
  const PricingSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FİYATLANDIRMA',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ekibinize uygun paketi seçin',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Tüm paketlerde mobil ve web erişimi, sınırsız müşteri/cihaz kaydı ve '
          'veri dışa aktarımı dahildir. Yıllık ödemede 2 ay ücretsiz.',
          style: TextStyle(
            fontSize: 17,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: const [
            _TrustNote(
                icon: Icons.verified_user_outlined, label: 'KVKK uyumlu'),
            _TrustNote(icon: Icons.devices_outlined, label: 'Web ve mobil'),
            _TrustNote(
                icon: Icons.cloud_upload_outlined,
                label: 'Ücretsiz veri aktarımı'),
            _TrustNote(
                icon: Icons.support_agent_rounded, label: 'Türkçe destek'),
          ],
        ),
      ],
    );
  }
}

class _TrustNote extends StatelessWidget {
  const _TrustNote({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Plan {
  const _Plan({
    required this.name,
    required this.tagline,
    required this.price,
    required this.period,
    required this.features,
    required this.highlighted,
  });

  final String name;
  final String tagline;
  final String price;
  final String period;
  final List<String> features;
  final bool highlighted;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final _Plan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: plan.highlighted ? AppColors.accentBg : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.highlighted ? AppColors.accent : AppColors.border,
          width: plan.highlighted ? 2 : 1,
        ),
        boxShadow: plan.highlighted
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (plan.highlighted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Text(
                'EN POPÜLER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          if (plan.highlighted) const SizedBox(height: 14),
          Text(
            plan.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            plan.tagline,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // Dar kartlarda "₺2.490 / ay" satırı taşabildiği için fiyat
          // metni karta göre küçültülür, dönem etiketi alt satıra düşebilir.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plan.price,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                if (plan.period.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 4),
                    child: Text(
                      plan.period,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 20),
          for (final feature in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 18, color: AppColors.statusGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: plan.highlighted
                ? FilledButton(
                    onPressed: () => LandingActions.demoRequest(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                    child: const Text(
                      'Demo Talep Et',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  )
                : OutlinedButton(
                    onPressed: () => LandingActions.talkToSales(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                    child: const Text(
                      'Satışla Görüş',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
