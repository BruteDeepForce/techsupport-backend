import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Admin web için koyu/teknolojik görünüm dileri.
///
/// Tüm admin sayfaları bu paleti kullanır: koyu lacivert zemin, yarı saydam
/// cam yüzeyler ve tek bir vurgu ailesi. Sayısal değerler tek aralıklı
/// (tabular) rakamla hizalanır.
class AdminTechColors {
  AdminTechColors._();

  // ── Zemin ─────────────────────────────────────────────────────────────────
  static const canvas = Color(0xFF020408);
  static const canvasTop = Color(0xFF05080F);

  // ── Yüzeyler ──────────────────────────────────────────────────────────────
  /// Kart ve tablo yüzeyi; sayfa zemini ve içerik arasındaki kontrastı taşır.
  static const surface = Color(0xFF070C17);

  /// İç içe geçmiş yüzey (tablo başlığı, ikincil panel, hover satırı).
  static const surfaceAlt = Color(0xFF0A1022);

  /// Form alanı, kutu ve diğer hafif yükseltilmiş yüzey.
  static const surfaceRaised = Color(0xFF0D1428);

  // Kenarlıklar soğuk mavi (7BA7D9) ailesinden; saf gri yerine geçince
  // kart çerçeveleri koyu zeminde daha resmi ve derin görünür.
  // Opaklık, çizgi kalınlığı değiştirilmeden görünürlük ayarı içindir.
  static const border = Color(0x667BA7D9);

  /// Cam yüzey kenarlığı; kart çerçevesi ve ince ayrım çizgileri için.
  static const panelBorder = Color(0x3D7BA7D9);
  static const borderStrong = Color(0x8C7BA7D9);

  /// En ince ayrım çizgileri ve varsayılan kart çerçevesi.
  static const borderSubtle = Color.fromARGB(149, 139, 137, 137);

  // ── Metin ─────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFEAF1FF);
  static const textSecondary = Color(0xFFB3C2DC);
  static const textTertiary = Color(0xFF8595B4);
  static const textDisabled = Color(0xFF5B6B89);
  static const textOnAccent = Color(0xFFFFFFFF);

  // ── Vurgular ──────────────────────────────────────────────────────────────
  static const cyan = Color(0xFF22D3EE);
  static const indigo = Color(0xFF6366F1);
  static const violet = Color(0xFFA855F7);
  static const green = Color(0xFF34D399);
  static const amber = Color(0xFFFBBF24);
  static const orange = Color(0xFFFB923C);
  static const red = Color(0xFFF87171);
  static const slate = Color(0xFF7C8CA8);
  static const teal = Color(0xFF2DD4BF);

  /// Eski mavi vurguların yerini alan birincil aksiyon rengi.
  static const primary = cyan;

  // ── Metalik tonlar ────────────────────────────────────────────────────────
  // Alt bar gibi ikincil gezinme yüzeylerinde, sert gri yerine yumuşak bir
  // gümüş geçiş kullanılır; koyu lacivert üzerinde "metalik" ama tatlı durur.

  /// Metalik yüzeyin üst (aydınlık) tonu.
  static const metalLight = Color(0xFFE2E9F5);

  /// Metalik yüzeyin alt (gölge) tonu.
  static const metalShade = Color(0xFF8FA0BE);

  /// Pasif sekme ikonu/yazısı için metalik geçiş.
  static const metalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [metalLight, metalShade],
  );

  /// Aktif sekmenin metalik vurgusu: parlak gümüşün cyan'e yaslanmış hâli.
  static const metalActiveGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFB8F4FF), cyan],
  );

  /// Durum rozetlerinde kullanılan, koyu zeminde okunabilir tonlar.
  static const statusGreen = Color(0xFF4ADE80);
  static const statusAmber = Color(0xFFFCD34D);
  static const statusRed = Color(0xFFFB7185);
  static const statusBlue = Color(0xFF60A5FA);
  static const statusPurple = Color(0xFFC084FC);
  static const statusGray = Color(0xFF94A3B8);

  /// Durum renklerine karşılık gelen düşük opaklıklı dolgular.
  static final Color greenBg = green.withValues(alpha: 0.14);
  static final Color amberBg = amber.withValues(alpha: 0.14);
  static final Color redBg = red.withValues(alpha: 0.14);
  static final Color cyanBg = cyan.withValues(alpha: 0.14);
  static final Color violetBg = violet.withValues(alpha: 0.14);
  static final Color slateBg = slate.withValues(alpha: 0.14);
  static final Color indigoBg = indigo.withValues(alpha: 0.14);

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF22D3EE)],
  );

  static const panelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF121B36), Color(0xFF0C1327)],
  );
}

/// Sayfa zemini: koyu dikey gradyan + iki yönlü yumuşak ışıma.
/// Izgara dokusu bilerek kullanılmıyor; zemin sade ve derin kalıyor.
class AdminTechBackdrop extends StatelessWidget {
  const AdminTechBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AdminTechColors.canvasTop, AdminTechColors.canvas],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -220,
            right: -160,
            child: _GlowOrb(color: AdminTechColors.indigo, size: 520),
          ),
          const Positioned(
            top: 160,
            left: -200,
            child: _GlowOrb(color: Color(0xFF0EA5E9), size: 420),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

/// Koyu cam yüzeyli kart. `glow` verildiğinde üst kenarda vurgu çizgisi belirir.
class AdminTechCard extends StatelessWidget {
  const AdminTechCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.glow,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? glow;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: AdminTechColors.panelGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminTechColors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          if (glow != null)
            BoxShadow(
              color: glow!.withValues(alpha: 0.22),
              blurRadius: 26,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: child,
    );
  }
}

/// Sayısal değerler için tek aralıklı stil; dikey ritmi bozmaması için
/// tüm rakamlar aynı genişliğe sahip olur.
const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

TextStyle adminTechValueStyle({
  double size = 26,
  FontWeight weight = FontWeight.w700,
  Color color = AdminTechColors.textPrimary,
  double? letterSpacing,
}) =>
    TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing ?? -0.5,
      fontFeatures: _tabular,
    );

/// Büyük harfli, ince ve aralıklı üst başlık.
TextStyle adminTechLabelStyle({
  double size = 11,
  FontWeight weight = FontWeight.w600,
  Color color = AdminTechColors.textTertiary,
}) =>
    TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 1.1,
    );

/// Bölüm başlığı: ikon + başlık + isteğe bağlı sağ aksiyon.
class AdminTechSectionTitle extends StatelessWidget {
  const AdminTechSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AdminTechColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                  color: AdminTechColors.cyan.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, size: 16, color: AdminTechColors.cyan),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AdminTechColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminTechColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Küçük seçim/etiket rozeti.
class AdminTechPill extends StatelessWidget {
  const AdminTechPill({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.color,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AdminTechColors.cyan;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.5)
              : AdminTechColors.panelBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? accent : AdminTechColors.textSecondary,
        ),
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: child,
    );
  }
}

/// Yayılan "canlı" göstergesi.
class AdminTechPulseDot extends StatefulWidget {
  const AdminTechPulseDot(
      {super.key, this.color = AdminTechColors.green, this.size = 8});

  final Color color;
  final double size;

  @override
  State<AdminTechPulseDot> createState() => _AdminTechPulseDotState();
}

class _AdminTechPulseDotState extends State<AdminTechPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_controller.value);
        return SizedBox(
          width: widget.size * 2.4,
          height: widget.size * 2.4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t) * 0.6,
                child: Container(
                  width: widget.size + (widget.size * 1.4 * t),
                  height: widget.size + (widget.size * 1.4 * t),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.35),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }
}

/// Küçük iç/dış çizgili sparkline. Değerler tek nokta ise düz çizgi çizer.
class AdminTechSparkline extends StatelessWidget {
  const AdminTechSparkline({
    super.key,
    required this.values,
    this.color = AdminTechColors.cyan,
    this.height = 34,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SparklinePainter(values: values, color: color),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;

    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final span =
        (maxValue - minValue).abs() < 0.0001 ? 1.0 : maxValue - minValue;

    // Yatayda tam genişlik, dikeyde 4px nefes payı bırakılır.
    const pad = 4.0;
    final usableHeight = size.height - pad * 2;
    final stepX = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          stepX * i,
          pad + usableHeight - ((values[i] - minValue) / span) * usableHeight,
        ),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(points.last, 3, Paint()..color = color);
    canvas.drawCircle(
      points.last,
      6,
      Paint()..color = color.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

/// Yüzde gösteren halka. `progress` 0..1 aralığında beklenir.
class AdminTechRing extends StatelessWidget {
  const AdminTechRing({
    super.key,
    required this.progress,
    required this.centerLabel,
    this.size = 108,
    this.color = AdminTechColors.cyan,
    this.caption,
  });

  final double progress;
  final String centerLabel;
  final double size;
  final Color color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter:
              _RingPainter(progress: progress.clamp(0.0, 1.0), color: color),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(centerLabel,
                    style: adminTechValueStyle(size: size * 0.22)),
                if (caption != null)
                  Text(
                    caption!,
                    style: adminTechLabelStyle(size: size * 0.085),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke,
    );

    if (progress <= 0) return;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: [color.withValues(alpha: 0.35), color],
        ).createShader(rect)
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Yatay dağılım çubuğu: parçaları oranla yan yana gösterir.
class AdminTechDistributionBar extends StatelessWidget {
  const AdminTechDistributionBar(
      {super.key, required this.segments, this.height = 10});

  final List<({String label, int value, Color color})> segments;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<int>(0, (sum, s) => sum + s.value);
    if (total <= 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(height),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (final segment in segments)
              if (segment.value > 0)
                Expanded(
                  flex: segment.value,
                  child: Container(color: segment.color),
                ),
          ],
        ),
      ),
    );
  }
}

/// Dikey çubuklu mini grafik; aylık/haftalık karşılaştırma için.
class AdminTechBars extends StatelessWidget {
  const AdminTechBars({
    super.key,
    required this.values,
    this.labels = const [],
    this.height = 120,
    this.color = AdminTechColors.indigo,
  });

  final List<double> values;
  final List<String> labels;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return SizedBox(height: height);

    final maxValue = values.reduce(math.max);
    final displayMax = maxValue <= 0 ? 1.0 : maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final value in values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      height: (value / displayMax) * height,
                      constraints: const BoxConstraints(minHeight: 3),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [color.withValues(alpha: 0.35), color],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (labels.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              for (final label in labels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: adminTechLabelStyle(size: 10),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Yükleniyor / hata / boş durumlar için ortak koyu yer tutucu.
class AdminTechPlaceholder extends StatelessWidget {
  const AdminTechPlaceholder({
    super.key,
    required this.label,
    this.height = 120,
    this.icon,
    this.showSpinner = false,
  });

  final String label;
  final double height;
  final IconData? icon;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AdminTechColors.cyan,
              ),
            )
          else if (icon != null)
            Icon(icon,
                size: 26,
                color: AdminTechColors.textTertiary.withValues(alpha: 0.7)),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, color: AdminTechColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Admin sayfalarında kullanılan koyu Material teması.
///
/// Gelen metin teması uygulamanın açık temasından türetilir; renkleri siyaha
/// yakındır. Koyu zeminde o renkler okunmaz olduğu için, koyu ve renksiz
/// stiller açık metin rengine çevrilir. Kasıtlı parlak renkler korunur.
TextTheme _brightenForDark(TextTheme theme) {
  TextStyle fix(TextStyle? s) {
    if (s == null) return const TextStyle(color: AdminTechColors.textPrimary);
    final c = s.color;
    if (c != null && c.a > 0.5 && c.computeLuminance() >= 0.25) return s;
    return s.copyWith(color: AdminTechColors.textPrimary);
  }

  return TextTheme(
    displayLarge: fix(theme.displayLarge),
    displayMedium: fix(theme.displayMedium),
    displaySmall: fix(theme.displaySmall),
    headlineLarge: fix(theme.headlineLarge),
    headlineMedium: fix(theme.headlineMedium),
    headlineSmall: fix(theme.headlineSmall),
    titleLarge: fix(theme.titleLarge),
    titleMedium: fix(theme.titleMedium),
    titleSmall: fix(theme.titleSmall),
    bodyLarge: fix(theme.bodyLarge),
    bodyMedium: fix(theme.bodyMedium),
    bodySmall: fix(theme.bodySmall),
    labelLarge: fix(theme.labelLarge),
    labelMedium: fix(theme.labelMedium),
    labelSmall: fix(theme.labelSmall),
  );
}

/// Sayfalar kendi renklerini [AdminTechColors] üzerinden verse de form
/// alanları, açılır menüler, diyaloglar ve tablo başlıkları Material
/// bileşenleridir; bu tema onları da koyu palete uyarlar.
ThemeData buildAdminDarkTheme(TextTheme textTheme) {
  textTheme = _brightenForDark(textTheme);

  const scheme = ColorScheme.dark(
    primary: AdminTechColors.cyan,
    onPrimary: Color(0xFF04222B),
    secondary: AdminTechColors.indigo,
    onSecondary: Colors.white,
    surface: AdminTechColors.surface,
    onSurface: AdminTechColors.textPrimary,
    error: AdminTechColors.red,
    onError: Color(0xFF3B0A0A),
    outline: AdminTechColors.border,
    // Material'in koyu şema varsayılanı beyazdır; bu değer açıkça
    // belirtilmezse her kart kenarlığı kalın beyaz çizgi olarak görünür.
    outlineVariant: AdminTechColors.borderSubtle,
  );

  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AdminTechColors.canvas,
    canvasColor: AdminTechColors.surface,
    cardColor: AdminTechColors.surface,
    dividerColor: AdminTechColors.borderSubtle,
    textTheme: textTheme,
    dialogTheme: DialogThemeData(
      backgroundColor: AdminTechColors.surfaceAlt,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AdminTechColors.border),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AdminTechColors.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 13.5,
        height: 1.5,
        color: AdminTechColors.textSecondary,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AdminTechColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AdminTechColors.surface,
      foregroundColor: AdminTechColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: AdminTechColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: AdminTechColors.border),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: const WidgetStatePropertyAll(AdminTechColors.surfaceAlt),
      dataRowColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AdminTechColors.surfaceRaised
            : Colors.transparent,
      ),
      dividerThickness: 0.5,
      headingTextStyle: adminTechLabelStyle(size: 10),
      dataTextStyle: const TextStyle(
        fontSize: 12.5,
        color: AdminTechColors.textSecondary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AdminTechColors.cyan,
        foregroundColor: const Color(0xFF04222B),
        elevation: 0,
        minimumSize: const Size(88, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminTechColors.surfaceRaised,
        foregroundColor: AdminTechColors.textPrimary,
        elevation: 0,
        minimumSize: const Size(88, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminTechColors.textPrimary,
        side: const BorderSide(color: AdminTechColors.border),
        minimumSize: const Size(88, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AdminTechColors.cyan,
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style:
          IconButton.styleFrom(foregroundColor: AdminTechColors.textSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AdminTechColors.surfaceAlt,
      isDense: true,
      hintStyle: const TextStyle(
        fontSize: 13.5,
        color: AdminTechColors.textTertiary,
      ),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: AdminTechColors.textSecondary,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 12.5,
        color: AdminTechColors.cyan,
      ),
      prefixIconColor: AdminTechColors.textTertiary,
      suffixIconColor: AdminTechColors.textTertiary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(AdminTechColors.border),
      enabledBorder: border(AdminTechColors.border),
      focusedBorder: border(AdminTechColors.cyan, 1.4),
      errorBorder: border(AdminTechColors.red),
      focusedErrorBorder: border(AdminTechColors.red, 1.4),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminTechColors.surfaceAlt,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(
          fontSize: 13.5,
          color: AdminTechColors.textTertiary,
        ),
        border: border(AdminTechColors.border),
        enabledBorder: border(AdminTechColors.border),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AdminTechColors.surfaceAlt,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AdminTechColors.border),
      ),
      textStyle: const TextStyle(
        fontSize: 13.5,
        color: AdminTechColors.textPrimary,
      ),
    ),
    menuTheme: const MenuThemeData(),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AdminTechColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminTechColors.border),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        color: AdminTechColors.textPrimary,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AdminTechColors.surfaceRaised,
      contentTextStyle: const TextStyle(
        fontSize: 13.5,
        color: AdminTechColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AdminTechColors.border),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AdminTechColors.cyan,
      linearTrackColor: AdminTechColors.surfaceAlt,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AdminTechColors.cyan
            : AdminTechColors.textTertiary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AdminTechColors.cyan.withValues(alpha: 0.30)
            : AdminTechColors.surfaceAlt,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(AdminTechColors.border),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AdminTechColors.cyan
            : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(Color(0xFF04222B)),
      side: const BorderSide(color: AdminTechColors.borderStrong),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AdminTechColors.cyan
            : AdminTechColors.textTertiary,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AdminTechColors.cyan,
      unselectedLabelColor: AdminTechColors.textTertiary,
      indicatorColor: AdminTechColors.cyan,
      dividerColor: AdminTechColors.borderSubtle,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 13),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AdminTechColors.surfaceAlt,
      side: const BorderSide(color: AdminTechColors.border),
      labelStyle: const TextStyle(
        fontSize: 12,
        color: AdminTechColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AdminTechColors.textPrimary,
      iconColor: AdminTechColors.textSecondary,
    ),
    expansionTileTheme: const ExpansionTileThemeData(
      iconColor: AdminTechColors.textSecondary,
      collapsedIconColor: AdminTechColors.textTertiary,
      textColor: AdminTechColors.textPrimary,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AdminTechColors.cyan,
      inactiveTrackColor: AdminTechColors.surfaceAlt,
      thumbColor: AdminTechColors.cyan,
      overlayColor: Color(0x2922D3EE),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(
        AdminTechColors.textTertiary.withValues(alpha: 0.35),
      ),
      radius: const Radius.circular(8),
      thickness: const WidgetStatePropertyAll(6),
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}

/// Sayfa başlığı: başlık + alt açıklama + aksiyonlar.
///
/// Dar ekranda aksiyonlar başlığın altına sarar; aksi halde buton satırı
/// yatayda taşıyor ve içerik ekrandan taşıyor.
class AdminTechPageHeader extends StatelessWidget {
  const AdminTechPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 620;

        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AdminTechColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AdminTechColors.textSecondary,
                ),
              ),
            ],
          ],
        );

        if (actions.isEmpty) return heading;

        final actionRow = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: actions,
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: 14),
              actionRow,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 20),
            actionRow,
          ],
        );
      },
    );
  }
}

/// Sayfanın birincil aksiyonu.
class AdminTechPrimaryButton extends StatelessWidget {
  const AdminTechPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminTechColors.cyan,
        foregroundColor: const Color(0xFF04222B),
      ),
    );
  }
}

/// Sayfanın ikincil aksiyonu.
class AdminTechSecondaryButton extends StatelessWidget {
  const AdminTechSecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminTechColors.textPrimary,
        side: const BorderSide(color: AdminTechColors.border),
      ),
    );
  }
}

/// Alt ağacı koyu lacivert admin temasına sokar.
///
/// Hem web (`AdminWebShell`) hem mobil (`LinearPageShell.dark`) admin
/// panelleri bu sarmalayıcıyı kullanır; böylece Material bileşenleri ve
/// `adminAware*` yardımcıları aynı paleti görür.
class AdminDarkScope extends StatelessWidget {
  const AdminDarkScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme);
    return Theme(
      data: buildAdminDarkTheme(textTheme),
      child: child,
    );
  }
}
