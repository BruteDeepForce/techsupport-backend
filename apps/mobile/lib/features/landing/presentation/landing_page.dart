import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:techsupport_mobile/core/design/app_design.dart';
import 'package:techsupport_mobile/features/auth/presentation/login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  final _heroKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _howKey = GlobalKey();
  final _contactKey = GlobalKey();

  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _isScrolled ? 12 : 0,
              sigmaY: _isScrolled ? 12 : 0,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _isScrolled 
                    ? AppColors.bgSurface.withValues(alpha: 0.8) 
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: _isScrolled ? AppColors.border : Colors.transparent,
                    width: 0.5,
                  ),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        const LinearLogo(size: 36),
                        const SizedBox(width: 12),
                        Text(
                          'Lineer Destek',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (isDesktop) ...[
                          _NavLink(
                            label: 'Özellikler',
                            onTap: () => _scrollToKey(_featuresKey),
                          ),
                          _NavLink(
                            label: 'Nasıl Çalışır?',
                            onTap: () => _scrollToKey(_howKey),
                          ),
                          _NavLink(
                            label: 'İletişim',
                            onTap: () => _scrollToKey(_contactKey),
                          ),
                          const SizedBox(width: 24),
                        ],
                        _PremiumButton(
                          onPressed: _navigateToLogin,
                          label: 'Giriş Yap',
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // ── Hero Section ──────────────────────────────────────────────
            Container(
              key: _heroKey,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 160, bottom: 80),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.05),
                    AppColors.bg,
                  ],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(child: _HeroContent(onLogin: _navigateToLogin)),
                              const SizedBox(width: 80),
                              Expanded(child: _HeroImage()),
                            ],
                          )
                        : Column(
                            children: [
                              _HeroContent(onLogin: _navigateToLogin),
                              const SizedBox(height: 60),
                              _HeroImage(),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            // ── Features Section ──────────────────────────────────────────
            Container(
              key: _featuresKey,
              width: double.infinity,
              color: AppColors.bgSurface,
              padding: const EdgeInsets.symmetric(vertical: 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const _SectionHeader(
                          tag: 'ÖZELLİKLER',
                          title: 'Her Adımda Yanınızdayız',
                          subtitle: 'Teknik servis süreçlerinizi modernize eden güçlü araçlar.',
                        ),
                        const SizedBox(height: 80),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isDesktop ? 4 : (size.width > 700 ? 2 : 1),
                          mainAxisSpacing: 32,
                          crossAxisSpacing: 32,
                          childAspectRatio: 0.8,
                          children: const [
                            _FeatureCard(
                              icon: Icons.auto_awesome_outlined,
                              title: 'Yapay Zeka Destekli',
                              description: 'Arıza analizi ve otomatik yönlendirme ile süreçlerinizi optimize edin.',
                            ),
                            _FeatureCard(
                              icon: Icons.bolt_outlined,
                              title: 'Anlık Takip',
                              description: 'Tüm servis taleplerini harita üzerinden canlı izleyin ve yönetin.',
                            ),
                            _FeatureCard(
                              icon: Icons.inventory_2_outlined,
                              title: 'Stok Yönetimi',
                              description: 'Parça stoklarınızı ve teknisyen envanterlerini anlık güncelleyin.',
                            ),
                            _FeatureCard(
                              icon: Icons.bar_chart_outlined,
                              title: 'Detaylı Raporlama',
                              description: 'KPI ve performans raporları ile işletmenizin verimliliğini artırın.',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── How It Works Section ──────────────────────────────────────────
            Container(
              key: _howKey,
              width: double.infinity,
              color: AppColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const _SectionHeader(
                          tag: 'SÜREÇ',
                          title: 'Dijitalleşen İş Akışı',
                          subtitle: 'Kağıt kalem devrini kapatıp, veriye dayalı yönetime geçin.',
                        ),
                        const SizedBox(height: 80),
                        _WorkflowGraphic(isDesktop: isDesktop),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── CTA Section ─────────────────────────────────────────────
            Container(
              key: _contactKey,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LinearCard(
                      padding: const EdgeInsets.all(60),
                      color: AppColors.accent,
                      child: Column(
                        children: [
                          const Text(
                            'İşletmenizi bir üst seviyeye taşımaya hazır mısınız?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Hemen ücretsiz demo talebinde bulunun veya sistemimizi test edin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 48),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _PremiumButton(
                                onPressed: () {},
                                label: 'Hemen Başla',
                                isPrimary: false, // White button on accent background
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                  ),
                                ),
                                child: const Text('Satışla Konuş', 
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────
            _Footer(width: size.width),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final VoidCallback onLogin;
  const _HeroContent({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: const Text(
            '🚀 Yeni Nesil Teknik Servis Yönetimi',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Teknik Servislerinizi\nLineer Hızda Yönetin',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -2,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Müşteri taleplerinden saha operasyonlarına, yapay zeka destekli planlamadan dijital imzaya kadar her şeyi tek bir platformda toplayın.',
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 48),
        Row(
          children: [
            _PremiumButton(
              onPressed: onLogin,
              label: 'Hemen Giriş Yap',
            ),
            const SizedBox(width: 20),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_outline, size: 32),
              label: const Text('Ürünü İzle', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Image.asset(
        'assets/mockups.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.tag,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          tag,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowGraphic extends StatelessWidget {
  final bool isDesktop;
  const _WorkflowGraphic({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) {
      return Column(
        children: [
          _WorkflowStep(num: '01', title: 'Talep Alma', desc: 'Web/Mobil üzerinden gelen servis talepleri.'),
          _WorkflowStep(num: '02', title: 'Akıllı Atama', desc: 'Yapay zeka ile en uygun teknisyene yönlendirme.'),
          _WorkflowStep(num: '03', title: 'Saha Operasyonu', desc: 'Mobil uygulama ile dijital süreç takibi.'),
          _WorkflowStep(num: '04', title: 'Raporlama', desc: 'Müşteriye otomatik rapor gönderimi.'),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _WorkflowStep(num: '01', title: 'Talep Alma', desc: 'Web/Mobil üzerinden\ngelen servis talepleri.'),
        _Arrow(),
        _WorkflowStep(num: '02', title: 'Akıllı Atama', desc: 'Yapay zeka ile\nen uygun teknisyene.'),
        _Arrow(),
        _WorkflowStep(num: '03', title: 'Saha Operasyonu', desc: 'Mobil uygulama ile\ndijital süreç takibi.'),
        _Arrow(),
        _WorkflowStep(num: '04', title: 'Raporlama', desc: 'Müşteriye otomatik\nrapor gönderimi.'),
      ],
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final String num;
  final String title;
  final String desc;

  const _WorkflowStep({required this.num, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          Text(
            num,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppColors.accent.withValues(alpha: 0.1),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Icon(Icons.arrow_forward_rounded, color: AppColors.border, size: 24),
    );
  }
}

class _Footer extends StatelessWidget {
  final double width;
  const _Footer({required this.width});

  @override
  Widget build(BuildContext context) {
    final isDesktop = width > 700;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: width * 0.1,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                   LinearLogo(size: 24),
                   SizedBox(width: 8),
                   Text('Lineer Destek', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text('© 2026 Lineer Destek. Tüm hakları saklıdır.', 
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          if (isDesktop)
            Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('Gizlilik')),
                TextButton(onPressed: () {}, child: const Text('Kullanım Şartları')),
                TextButton(onPressed: () {}, child: const Text('Destek')),
              ],
            ),
        ],
      ),
    );
  }
}
class _PremiumButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isPrimary;

  const _PremiumButton({
    required this.onPressed,
    required this.label,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.accent : Colors.white,
        foregroundColor: isPrimary ? Colors.white : AppColors.accent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: isPrimary ? BorderSide.none : const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}
