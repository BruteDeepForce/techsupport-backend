import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:techsupport_mobile/core/design/app_design.dart';
import 'package:techsupport_mobile/features/auth/presentation/login_page.dart';
import 'package:techsupport_mobile/features/auth/presentation/register_page.dart';
import '../data/site_contact.dart';
import 'widgets/ai_chat_preview.dart';
import 'widgets/landing_actions.dart';
import 'widgets/legal_document_page.dart';
import 'widgets/pricing_section.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _OutlinedHeroButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _OutlinedHeroButton({
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DrawerLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howKey = GlobalKey();
  final GlobalKey _aiKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

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

  void _scrollToKey(GlobalKey? key) {
    if (key == null) return;
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

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void _demoRequest() => LandingActions.demoRequest(context);

  void _talkToSales() => LandingActions.talkToSales(context);

  void _openLegal(LegalDocument document) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentPage(document: document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isMobile = size.width < 800;
    final isTablet = size.width >= 800 && size.width <= 1100;

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      drawer: isDesktop
          ? null
          : Drawer(
              child: Container(
                color: AppColors.bg,
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const LinearLogo(size: 48),
                    const SizedBox(height: 40),
                    _DrawerLink(
                      label: 'Özellikler',
                      onTap: () {
                        Navigator.pop(context);
                        _scrollToKey(_featuresKey);
                      },
                    ),
                    _DrawerLink(
                      label: 'Nasıl Çalışır?',
                      onTap: () {
                        Navigator.pop(context);
                        _scrollToKey(_howKey);
                      },
                    ),
                    _DrawerLink(
                      label: 'Lineer AI',
                      onTap: () {
                        Navigator.pop(context);
                        _scrollToKey(_aiKey);
                      },
                    ),
                    _DrawerLink(
                      label: 'Fiyatlandırma',
                      onTap: () {
                        Navigator.pop(context);
                        _scrollToKey(_pricingKey);
                      },
                    ),
                    _DrawerLink(
                      label: 'İletişim',
                      onTap: () {
                        Navigator.pop(context);
                        _scrollToKey(_contactKey);
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: _PremiumButton(
                          onPressed: _navigateToRegister,
                          label: 'Kayıt Ol',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: _PremiumButton(
                          onPressed: _navigateToLogin,
                          label: 'Giriş Yap',
                          isPrimary: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                        if (!isDesktop) ...[
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu_rounded,
                                  color: AppColors.textPrimary),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const LinearLogo(size: 32),
                        const SizedBox(width: 8),
                        Text(
                          'Lineer Destek',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (isDesktop) ...[
                          // Dar masaüstü genişliklerde nav satırının taşmaması
                          // için esneme + kaydırma uygulanır.
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _NavLink(
                                    label: 'Özellikler',
                                    onTap: () => _scrollToKey(_featuresKey),
                                  ),
                                  _NavLink(
                                    label: 'Nasıl Çalışır?',
                                    onTap: () => _scrollToKey(_howKey),
                                  ),
                                  _NavLink(
                                    label: 'Yapay Zeka',
                                    onTap: () => _scrollToKey(_aiKey),
                                  ),
                                  _NavLink(
                                    label: 'Fiyatlandırma',
                                    onTap: () => _scrollToKey(_pricingKey),
                                  ),
                                  _NavLink(
                                    label: 'İletişim',
                                    onTap: () => _scrollToKey(_contactKey),
                                  ),
                                  const SizedBox(width: 24),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _PremiumButton(
                            onPressed: _navigateToRegister,
                            label: 'Kayıt Ol',
                            isPrimary: false,
                          ),
                          const SizedBox(width: 12),
                          _PremiumButton(
                            onPressed: _navigateToLogin,
                            label: 'Giriş Yap',
                            isPrimary: true,
                          ),
                        ],
                        if (!isDesktop)
                          IconButton(
                            onPressed: _navigateToLogin,
                            icon:
                                const Icon(Icons.login_rounded, color: AppColors.accent),
                            tooltip: 'Giriş Yap',
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
            _AnimatedSection(
              child: Container(
                key: _heroKey,
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: isDesktop ? 160 : 120, bottom: isDesktop ? 80 : 40),
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
                                Expanded(
                                    child: _HeroContent(
                                  onRegister: _navigateToRegister,
                                  onWatchProduct: _navigateToRegister,
                                )),
                                const SizedBox(width: 80),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.asset(
                                      'assets/mockups.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _HeroContent(
                                  onRegister: _navigateToRegister,
                                  onWatchProduct: _navigateToRegister,
                                ),
                                const SizedBox(height: 60),
                                _HeroImage(),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Stats Section ─────────────────────────────────────────────
            _AnimatedSection(child: _StatsSection()),

            // ── Features Section ──────────────────────────────────────────
            _AnimatedSection(
              child: Container(
                key: _featuresKey,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        const _SectionHeader(
                          tag: 'Özellikler',
                          title: 'İşinizi Kolaylaştıran Çözümler',
                          subtitle:
                              'Lineer Destek ile teknik servis süreçlerinizi uçtan uca dijitalleştirin.',
                        ),
                        const SizedBox(height: 60),
                        Column(
                          children: [
                            _FeatureRow(
                              title: 'Lineer AI Asistan',
                              description:
                                  'Operasyon, stok, muhasebe, müşteri ve insan kaynakları verilerinizi doğal dilde sorgulayın; tek ekrandan analiz edin.',
                              imagePath: 'assets/photos/7.png',
                              isReversed: false,
                              onDetailTap: _talkToSales,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Ticket ve İş Emri Yönetimi',
                              description:
                                  'Müşteri taleplerini kaydedin, teknisyene atayın ve saha sürecini tek akışta yönetin.',
                              imagePath: 'assets/photos/4.png',
                              isReversed: true,
                              onDetailTap: _talkToSales,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Stok Yönetimi',
                              description:
                                  'Araçlardaki ve ana depodaki yedek parçaları gerçek zamanlı kontrol edin.',
                              imagePath: 'assets/photos/8.png',
                              isReversed: false,
                              onDetailTap: _talkToSales,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Gelişmiş Raporlama',
                              description:
                                  'Servis performansını, maliyetleri ve müşteri memnuniyetini anlık izleyin.',
                              imagePath: 'assets/photos/5.png',
                              isReversed: true,
                              onDetailTap: _talkToSales,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Dijital Onay ve İmza',
                              description:
                                  'Servis formlarını sahada dijital imza ile anında onaylatın ve PDF yapın.',
                              imagePath: 'assets/photos/9.png',
                              isReversed: false,
                              onDetailTap: _talkToSales,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'İnsan Kaynakları',
                              description:
                                  'Çalışan, izin, avans ve performans kayıtlarını tek panelden yönetin.',
                              imagePath: 'assets/photos/4.png',
                              isReversed: true,
                              onDetailTap: _talkToSales,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Cihaz ve Garanti Takibi',
                              description:
                                  'Müşteri cihazlarını seri numarası, arıza geçmişi ve garanti süresiyle birlikte izleyin.',
                              imagePath: 'assets/photos/3.png',
                              isReversed: false,
                              onDetailTap: _talkToSales,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Muhasebe ve Faturalama',
                              description:
                                  'Alacak, borç, fatura ve tahsilat kayıtlarını cari hesap ekstreleriyle birlikte yönetin.',
                              imagePath: 'assets/photos/2.png',
                              isReversed: true,
                              onDetailTap: _talkToSales,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Saha Süreç Yönetimi',
                              description:
                                  'Servis formu, kullanılan parça ve dijital müşteri onayını operasyon kaydında toplayın.',
                              imagePath: 'assets/photos/10.png',
                              isReversed: false,
                              onDetailTap: _talkToSales,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── How It Works Section ──────────────────────────────────────
            _AnimatedSection(
              child: Container(
                key: _howKey,
                width: double.infinity,
                color: AppColors.bgSurface,
                padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        const _SectionHeader(
                          tag: 'Süreç',
                          title: 'Nasıl Çalışır?',
                          subtitle:
                              'Talepten rapora kadar süreci saniyeler içinde tamamlayın.',
                        ),
                        const SizedBox(height: 80),
                        _WorkflowGraphic(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Pricing Section ──────────────────────────────────────────
            _AnimatedSection(
              child: Container(
                key: _pricingKey,
                width: double.infinity,
                color: AppColors.bgSurface,
                child: PricingSection(onScrollToFaq: () => _scrollToKey(_faqKey)),
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 0),
                            child: isMobile
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _PremiumButton(
                                        onPressed: _demoRequest,
                                        label: 'Demo Talep Et',
                                        isPrimary: false,
                                      ),
                                      const SizedBox(height: 12),
                                      _OutlinedHeroButton(
                                        onPressed: _talkToSales,
                                        label: 'Bilgi Alınız',
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _PremiumButton(
                                        onPressed: _demoRequest,
                                        label: 'Demo Talep Et',
                                        isPrimary: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _OutlinedHeroButton(
                                        onPressed: _talkToSales,
                                        label: 'Bilgi Alınız',
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            _AnimatedSection(
              child: _AIFeaturesSection(key: _aiKey, scrollController: _scrollController),
            ),

            // ── FAQ Section ───────────────────────────────────────────────
            _AnimatedSection(child: _FAQSection(sectionKey: _faqKey)),

            // ── CTA Section ───────────────────────────────────────────────
            _AnimatedSection(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 80, horizontal: isDesktop ? 60 : 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Saha Operasyonlarınızı\nBugün Dijitalleştirin',
                            textAlign: TextAlign.center,
                            style: (isMobile
                                    ? theme.textTheme.headlineLarge
                                    : theme.textTheme.displayMedium)
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Lineer Destek ile verimliliğinizi %40 artırın, müşteri memnuniyetini zirveye taşıyın.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 48),
                          isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _PremiumButton(
                                      onPressed: _demoRequest,
                                      label: 'Demo Talep Et',
                                      isPrimary: false,
                                    ),
                                    const SizedBox(height: 16),
                                    _OutlinedHeroButton(
                                      onPressed: _talkToSales,
                                      label: 'Satışla Konuş',
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _PremiumButton(
                                      onPressed: _demoRequest,
                                      label: 'Demo Talep Et',
                                      isPrimary: false,
                                    ),
                                    const SizedBox(width: 16),
                                    _OutlinedHeroButton(
                                      onPressed: _talkToSales,
                                      label: 'Satışla Konuş',
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
            _Footer(
              width: size.width,
              onOpenLegal: _openLegal,
              onSupport: _talkToSales,
            ),
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
  final VoidCallback onRegister;
  final VoidCallback onWatchProduct;
  const _HeroContent({
    required this.onRegister,
    required this.onWatchProduct,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;
    final textAlign = isMobile ? TextAlign.center : TextAlign.start;
    final crossAlign = isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final buttonMainAlign = isMobile ? MainAxisAlignment.center : MainAxisAlignment.start;
    final titleFontSize = isMobile ? 38.0 : 56.0;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        const SizedBox(height: 24),
        Text(
          'Teknik Servislerinizi\nLineer Hızda Yönetin',
          textAlign: textAlign,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -2,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Müşteri taleplerinden saha operasyonlarına, yapay zeka destekli planlamadan dijital imzaya kadar her şeyi tek bir platformda toplayın.',
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: buttonMainAlign,
          children: [
            _PremiumButton(
              onPressed: onRegister,
              label: 'Kayıt Ol',
            ),
            if (!isMobile) ...[
              const SizedBox(width: 20),
              TextButton.icon(
                onPressed: onWatchProduct,
                icon: const Icon(Icons.play_circle_outline, size: 32),
                label: const Text('Ürünü İzle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                ),
              ),
            ],
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onWatchProduct,
            icon: const Icon(Icons.play_circle_outline, size: 28),
            label: const Text('Ürünü İzle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({super.key});
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/photos/2.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String? tag;
  final String title;
  final String subtitle;

  const _SectionHeader({
    this.tag,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (tag != null) ...[
          Text(
            tag!,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
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
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool isReversed;
  final VoidCallback onDetailTap;

  const _FeatureRow({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isReversed,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: const TextStyle(
            fontSize: 18,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        _OutlinedHeroButton(
          onPressed: onDetailTap,
          label: 'Detayları İncele',
        ),
      ],
    );

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        height: isMobile ? 300 : 450,
        width: double.infinity,
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          image,
          const SizedBox(height: 40),
          content,
        ],
      );
    }

    return Row(
      children: [
        if (!isReversed) ...[
          Expanded(child: content),
          const SizedBox(width: 80),
          Expanded(child: image),
        ] else ...[
          Expanded(child: image),
          const SizedBox(width: 80),
          Expanded(child: content),
        ],
      ],
    );
  }
}

class _WorkflowGraphic extends StatelessWidget {
  const _WorkflowGraphic({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    final steps = [
      {'number': '1', 'description': 'Müşteri Talebi Alınır ve Kaydedilir'},
      {'number': '2', 'description': 'Yapay Zeka ile En Yakın Teknisyene Atanır'},
      {'number': '3', 'description': 'Saha Ekibi İşe Başlar ve Dijital Form Doldurur'},
      {'number': '4', 'description': 'Müşteri Onayı ve Dijital İmza Alınır'},
      {'number': '5', 'description': 'Otomatik Raporlama ve Faturalandırma'},
    ];

    if (isMobile) {
      return Column(
        children: steps
            .map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            step['number']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          step['description']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _WorkflowStep(
              number: steps[i]['number']!,
              description: steps[i]['description']!,
            ),
            if (i < steps.length - 1) _WorkflowDivider(),
          ],
        ],
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final String number;
  final String description; // Changed from title and description to just description

  const _WorkflowStep({
    required this.number,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppColors.accent.withValues(alpha: 0.1),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          // Removed the title Text widget
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary), // Adjusted style
          ),
        ],
      ),
    );
  }
}

class _WorkflowDivider extends StatelessWidget {
  const _WorkflowDivider({super.key});
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
  final void Function(LegalDocument document) onOpenLegal;
  final VoidCallback onSupport;

  const _Footer({
    required this.width,
    required this.onOpenLegal,
    required this.onSupport,
  });

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
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        LinearLogo(size: 24),
                        SizedBox(width: 8),
                        Text('Lineer Destek',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('© 2026 ${SiteContact.companyName}. Tüm hakları saklıdır.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 4,
                    children: [
                      TextButton(
                        onPressed: () => onOpenLegal(LegalDocument.privacy),
                        child: const Text('Gizlilik'),
                      ),
                      TextButton(
                        onPressed: () => onOpenLegal(LegalDocument.kvkk),
                        child: const Text('KVKK'),
                      ),
                      TextButton(
                        onPressed: () => onOpenLegal(LegalDocument.terms),
                        child: const Text('Kullanım Şartları'),
                      ),
                      TextButton(
                        onPressed: () => onOpenLegal(LegalDocument.cookies),
                        child: const Text('Çerez Politikası'),
                      ),
                      TextButton(
                        onPressed: onSupport,
                        child: const Text('Destek'),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                const LinearLogo(size: 32),
                const SizedBox(height: 12),
                const Text('Lineer Destek',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 24),
                // Dar ekranlarda beş bağlantı yan yana sığmayacağı için
                // alt satıra kayabilen Wrap kullanılır.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => onOpenLegal(LegalDocument.privacy),
                      child: const Text('Gizlilik'),
                    ),
                    TextButton(
                      onPressed: () => onOpenLegal(LegalDocument.terms),
                      child: const Text('Şartlar'),
                    ),
                    TextButton(
                      onPressed: () => onOpenLegal(LegalDocument.kvkk),
                      child: const Text('KVKK'),
                    ),
                    TextButton(
                      onPressed: () => onOpenLegal(LegalDocument.cookies),
                      child: const Text('Çerezler'),
                    ),
                    TextButton(
                      onPressed: onSupport,
                      child: const Text('Destek'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('© 2026 ${SiteContact.companyName}. Tüm hakları saklıdır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
    );
  }
}

class _AnimatedSection extends StatefulWidget {
  final Widget child;
  const _AnimatedSection({required this.child});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 40.0, end: 0.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.03),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const _SectionHeader(
                title: 'Sayılarda Lineer Destek',
                subtitle: 'Teknik servis yönetiminde Türkiye\'nin tercihi.',
              ),
              const SizedBox(height: 60),
              isMobile
                  ? Column(
                      children: [
                        _StatItem(label: 'Aktif İşletme', value: '500+'),
                        const SizedBox(height: 40),
                        _StatItem(label: 'Çözülen Talep', value: '1M+'),
                        const SizedBox(height: 40),
                        _StatItem(label: 'Ort. Atama Süresi', value: '15 dk'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'Aktif İşletme', value: '500+'),
                        _StatItem(label: 'Çözülen Talep', value: '1M+'),
                        _StatItem(label: 'Ort. Atama Süresi', value: '15 dk'),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AIFeaturesSection extends StatelessWidget {
  const _AIFeaturesSection({super.key, required this.scrollController});

  /// Yığın efekti bu sayfanın kaydırma konumuna bağlıdır.
  final ScrollController scrollController;

  // Kaydırma ile değişen altı gerçek AI sohbet önizlemesi.
  static final List<AIChatPreviewCard> _aiPreviewCards = [
    AIChatPreviewCard(
      title: 'Teknisyen performansı',
      messages: [
        (
          'Bu ay hangi teknisyenler en çok iş tamamladı?',
          'Mert Yılmaz 46, Elif Demir 41 ve Can Kaya 38 tamamlanan iş ile öne çıkıyor. '
              'Mert Yılmaz\'ın tamamlama oranı %96.',
          true,
        ),
        (
          'Onun uzmanlıkları neler?',
          'Asansör, yangın güvenlik ve periyodik bakım alanlarında uzman. '
              '5 yıllık saha deneyimi var.',
          false,
        ),
      ],
    ),
    AIChatPreviewCard(
      title: 'Stok uyarısı',
      messages: [
        (
          'Kritik seviyedeki parçaları listele.',
          '4 parça kritik seviyede. En acil olan Asansör Rulman Seti: 4 adet kaldı, '
              'son 3 çalışmada kullanıldı.',
          true,
        ),
        (
          'Bu parçanın son hareketleri neler?',
          'Son 30 günde 2 kez tüketilmiş, 1 kez depoya giriş yapılmış. '
              'Tedarikçideki mevcut miktar sorunuzda belirtilmiyor.',
          false,
        ),
      ],
    ),
    AIChatPreviewCard(
      title: 'Muhasebe durumu',
      messages: [
        (
          'Vadesi geçen faturaları listele.',
          '3 fatura listeleniyor. Toplam alacak ₺48.200, en eski vade 12 gün önce.',
          true,
        ),
        (
          'Toplam alacağımız ne kadar?',
          'Toplam alacak ₺312.400, ödenmiş tutar ₺264.200. Kasa bakiyesi ₺87.900.',
          false,
        ),
      ],
    ),
    AIChatPreviewCard(
      title: 'Ticket ve operasyon',
      messages: [
        (
          'Yeni açılan ticketları göster.',
          'Son 24 saatte 7 ticket açıldı. 3 tanesi henüz atanmamış, en eskisi 6 saat önce.',
          true,
        ),
        (
          'Atanmamış asansör ticketını Mert Yılmaz\'a ata.',
          'Mert Yılmaz asansör uzmanı ve şu an 2 bekleyen işi var. '
              'Ticket atandı ve operasyon başlatıldı.',
          false,
        ),
      ],
    ),
    AIChatPreviewCard(
      title: 'Müşteri ve cihaz takibi',
      messages: [
        (
          'ABC Teknoloji müşterisinin garanti bitimi yaklaşan cihazlarını göster.',
          'ABC Teknoloji için 3 cihazın garantisi 30 gün içinde bitiyor. '
              'En yakın bitiş: SN-AX220 cihazında 12 gün kaldı.',
          true,
        ),
        (
          'SN-AX220 için son arıza kaydı nedir?',
          'SN-AX220 için son kayıt 9 gün önce açılmış: "soğutma performansı düşük". '
              'Yerinde bakım tamamlandı, durum kapalı.',
          false,
        ),
      ],
    ),
    AIChatPreviewCard(
      title: 'İnsan kaynakları özeti',
      messages: [
        (
          'Bu ay izinli personel ve açık avans taleplerini özetle.',
          'Bu ay 6 personel izinli görünüyor. 2 açık avans talebi var; '
              'toplam talep tutarı ₺18.500.',
          true,
        ),
        (
          'Geciken iş sayısı yüksek olan ekip hangisi?',
          'Saha Operasyon Ekibi-2, 14 geciken iş ile en yüksek değerde. '
              'Aynı ekipte tamamlanan iş oranı %82.',
          false,
        ),
      ],
    ),
  ];

  // AI'ın gerçekten yapabildiği işler. Her kart, üründe çalışan bir
  // yeteneği anlatır; vaat edilen ama uygulanmayan özellikler yoktur.
  static const List<_AIDomain> _domains = [
    _AIDomain(
      icon: Icons.assignment_outlined,
      title: 'Operasyon ve Ticket Yönetimi',
      description:
          'Açık ticketları, iş emirlerini ve durumlarını listeler. Müşteri adına yeni bir ticket açabilir, mevcut talebi teknisyene atayarak operasyona dönüştürebilir.',
      capabilities: [
        'Açık ticket listesi ve durum takibi',
        'Ticket detayı ve işlem geçmişi',
        'Ticket\'ı teknisyene atama ve operasyon başlatma',
      ],
    ),
    _AIDomain(
      icon: Icons.engineering_outlined,
      title: 'Teknisyen Yönetimi',
      description:
          'Teknisyenleri ad, uzmanlık alanı, iletişim bilgisi ve iş yüküne göre arar. Tek bir teknisyenin profilini, tamamlama oranını ve son işlerini detaylı verir.',
      capabilities: [
        'Uzmanlık ve iş yüküne göre teknisyen listesi',
        'Teknisyen detayı: deneyim, iletişim, performans',
        'Aktif, tamamlanan ve bekleyen iş dağılımı',
      ],
    ),
    _AIDomain(
      icon: Icons.inventory_2_outlined,
      title: 'Stok ve Yedek Parça',
      description:
          'Kritik stok seviyesini, mevcut ve rezerve miktarları raporlar. Parça hareketlerini ve rezervasyon durumunu tarih aralığına göre inceler.',
      capabilities: [
        'Kritik stok ve toplam envanter özeti',
        'Stok kartı, birim fiyat ve miktar sorgusu',
        'Stok giriş/çıkış hareketleri ve rezervasyonlar',
      ],
    ),
    _AIDomain(
      icon: Icons.receipt_long_outlined,
      title: 'Muhasebe ve Finans',
      description:
          'Alacak, borç, fatura ve tahsilat toplamlarını verir. Vadesi geçen faturaları, cari hesap bakiyelerini ve ekstre hareketlerini sorgular.',
      capabilities: [
        'Alacak, borç ve tahsilat özeti',
        'Vadesi geçen fatura listesi',
        'Cari hesap bakiyesi ve ekstre hareketleri',
      ],
    ),
    _AIDomain(
      icon: Icons.people_alt_outlined,
      title: 'Müşteri ve Cihaz',
      description:
          'Müşteri sayısını, cihaz envanterini ve garanti durumunu raporlar. Bir müşterinin cihazlarını arıza kaydı ve garanti bitiş tarihiyle listeler.',
      capabilities: [
        'Müşteri ve cihaz sayıları, garanti dağılımı',
        'Müşteri arama ve detay sorgusu',
        'Cihaz arıza geçmişi ve garanti bitiş tarihi',
      ],
    ),
    _AIDomain(
      icon: Icons.badge_outlined,
      title: 'İnsan Kaynakları',
      description:
          'Çalışan sayısını, izin durumunu ve avans taleplerini özetler. Aylık performans raporlarını tamamlanan, geciken iş ve ödül/ceza verileriyle verir.',
      capabilities: [
        'Çalışan, izin ve avans özeti',
        'Departman ve unvan bazında personel listesi',
        'Aylık performans ve gecikme analizi',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.bgSurface,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const _SectionHeader(
                tag: 'LINEER AI',
                title: 'Kurumunuzun verisini konuşan asistan',
                subtitle:
                    'Lineer AI, operasyon, stok, muhasebe, müşteri ve insan kaynakları '
                    'verilerinize doğrudan erişir. Rapor hazırlamak için menülerde '
                    'dolaşmak yerine tek cümleyle sorun; cevabı anında alın.',
              ),
              const SizedBox(height: 32),
              AIChatPreviewStack(
                scrollController: scrollController,
                cards: _aiPreviewCards,
              ),
              const SizedBox(height: 72),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Kart yüksekliği içeriğe göre belirlensin diye GridView
                  // yerine Wrap kullanılır; sabit en-boy oranı uzun
                  // metinlerde dikey taşma üretiyordu.
                  const spacing = 24.0;
                  final columns = constraints.maxWidth >= 1000
                      ? 3
                      : (constraints.maxWidth >= 620 ? 2 : 1);
                  final cardWidth =
                      (constraints.maxWidth - spacing * (columns - 1)) / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final domain in _domains)
                        SizedBox(
                          width: cardWidth,
                          child: _AIDomainCard(domain: domain),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 56),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        color: AppColors.accent, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Lineer AI yalnızca size ait verileri görür. Tüm sorgular '
                        'kiracınıza özeldir ve başka firmalarla paylaşılmaz.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AI'ın yapabildiği bir iş alanını tanımlar.
class _AIDomain {
  const _AIDomain({
    required this.icon,
    required this.title,
    required this.description,
    required this.capabilities,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> capabilities;
}

class _AIDomainCard extends StatelessWidget {
  const _AIDomainCard({required this.domain});

  final _AIDomain domain;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(domain.icon, color: AppColors.accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  domain.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            domain.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          for (final capability in domain.capabilities)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.statusGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      capability,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// AI sohbet arayüzünün gerçek bir örneğini gösteren tanıtım bloğu.
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FAQSection extends StatelessWidget {
  const _FAQSection({super.key, required this.sectionKey});

  final Key sectionKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const _SectionHeader(
                title: 'Sıkça Sorulan Sorular',
                subtitle: 'Platformumuz hakkında en çok merak edilenler.',
              ),
              const SizedBox(height: 60),
              _FAQItem(
                question: 'Yapay Zeka (AI) operasyonlarımızı nasıl kolaylaştırır?',
                answer:
                    'Lineer AI, gelen servis taleplerini analiz ederek en uygun teknisyeni otomatik atar, yedek parça ihtiyacını önceden tahmin eder ve teknisyenlerinize arıza çözümünde akıllı ipuçları sunarak verimliliği %40 artırır.',
              ),
              _FAQItem(
                question: 'Lineer Destek hangi sektörler için uygun?',
                answer:
                    'Beyaz eşya, iklimlendirme, asansör, güvenlik sistemleri ve saha operasyonu yürüten tüm teknik servisler için özel olarak tasarlanmıştır.',
              ),
              _FAQItem(
                question: 'Dijital imza yasal olarak geçerli mi?',
                answer:
                    'Evet, servis formları üzerinde alınan biyometrik dijital imzalar, onay süreçlerinde standart servis dökümanı olarak kabul görmektedir.',
              ),
              _FAQItem(
                question: 'Mevcut verilerimi sisteme aktarabilir miyim?',
                answer:
                    'Evet, Excel veya API servislerimiz aracılığıyla mevcut müşteri ve envanter verilerinizi dakikalar içinde Lineer Destek\'e taşıyabilirsiniz.',
              ),
              _FAQItem(
                question: 'Offline (internet yokken) çalışma desteği var mı?',
                answer:
                    'Evet, mobil uygulamamız internet kesildiğinde verileri saklar ve ilk bağlantıda otomatik olarak bulut sunucularımızla senkronize eder.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            title: Text(
              widget.question,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.remove : Icons.add,
              color: AppColors.accent,
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      child:
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
