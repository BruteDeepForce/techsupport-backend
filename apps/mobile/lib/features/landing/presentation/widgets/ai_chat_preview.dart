import 'package:flutter/material.dart';

import '../../../../core/design/app_design.dart';

/// Tek bir AI sohbet önizleme kartı.
class AIChatPreviewCard extends StatelessWidget {
  const AIChatPreviewCard(
      {super.key, required this.title, required this.messages});

  /// Kart üstünde gösterilen senaryo başlığı (ör. "Teknisyen performansı").
  final String title;

  /// (soru, cevap, kullanıcıdan mı) üçlüleri.
  final List<(String, String, bool)> messages;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 700;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.07),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lineer AI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.statusGreenBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isCompact ? 'Kurumsal veri' : 'Kurumsal verinize bağlı',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < messages.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: i == messages.length - 1 ? 0 : 12),
                    child: _MessageBubble(
                      question: messages[i].$1,
                      answer: messages[i].$2,
                      fromUser: messages[i].$3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isCompact
                        ? 'Lineer AI\'ya bir soru yazın...'
                        : 'Lineer AI\'ya bir soru yazın: örn. "geciken işlerim neler?"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.question,
    required this.answer,
    required this.fromUser,
  });

  final String question;
  final String answer;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: fromUser ? AppColors.accentBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: fromUser
                ? AppColors.accent.withValues(alpha: 0.2)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sayfa kaydırıldıkça kartların alt alta yığılarak değiştiği önizleme.
///
/// Aktif kart yukarı çıkarken sıradaki kart alttan gelir. Bölüm, tüm kartlar
/// gösterilene kadar ekranda sabit (sticky) kalır: her kaydırma adımında bir
/// kart değişir, son kart göründükten sonra bölüm normal akışta aşağı çıkar.
class AIChatPreviewStack extends StatefulWidget {
  const AIChatPreviewStack({
    super.key,
    required this.scrollController,
    required this.cards,
  });

  final ScrollController scrollController;
  final List<AIChatPreviewCard> cards;

  @override
  State<AIChatPreviewStack> createState() => _AIChatPreviewStackState();
}

class _AIChatPreviewStackState extends State<AIChatPreviewStack> {
  final GlobalKey _anchorKey = GlobalKey();

  /// Bölümün ekrana sabitlendiği mesafe (0..stickyTravel).
  double _stickyOffset = 0;

  /// Sticky kilidin başladığı scroll offset (liste koordinatında).
  double? _lockStartScrollOffset;

  /// Her kart değişimi için ayrılan kaydırma mesafesi.
  static const double _stepDistance = 120;

  /// Sabitlenen konum; sayfanın üstteki sabit app bar yüksekliği kadar,
  /// böylece kart başlık çubuğunun altında kalır.
  /// UX: kilidi biraz daha aşağıdan başlatmak için eşik yükseltildi.
  static const double _stickyTop = 350;

  double get _stickyTravel {
    final count = widget.cards.length;
    return count < 2 ? 0 : (count - 1) * _stepDistance;
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(AIChatPreviewStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final context = _anchorKey.currentContext;
    final box = context?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !widget.scrollController.hasClients) {
      return;
    }

    final travel = _stickyTravel;
    if (travel <= 0) return;

    final scrollOffset = widget.scrollController.offset;
    final sectionTop = box.localToGlobal(Offset.zero).dy;

    if (sectionTop > _stickyTop) {
      if (_stickyOffset == 0 && _lockStartScrollOffset == null) return;
      setState(() {
        _stickyOffset = 0;
        _lockStartScrollOffset = null;
      });
      return;
    }

    _lockStartScrollOffset ??= scrollOffset - (_stickyTop - sectionTop);
    final offset = (scrollOffset - _lockStartScrollOffset!).clamp(0.0, travel);

    if ((offset - _stickyOffset).abs() < 0.5) return;
    setState(() => _stickyOffset = offset);
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    if (cards.isEmpty) return const SizedBox.shrink();
    final cardCount = cards.length;

    // Sert geçiş: kart yalnızca tam adım tamamlandığında değişir.
    final position = _stepDistance <= 0
        ? 0.0
        : (_stickyOffset / _stepDistance).floorToDouble();
    final activeIndex = position.clamp(0.0, (cardCount - 1).toDouble()).toInt();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        // Sabitleme sırasında kartlar yerinde durur; Column'un altındaki boş
        // alan (stickyTravel) kaydırma rezervi sağlar.
        child: Column(
          key: _anchorKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, _stickyOffset),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Kartların yükseklikleri farklı olabildiği için,
                      // hepsini görünmez olarak ölçüye katıyoruz. Böylece
                      // alttaki içerik (domain kartları) zıplamaz.
                      for (var i = 0; i < cardCount; i++)
                        IgnorePointer(
                          child: Opacity(
                            opacity: 0,
                            child: _buildCard(index: i, width: width),
                          ),
                        ),
                      _buildCard(index: activeIndex, width: width),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: _stickyTravel),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required int index,
    required double width,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: width,
        child: widget.cards[index],
      ),
    );
  }
}
