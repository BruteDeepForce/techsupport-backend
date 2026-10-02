import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import './shared/admin_web_design.dart';

import '../../../core/utils/guid_generator.dart';
import '../../ai/data/ai_chat_service.dart';
import '../../ai/models/ai_chat_message.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';

class AdminWebAiChatPage extends StatefulWidget {
  const AdminWebAiChatPage({super.key});

  @override
  State<AdminWebAiChatPage> createState() => _AdminWebAiChatPageState();
}

class _AdminWebAiChatPageState extends State<AdminWebAiChatPage>
    with SingleTickerProviderStateMixin {
  /// Kelime başına hedef süre. Toplam süre yanıt uzunluğuna göre kırpılır.
  static const int _msPerWord = 120;
  static const int _minRevealMs = 2600;
  static const int _maxRevealMs = 16000;

  final AiChatService _service = AiChatService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<AiChatMessage> _messages = [];

  /// Frontend üretir. Sayfa kapanana kadar (yani yeni sohbet başlatılana
  /// kadar) her request/response döngüsünde aynı id ile gönderilir.
  String _conversationId = GuidGenerator.newGuid();

  bool _sending = false;

  /// Ticker ilk kullanıldığında oluşturulur. `late final` alan `dispose`
  /// içinde ilk erişimde yaratılabiliyor ve o sırada ağaç sökülmüş olduğu
  /// için TickerMode araması güvenli olmuyordu.
  Ticker? _revealTicker;

  String? _revealTargetId;
  int _revealedWords = 0;
  int _revealDurationMs = _minRevealMs;

  bool get _isRevealing => _revealTargetId != null;

  /// Ticker'ı ilk kullanımda oluşturur; sonraki çağrılar mevcut olanı döner.
  Ticker get _reveal => _revealTicker ??= createTicker(_onRevealTick);

  @override
  void dispose() {
    _revealTicker?.dispose();
    _revealTicker = null;
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String rawInput) async {
    final input = rawInput.trim();
    if (input.isEmpty || _sending) return;

    // Kullanıcı yazma sırasında yeni mesaj gönderirse mevcut yanıtı
    // anında tamamla, yeni sohbete geç.
    if (_isRevealing) _finishReveal();

    setState(() {
      _messages.add(AiChatMessage(
        role: AiChatRole.user,
        content: input,
        createdAt: DateTime.now(),
      ));
      _sending = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await _service.sendMessage(
        conversationId: _conversationId,
        input: input,
      );
      if (!mounted) return;
      final message = AiChatMessage(
        role: AiChatRole.assistant,
        content: reply,
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.add(message);
      });
      _startReveal(message);
    } on DioException catch (error) {
      if (!mounted) return;
      _markLastFailed(_resolveErrorMessage(error));
    } catch (error) {
      if (!mounted) return;
      _markLastFailed(error.toString());
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  void _markLastFailed(String message) {
    setState(() {
      _messages.add(AiChatMessage(
        role: AiChatRole.assistant,
        content: message,
        createdAt: DateTime.now(),
        isFailed: true,
      ));
    });
  }

  String _resolveErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Asistan yanıt vermedi. Lütfen tekrar deneyin.';
      case DioExceptionType.connectionError:
        return 'Sunucuya ulaşılamadı. Bağlantınızı kontrol edin.';
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status == 401 || status == 403) {
          return 'Bu ekrana erişim yetkiniz yok. Sadece adminler kullanabilir.';
        }
        return 'Asistan isteği başarısız oldu ($status).';
      default:
        return 'Beklenmeyen bir hata oluştu.';
    }
  }

  void _startNewConversation() {
    if (_sending) return;
    _reveal.stop();
    setState(() {
      _messages.clear();
      _revealTargetId = null;
      _revealedWords = 0;
      _conversationId = GuidGenerator.newGuid();
    });
    _focusNode.requestFocus();
  }

  /// Yanıtı kelime kelime ekrana yazar.
  void _startReveal(AiChatMessage message) {
    _reveal.stop();
    setState(() {
      _revealTargetId = message.id;
      _revealedWords = 0;
      _revealDurationMs =
          (_wordCount(message.content) * _msPerWord).clamp(_minRevealMs, _maxRevealMs);
    });

    if (message.content.isEmpty) {
      _finishReveal();
      return;
    }
    _reveal.start();
  }

  void _onRevealTick(Duration elapsed) {
    final target = _revealingMessage;
    if (target == null) {
      _reveal.stop();
      return;
    }

    final total = _wordCount(target.content);
    if (total == 0) {
      _finishReveal();
      return;
    }

    final progress =
        (elapsed.inMilliseconds / _revealDurationMs).clamp(0.0, 1.0);
    final words = (total * progress).floor();

    if (words >= total) {
      _finishReveal();
      return;
    }

    setState(() => _revealedWords = words);
    _scrollToBottom(animate: false);
  }

  /// Yazma animasyonunu anında tamamlar (balona dokununca).
  void _finishReveal() {
    _reveal.stop();
    if (_revealTargetId == null) return;
    setState(() {
      _revealedWords = _wordCount(_revealingMessage?.content ?? '');
      _revealTargetId = null;
    });
    _scrollToBottom();
  }

  AiChatMessage? get _revealingMessage {
    final id = _revealTargetId;
    if (id == null) return null;
    for (final message in _messages) {
      if (message.id == id) return message;
    }
    return null;
  }

  static final RegExp _wordPattern = RegExp(r'\S+');

  static int _wordCount(String text) => _wordPattern.allMatches(text).length;

  /// Yazılırken balonda gösterilecek metin.
  ///
  /// Kısmi kelime gösterilmez; metin her zaman bir kelimenin bittiği
  /// yerde kesilir.
  String _visibleText(AiChatMessage message) {
    if (message.id != _revealTargetId || message.isFailed) {
      return message.content;
    }

    final matches = _wordPattern.allMatches(message.content).toList();
    if (matches.isEmpty || _revealedWords <= 0) return '';

    final index = _revealedWords.clamp(0, matches.length) - 1;
    return message.content.substring(0, matches[index].end);
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (!animate) {
        _scrollController.jumpTo(target);
        return;
      }
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  void _copyMessage(AiChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yanıt kopyalandı'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      dark: true,
      active: AdminNavKey.aiChat,
      scrollable: false,
      actions: [
        if (_messages.isNotEmpty)
          AdminWebActionButton(
            label: 'Yeni Sohbet',
            icon: Icons.add_comment_outlined,
            onPressed: _sending || _isRevealing ? () {} : _startNewConversation,
          ),
      ],
      body: Column(
        children: [
          const _Breadcrumb(),
          Expanded(
            child: _messages.isEmpty
                ? const _EmptyState()
                : _MessageList(
                    messages: _messages,
                    sending: _sending,
                    revealTargetId: _revealTargetId,
                    textBuilder: _visibleText,
                    scrollController: _scrollController,
                    onCopy: _copyMessage,
                    onRetry: (message) => _retry(message),
                    onSkipReveal: _finishReveal,
                  ),
          ),
          _Composer(
            controller: _controller,
            focusNode: _focusNode,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  void _retry(AiChatMessage message) {
    // Başarısız yanıtı kaldırıp aynı soruyu tekrar gönderiyoruz.
    final failedIndex = _messages.lastIndexOf(message);
    String? input;
    if (failedIndex > 0) {
      final previous = _messages[failedIndex - 1];
      if (previous.role == AiChatRole.user) input = previous.content;
    }
    setState(() {
      _messages.removeWhere((m) => m.isFailed);
    });
    if (input != null) {
      _send(input);
    }
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Text('Yönetim',
              style:
                  TextStyle(fontSize: 12, color: AdminTechColors.textTertiary)),
          SizedBox(width: 6),
          Icon(Icons.chevron_right,
              size: 14, color: AdminTechColors.textTertiary),
          SizedBox(width: 6),
          Text('AI Asistan',
              style: TextStyle(
                  fontSize: 12, color: AdminTechColors.textSecondary)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const List<_Suggestion> _suggestions = [
    _Suggestion(
      icon: Icons.inventory_2_outlined,
      iconColor: AdminTechColors.indigo,
      iconBg: AdminTechColors.surfaceAlt,
      title: 'Stok durumu',
      subtitle: 'Kritik seviyedeki ürünleri ve mevcut miktarları göster',
      prompt: 'Stokta kritik seviyeye düşen ürünler var mı?',
    ),
    _Suggestion(
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AdminTechColors.green,
      iconBg: AdminTechColors.surfaceAlt,
      title: 'Muhasebe özeti',
      subtitle: 'Toplam alacak, vadesi geçen faturalar ve tahsilat durumu',
      prompt: 'Muhasebe özetini ve vadesi geçen faturaları göster.',
    ),
    _Suggestion(
      icon: Icons.receipt_long_outlined,
      iconColor: AdminTechColors.statusBlue,
      iconBg: AdminTechColors.surfaceAlt,
      title: 'Operasyon analizi',
      subtitle: 'Son 30 günün operasyonlarını durumlarına göre incele',
      prompt: 'Son 30 günün operasyonlarını durumlarına göre özetle.',
    ),
    _Suggestion(
      icon: Icons.group_outlined,
      iconColor: AdminTechColors.orange,
      iconBg: AdminTechColors.surfaceAlt,
      title: 'Teknisyen performansı',
      subtitle: 'Uzmanlık alanları ve iş emirlerini listele',
      prompt: 'Teknisyenleri ve uzmanlık alanlarını listele.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final twoColumns = width >= 820;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          children: [
            const SizedBox(height: 48),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AdminTechColors.indigo, AdminTechColors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _AiChatColors.accent.withValues(alpha: 0.32),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 18),
            const Text(
              'Lineer-AI Asistan',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: _AiChatColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Teknik Operasyonlarınızı Üst Düzey Yapay Zeka Ajanlar İle Yönetin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AdminTechColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 22),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
            ),
            const SizedBox(height: 26),
            GridView.count(
              crossAxisCount: twoColumns ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: twoColumns ? 4.6 : 7,
              children: [
                for (final suggestion in _suggestions)
                  _SuggestionCard(suggestion: suggestion),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _Suggestion {
  const _Suggestion({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.prompt,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String prompt;
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion});

  final _Suggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminTechColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          final state =
              context.findAncestorStateOfType<_AdminWebAiChatPageState>();
          state?._send(suggestion.prompt);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _AiChatColors.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: suggestion.iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(suggestion.icon,
                    color: suggestion.iconColor, size: 17),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      suggestion.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _AiChatColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      suggestion.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: _AiChatColors.textTertiary,
                        height: 1.5,
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AdminTechColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _AiChatColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12.5, color: AdminTechColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.sending,
    required this.revealTargetId,
    required this.textBuilder,
    required this.scrollController,
    required this.onCopy,
    required this.onRetry,
    required this.onSkipReveal,
  });

  final List<AiChatMessage> messages;
  final bool sending;
  final String? revealTargetId;
  final String Function(AiChatMessage) textBuilder;
  final ScrollController scrollController;
  final ValueChanged<AiChatMessage> onCopy;
  final ValueChanged<AiChatMessage> onRetry;
  final VoidCallback onSkipReveal;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
      itemCount: messages.length + (sending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          return const _ThinkingBubble();
        }
        final message = messages[index];
        if (message.role == AiChatRole.user) {
          return _UserBubble(message: message);
        }
        return _AssistantBubble(
          message: message,
          text: textBuilder(message),
          isRevealing: message.id == revealTargetId,
          onCopy: () => onCopy(message),
          onRetry: () => onRetry(message),
          onSkipReveal: onSkipReveal,
        );
      },
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _AiChatColors.accent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _AiChatColors.accent.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message.timeLabel,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: _AiChatColors.textTertiary,
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

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({
    required this.message,
    required this.text,
    required this.isRevealing,
    required this.onCopy,
    required this.onRetry,
    required this.onSkipReveal,
  });

  final AiChatMessage message;

  /// Şu an ekranda görünen kısım (yazma animasyonu sırasında kısa olur).
  final String text;

  /// Yanıt hâlâ harf harf yazılıyorsa true.
  final bool isRevealing;

  final VoidCallback onCopy;
  final VoidCallback onRetry;
  final VoidCallback onSkipReveal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AiAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: isRevealing ? onSkipReveal : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: AdminTechColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      border: Border.all(color: _AiChatColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: message.isFailed
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AdminTechColors.statusRed, size: 16),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  message.content,
                                  style: const TextStyle(
                                    color: AdminTechColors.statusRed,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: onRetry,
                                child: const Text(
                                  'Tekrar dene',
                                  style: TextStyle(
                                    color: _AiChatColors.accent,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _AnimatedText(
                            text: text,
                            isRevealing: isRevealing,
                          ),
                  ),
                ),
                if (!message.isFailed && !isRevealing)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 2),
                    child: Row(
                      children: [
                        Text(
                          message.timeLabel,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: _AiChatColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: onCopy,
                          child: const Row(
                            children: [
                              Icon(Icons.copy_rounded,
                                  size: 12, color: _AiChatColors.textTertiary),
                              SizedBox(width: 4),
                              Text(
                                'Kopyala',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: _AiChatColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isRevealing)
                  const Padding(
                    padding: EdgeInsets.only(top: 6, left: 2),
                    child: Text(
                      'Yazıyor · dokunarak hızlandır',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: _AiChatColors.textTertiary,
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

/// Yazma sırasında yanıp sönen imleç.
class _AnimatedText extends StatefulWidget {
  const _AnimatedText({required this.text, required this.isRevealing});

  final String text;
  final bool isRevealing;

  @override
  State<_AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<_AnimatedText>
    with SingleTickerProviderStateMixin {
  /// AI yanıtındaki S3 ve diğer bağlantıları yakalar.
  static final RegExp _urlPattern = RegExp(
    r'(?:https?://|www\.)[^\s<>"''“”]+',
    caseSensitive: false,
  );

  /// Cümle sonundaki noktalama bağlantının parçası değildir.
  static const String _trailingPunctuation = '.,;:!?)]}»”\'…';

  late final AnimationController _caret;

  /// Her derlemede yeniden üretilir; [dispose] ile serbest bırakılır.
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _caret = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isRevealing && _caret.isAnimating) {
      _caret.stop();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    _caret.dispose();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  /// Metni bağlantı olan ve olmayan parçalara ayırır. Bağlantılar
  /// tıklanabilir ve altı çizili olur; kalan metin normal görünür.
  List<InlineSpan> _buildLinkSpans(String text, TextStyle base) {
    _disposeRecognizers();

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in _urlPattern.allMatches(text)) {
      var url = match.group(0)!;
      var consumedTo = match.end;

      while (url.isNotEmpty && _trailingPunctuation.contains(url[url.length - 1])) {
        url = url.substring(0, url.length - 1);
        consumedTo -= 1;
      }

      if (url.isEmpty) continue;

      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }

      final recognizer = TapGestureRecognizer()
        ..onTap = () => _openExternally(url);
      _recognizers.add(recognizer);

      spans.add(TextSpan(
        text: url,
        recognizer: recognizer,
        style: const TextStyle(
          color: _AiChatColors.link,
          decoration: TextDecoration.underline,
          decorationColor: _AiChatColors.link,
        ),
      ));

      cursor = consumedTo;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return spans;
  }

  Future<void> _openExternally(String raw) async {
    final uri = Uri.tryParse(
      raw.toLowerCase().startsWith('www.') ? 'https://$raw' : raw,
    );
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bağlantı açılamadı: $raw')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      color: AdminTechColors.textPrimary,
      fontSize: 13.5,
      height: 1.65,
    );

    return SelectableText.rich(
      TextSpan(
        style: base,
        children: [
          ..._buildLinkSpans(widget.text, base),
          if (widget.isRevealing)
            TextSpan(
              text: '▍',
              style: TextStyle(
                color: _AiChatColors.accent.withValues(
                  alpha: 0.35 + (_caret.value * 0.65),
                ),
                fontSize: 13.5,
                height: 1.65,
              ),
            ),
        ],
      ),
      cursorColor: _AiChatColors.accent,
      selectionColor: _AiChatColors.accent.withValues(alpha: 0.28),
    );
  }
}

/// Yanıt gelene kadar hareket eden balon.
///
/// Mobil paneldekiyle aynı: döner halka, nefes alan kenar ve sırayla
/// yükselen noktalar. Sürekli döngüde olduğu için cevap gelene kadar
/// "canlı" görünür.
class _ThinkingBubble extends StatefulWidget {
  const _ThinkingBubble();

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AiAvatar(),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _loop,
            builder: (context, _) {
              final t = _loop.value;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AdminTechColors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border: Border.all(
                    color: Color.lerp(
                      AdminTechColors.borderSubtle,
                      AdminTechColors.cyan,
                      t,
                    )!,
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AdminTechColors.cyan
                          .withValues(alpha: 0.10 + 0.14 * t),
                      blurRadius: 10 + 10 * t,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dönen "düşünüyor" halkası.
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        value: t,
                        backgroundColor: AdminTechColors.borderSubtle
                            .withValues(alpha: 0.5),
                        valueColor:
                            AlwaysStoppedAnimation(AdminTechColors.cyan),
                      ),
                    ),
                    const SizedBox(width: 10),
                    for (var i = 0; i < 3; i++) _Dot(phase: t, index: i),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Sırayla yükselip alçalkan nokta.
class _Dot extends StatelessWidget {
  const _Dot({required this.phase, required this.index});

  final double phase;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Her nokta döngü içinde kendi penceresine sahip; böylece sırayla
    // hareket ediyormuş gibi görünürler.
    final offset = (phase * 3 - index).clamp(-1.0, 2.0);
    final wave = offset < 0 ? 0.0 : (offset > 1 ? 1.0 : offset);

    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Transform.translate(
        offset: Offset(0, -3.5 * wave),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Color.lerp(
              AdminTechColors.textTertiary,
              AdminTechColors.cyan,
              wave,
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  const _AiAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_AiChatColors.accent, _AiChatColors.accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: _AiChatColors.accent.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final ValueChanged<String> onSend;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _submit() {
    if (_hasText && !widget.sending) {
      widget.onSend(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _hasText && !widget.sending;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              decoration: BoxDecoration(
                color: AdminTechColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _AiChatColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    // SingleActivator (shift/ctrl/alt/meta yok) sadece düz
                    // Enter'a karşılık gelir; Shift+Enter satır atlamaya devam eder.
                    child: CallbackShortcuts(
                      bindings: <ShortcutActivator, VoidCallback>{
                        const SingleActivator(LogicalKeyboardKey.enter):
                            _submit,
                        const SingleActivator(LogicalKeyboardKey.numpadEnter):
                            _submit,
                      },
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        enabled: !widget.sending,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: _AiChatColors.textPrimary,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText:
                              'Stok, muhasebe, operasyon veya ekip hakkında sorun...',
                          hintStyle: TextStyle(
                            color: _AiChatColors.textTertiary,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SendButton(
                    enabled: canSend,
                    sending: widget.sending,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Enter gönderir · Shift+Enter satır atlar',
            style: TextStyle(
              fontSize: 11,
              color: _AiChatColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.enabled,
    required this.sending,
    required this.onPressed,
  });

  final bool enabled;
  final bool sending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: _AiChatColors.accent,
        borderRadius: BorderRadius.circular(10),
        elevation: enabled ? 3 : 0,
        shadowColor: _AiChatColors.accent.withValues(alpha: 0.4),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: 36,
            height: 36,
            child: sending
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

abstract class _AiChatColors {
  static const accent = AdminTechColors.indigo;
  static const accentDark = AdminTechColors.indigo;
  static const border = AdminTechColors.border;
  static const textPrimary = AdminTechColors.textPrimary;
  static const textTertiary = AdminTechColors.textTertiary;
  static const link = AdminTechColors.cyan;
}
