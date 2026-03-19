import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:techsupport_mobile/core/design/app_design.dart';
import 'package:techsupport_mobile/features/auth/presentation/login_page.dart';

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
      drawer: isDesktop ? null : Drawer(
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
                    onPressed: _navigateToLogin,
                    label: 'Giriş Yap',
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
                              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
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
                            label: 'İletişim',
                            onTap: () => _scrollToKey(_contactKey),
                          ),
                          const SizedBox(width: 24),
                          _PremiumButton(
                            onPressed: _navigateToLogin,
                            label: 'Giriş Yap',
                            isPrimary: true,
                          ),
                        ],
                        if (!isDesktop)
                          IconButton(
                            onPressed: _navigateToLogin,
                            icon: const Icon(Icons.login_rounded, color: AppColors.accent),
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
                padding: EdgeInsets.only(top: isDesktop ? 160 : 120, bottom: isDesktop ? 80 : 40),
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
                                _HeroContent(onLogin: _navigateToLogin),
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
                          subtitle: 'Lineer Destek ile teknik servis süreçlerinizi uçtan uca dijitalleştirin.',
                        ),
                        const SizedBox(height: 60),
                        Column(
                          children: [
                            _FeatureRow(
                              title: 'Yapay Zeka Atama',
                              description: 'Talepleri konuma ve uzmanlığa göre en uygun teknisyene anında yönlendirin.',
                              imagePath: 'assets/photos/7.png',
                              isReversed: false,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Saha Takibi',
                              description: 'Teknisyenlerinizi harita üzerinde canlı izleyin ve rota optimizasyonu yapın.',
                              imagePath: 'assets/photos/4.png',
                              isReversed: true,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Stok Yönetimi',
                              description: 'Araçlardaki ve ana depodaki yedek parçaları gerçek zamanlı kontrol edin.',
                              imagePath: 'assets/photos/8.png',
                              isReversed: false,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Gelişmiş Raporlama',
                              description: 'Servis performansını, maliyetleri ve müşteri memnuniyetini anlık izleyin.',
                              imagePath: 'assets/photos/5.png',
                              isReversed: true,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Dijital Onay ve İmza',
                              description: 'Servis formlarını sahada dijital imza ile anında onaylatın ve PDF yapın.',
                              imagePath: 'assets/photos/9.png',
                              isReversed: false,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'SLA Takibi',
                              description: 'Müşteri sözleşmelerine göre müdahale ve çözüm sürelerini garanti altına alın.',
                              imagePath: 'assets/photos/4.png',
                              isReversed: true,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Müşteri Portalı',
                              description: 'Müşterileriniz kendi taleplerini açsın ve sürecini şeffafça takip etsin.',
                              imagePath: 'assets/photos/3.png',
                              isReversed: false,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Rota Optimizasyonu',
                              description: 'Teknisyenleriniz için en kısa ve verimli günlük çalışma rotasını oluşturun.',
                              imagePath: 'assets/photos/2.png',
                              isReversed: true,
                            ),
                            const SizedBox(height: 80),
                            _FeatureRow(
                              title: 'Hakediş & Faturalama',
                              description: 'Teknisyen hakedişlerini ve servis maliyetlerini otomatik olarak hesaplayın.',
                              imagePath: 'assets/photos/10.png',
                              isReversed: false,
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
                          subtitle: 'Talepten rapora kadar süreci saniyeler içinde tamamlayın.',
                        ),
                        const SizedBox(height: 80),
                        _WorkflowGraphic(),
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 0),
                            child: isMobile
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _PremiumButton(
                                        onPressed: () {},
                                        label: 'Demo Talep Et',
                                        isPrimary: false,
                                      ),
                                      const SizedBox(height: 12),
                                      _OutlinedHeroButton(
                                        onPressed: () {},
                                        label: 'Satışla Konuş',
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _PremiumButton(
                                        onPressed: () {},
                                        label: 'Demo Talep Et',
                                        isPrimary: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _OutlinedHeroButton(
                                        onPressed: () {},
                                        label: 'Satışla Konuş',
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
              child: _AIFeaturesSection(key: _aiKey),
            ),

            // ── FAQ Section ───────────────────────────────────────────────
            _AnimatedSection(child: _FAQSection()),

            // ── CTA Section ───────────────────────────────────────────────
            _AnimatedSection(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isDesktop ? 60 : 24),
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
                            style: (isMobile ? theme.textTheme.headlineLarge : theme.textTheme.displayMedium)?.copyWith(
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
                                      onPressed: () {},
                                      label: 'Demo Talep Et',
                                      isPrimary: false,
                                    ),
                                    const SizedBox(height: 16),
                                    _OutlinedHeroButton(
                                      onPressed: () {},
                                      label: 'Satışla Konuş',
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _PremiumButton(
                                      onPressed: () {},
                                      label: 'Demo Talep Et',
                                      isPrimary: false,
                                    ),
                                    const SizedBox(width: 16),
                                    _OutlinedHeroButton(
                                      onPressed: () {},
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
              onPressed: onLogin,
              label: 'Demo Talep Et',
            ),
            if (!isMobile) ...[
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
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {},
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

  const _FeatureRow({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isReversed,
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
          onPressed: () {},
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
        children: steps.map((step) => Padding(
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
        )).toList(),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary), // Adjusted style
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
                         Text('Lineer Destek', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('© 2026 Lineer Destek. Tüm hakları saklıdır.', 
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Gizlilik')),
                    TextButton(onPressed: () {}, child: const Text('Kullanım Şartları')),
                    TextButton(onPressed: () {}, child: const Text('Destek')),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                const LinearLogo(size: 32),
                const SizedBox(height: 12),
                const Text('Lineer Destek', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Gizlilik')),
                    TextButton(onPressed: () {}, child: const Text('Şartlar')),
                    TextButton(onPressed: () {}, child: const Text('Destek')),
                  ],
                ),
                const SizedBox(height: 24),
                Text('© 2026 Lineer Destek. Tüm hakları saklıdır.', 
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
  const _AIFeaturesSection({super.key});

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
                tag: 'YAPAY ZEKA GÜCÜ',
                title: 'Lineer AI: Otonom Saha Yönetimi',
                subtitle: 'Geleneksel teknik servis yönetimini unutun. Yapay zeka ile işlerinizi otomatize edin, hataları sıfırlayın.',
              ),
              const SizedBox(height: 80),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final isTablet = constraints.maxWidth < 1000;
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                    mainAxisSpacing: 32,
                    crossAxisSpacing: 32,
                    childAspectRatio: isMobile ? 1.5 : 1.2,
                    children: const [
                      _AIFeatureCard(
                        icon: Icons.auto_awesome_motion,
                        title: 'Akıllı İş Atama & Rotalama',
                        description: 'Yapay zeka, teknisyen konumu, uzmanlığı ve parça durumunu analiz ederek en doğru atamayı anında yapar.',
                      ),
                      _AIFeatureCard(
                        icon: Icons.inventory_2,
                        title: 'Otonom Stok & Tedarik',
                        description: 'Cihaz geçmişini analiz eder, azalan parçaları belirler ve tedarikçilere otomatik talep e-postaları hazırlar.',
                      ),
                      _AIFeatureCard(
                        icon: Icons.forum_rounded,
                        title: 'Yapay Zeka Müşteri Temsilcisi',
                        description: 'Müşterileriniz ile doğal dilde konuşarak arıza detaylarını alır ve saniyeler içinde servis kaydı oluşturur.',
                      ),
                      _AIFeatureCard(
                        icon: Icons.psychology,
                        title: 'Duygu & Aciliyet Analizi',
                        description: 'Müşterinin ses tonu ve mesajlarındaki duygu durumunu analiz ederek gerçek aciliyet seviyesine göre öncelik atar.',
                      ),
                      _AIFeatureCard(
                        icon: Icons.query_stats_rounded,
                        title: 'Öngörücü Bakım & Fiyatlama',
                        description: 'Arıza belirtilerine göre parça maliyetini ve işçilik süresini önceden tahmin ederek doğru fiyat sunmanızı sağlar.',
                      ),
                      _AIFeatureCard(
                        icon: Icons.assignment_turned_in,
                        title: 'Teknisyen Performans Analitiği',
                        description: 'İş bitirme hızı ve başarı oranı verilerini analiz ederek ekibin verimliliğini artıracak içgörüler sunar.',
                      ),
                      _AIFeatureCard(
                        icon: Icons.analytics_rounded,
                        title: 'Kronik Arıza & Parça İzleme',
                        description: 'Hangi markada hangi parçanın ne zaman arıza yapacağını tahmin eder, yedek parça stratejinizi optimize eder.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AIFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AIFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.accent, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
  const _FAQSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
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
                answer: 'Lineer AI, gelen servis taleplerini analiz ederek en uygun teknisyeni otomatik atar, yedek parça ihtiyacını önceden tahmin eder ve teknisyenlerinize arıza çözümünde akıllı ipuçları sunarak verimliliği %40 artırır.',
              ),
              _FAQItem(
                question: 'Lineer Destek hangi sektörler için uygun?',
                answer: 'Beyaz eşya, iklimlendirme, asansör, güvenlik sistemleri ve saha operasyonu yürüten tüm teknik servisler için özel olarak tasarlanmıştır.',
              ),
              _FAQItem(
                question: 'Dijital imza yasal olarak geçerli mi?',
                answer: 'Evet, servis formları üzerinde alınan biyometrik dijital imzalar, onay süreçlerinde standart servis dökümanı olarak kabul görmektedir.',
              ),
              _FAQItem(
                question: 'Mevcut verilerimi sisteme aktarabilir miyim?',
                answer: 'Evet, Excel veya API servislerimiz aracılığıyla mevcut müşteri ve envanter verilerinizi dakikalar içinde Lineer Destek\'e taşıyabilirsiniz.',
              ),
              _FAQItem(
                question: 'Offline (internet yokken) çalışma desteği var mı?',
                answer: 'Evet, mobil uygulamamız internet kesildiğinde verileri saklar ve ilk bağlantıda otomatik olarak bulut sunucularımızla senkronize eder.',
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
          side: isPrimary ? BorderSide.none : const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}



