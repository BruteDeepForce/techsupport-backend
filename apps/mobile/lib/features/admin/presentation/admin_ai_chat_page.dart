import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/admin_design.dart';
import '../../../core/design/app_design.dart';
import '../../../core/utils/guid_generator.dart';
import '../../ai/data/ai_chat_service.dart';

class AdminAIChatPage extends StatefulWidget {
  const AdminAIChatPage({super.key});

  @override
  State<AdminAIChatPage> createState() => _AdminAIChatPageState();
}

class _AdminAIChatPageState extends State<AdminAIChatPage>
    with SingleTickerProviderStateMixin {
  /// Kelime başına hedef süre. Toplam süre yanıt uzunluğuna göre kırpılır.
  static const int _msPerWord = 120;
  static const int _minRevealMs = 2600;
  static const int _maxRevealMs = 16000;

  final AiChatService _service = AiChatService();

  /// Backend bu id ile konuşma geçmişini tutar; sayfa açık kaldığı
  /// sürece aynı değer gönderilir.
  final String _conversationId = GuidGenerator.newGuid();

  final List<_ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  /// Ticker ilk kullanımda oluşturulur; `late final` alan `dispose`
  /// sırasında ağaç sökülmüşken TickerMode arayabiliyordu.
  Ticker? _revealTicker;

  /// Yazma animasyonu süren mesajın id'si.
  String? _revealTargetId;
  int _revealedWords = 0;
  int _revealDurationMs = _minRevealMs;

  bool get _isRevealing => _revealTargetId != null;

  Ticker get _reveal => _revealTicker ??= createTicker(_onRevealTick);

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        id: '0',
        text:
            'Merhaba! Ben AI İş Asistanınız. Firmayla ilgili her şeyi sorabilirsiniz: stok durumu, ekip verimliliği, müşteri analizleri veya teknisyen atamaları.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _revealTicker?.dispose();
    _revealTicker = null;
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty || _isTyping) return;

    // Kullanıcı yazma sırasında yeni mesaj gönderirse mevcut yanıtı
    // anında tamamla.
    if (_isRevealing) _finishReveal();

    setState(() {
      _messages.add(_ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    _ask(text.trim());
  }

  Future<void> _ask(String input) async {
    try {
      final reply = await _service.sendMessage(
        conversationId: _conversationId,
        input: input,
      );
      if (!mounted) return;
      final message = _ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(message);
        _isTyping = false;
      });
      _startReveal(message);
    } on AiChatException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: e.message,
          isUser: false,
          timestamp: DateTime.now(),
          isFailed: true,
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Asistan yanıt veremedi. Bağlantınızı kontrol edin.',
          isUser: false,
          timestamp: DateTime.now(),
          isFailed: true,
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  /// Yanıtı kelime kelime ekrana yazar.
  void _startReveal(_ChatMessage message) {
    _reveal.stop();
    setState(() {
      _revealTargetId = message.id;
      _revealedWords = 0;
      _revealDurationMs = (_wordCount(message.text) * _msPerWord)
          .clamp(_minRevealMs, _maxRevealMs);
    });

    if (message.text.trim().isEmpty) {
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

    final total = _wordCount(target.text);
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
    // Her karede yumuşatma animasyonu başlatmak birbirini kesiyor;
    // yazma sırasında anında kaydırılır.
    _scrollToBottom(animate: false);
  }

  /// Yazma animasyonunu anında tamamlar (balona dokununca).
  void _finishReveal() {
    _reveal.stop();
    if (_revealTargetId == null) return;
    setState(() {
      _revealedWords = _wordCount(_revealingMessage?.text ?? '');
      _revealTargetId = null;
    });
    _scrollToBottom();
  }

  _ChatMessage? get _revealingMessage {
    final id = _revealTargetId;
    if (id == null) return null;
    for (final message in _messages) {
      if (message.id == id) return message;
    }
    return null;
  }

  static final RegExp _wordPattern = RegExp(r'\S+');

  static int _wordCount(String text) => _wordPattern.allMatches(text).length;

  /// [wordCount] kelimenin bittiği yere kadar metni keser; kısmi
  /// kelime gösterilmez.
  static String _textUpToWord(String text, int wordCount) {
    if (wordCount <= 0) return '';
    final matches = _wordPattern.allMatches(text).toList();
    if (matches.isEmpty) return '';
    final index = wordCount.clamp(0, matches.length) - 1;
    return text.substring(0, matches[index].end);
  }

  /// Hatalı yanıtın altındaki "Tekrar dene" bağlantısı.
  void _retry(_ChatMessage failed) {
    final index = _messages.indexWhere((m) => m.id == failed.id);
    final previous = index > 0 ? _messages[index - 1].text : null;
    setState(() => _messages.removeWhere((m) => m.id == failed.id));
    if (previous == null) return;
    setState(() => _isTyping = true);
    _ask(previous);
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Material(
            color: AdminTechColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AdminTechColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hızlı Sorular',
                    style: TextStyle(
                      color: AdminTechColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _QuickChip('Stok durumu nedir?', _sendMessage),
                      _QuickChip('En iyi teknisyen kim?', _sendMessage),
                      _QuickChip('Müşteri analizleri', _sendMessage),
                      _QuickChip('Aylık raporu göster', _sendMessage),
                      _QuickChip('Kritik arızalar var mı?', _sendMessage),
                      _QuickChip('Yeni gelen talepler', _sendMessage),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminDarkScope(
      child: Builder(builder: (context) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: AdminTechColors.canvas,
            body: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AdminTechColors.canvas,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                  top: 16, bottom: 100, left: 8, right: 8),
                              itemCount: _messages.length + (_isTyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _messages.length && _isTyping) {
                                  return const _TypingIndicator();
                                }
                                final msg = _messages[index];
                                return _buildMessage(msg);
                              },
                            ),
                          ),
                          _buildInputArea(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Teknolojik koyu başlık: degrade zemin, ızgara çizgileri ve
  /// canlı durum noktası.
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2A6B), Color(0xFF101A3D)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AdminTechColors.primary, AdminTechColors.cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                      'AI Asistan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF34D399),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isTyping ? 'Düşünüyor...' : 'Çevrimiçi',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: isUser ? _buildUserMessage(message) : _buildAIMessage(message),
      ),
    );
  }

  Widget _buildUserMessage(_ChatMessage message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 0, 92, 138),
            const Color.fromARGB(255, 21, 189, 214)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          topRight: Radius.circular(AppRadius.md),
          bottomLeft: Radius.circular(AppRadius.md),
          bottomRight: const Radius.circular(4),
        ),
      ),
      child: Text(
        message.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAIMessage(_ChatMessage message) {
    final isRevealing = message.id == _revealTargetId;

    // Yazma sırasında balon yalnızca o ana kadar gelen kelimeleri gösterir.
    final visible = isRevealing
        ? _textUpToWord(message.text, _revealedWords)
        : message.text;

    return GestureDetector(
      onTap: isRevealing ? _finishReveal : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AdminTechColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.md),
            topRight: Radius.circular(AppRadius.md),
            bottomRight: Radius.circular(AppRadius.md),
            bottomLeft: const Radius.circular(4),
          ),
          border: Border.all(color: AdminTechColors.borderSubtle, width: 0.5),
        ),
        child: message.isFailed
            ? _buildFailedMessage(message)
            : _AssistantRichText(visible, isRevealing: isRevealing),
      ),
    );
  }

  Widget _buildFailedMessage(_ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline,
                color: AdminTechColors.statusRed, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.text,
                style: const TextStyle(
                  color: AdminTechColors.statusRed,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _retry(message),
          child: const Text(
            'Tekrar dene',
            style: TextStyle(
              color: AdminTechColors.cyan,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    final hasText = _textController.text.trim().isNotEmpty;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        left: 12,
        right: 12,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: AdminTechColors.surface,
        border: Border(
          top: BorderSide(color: AdminTechColors.borderSubtle, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AdminTechColors.cyanBg,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.auto_awesome,
                  color: AdminTechColors.primary, size: 22),
              onPressed: _showQuickActions,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AdminTechColors.surfaceRaised.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color: AdminTechColors.borderSubtle, width: 0.5),
                  ),
                  child: TextField(
                    controller: _textController,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (v) {
                      if (hasText && !_isTyping) _sendMessage(v);
                    },
                    maxLines: 4,
                    minLines: 1,
                    style: const TextStyle(
                      color: AdminTechColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'AI Asistan\'a sorun...',
                      hintStyle: TextStyle(
                        color:
                            AdminTechColors.textTertiary.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasText && !_isTyping
                  ? LinearGradient(
                      colors: [AdminTechColors.primary, AdminTechColors.cyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: (hasText && !_isTyping)
                  ? null
                  : AdminTechColors.surfaceRaised.withValues(alpha: 0.5),
            ),
            child: IconButton(
              icon: _isTyping
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AdminTechColors.primary,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: hasText && !_isTyping
                          ? Colors.white
                          : AdminTechColors.textTertiary,
                      size: 20,
                    ),
              onPressed: (hasText && !_isTyping) ? _handleSend : null,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    _sendMessage(_textController.text);
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isFailed = false,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  /// Mesaj gönderildi ancak yanıt alınamadıysa true olur.
  final bool isFailed;
}

/// Asistan yanıtını `SelectableText.rich` için span ağacına çevirir.
///
/// Web panelindeki davranışla aynı: `**kalın**` kalınlaştırılır, satır
/// başındaki `•` madde işareti olur ve bağlantılar tıklanabilir hâle
/// gelir. Bağlantılar tarayıcıda açılır.
class _AssistantRichText extends StatefulWidget {
  const _AssistantRichText(this.text, {required this.isRevealing});

  final String text;

  /// Yanıt hâlâ yazılıyorsa yanıp sönen imleç gösterilir.
  final bool isRevealing;

  @override
  State<_AssistantRichText> createState() => _AssistantRichTextState();
}

class _AssistantRichTextState extends State<_AssistantRichText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _caret = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  static final RegExp _urlPattern = RegExp(
    r'(?:https?://|www\.)[^\s<>"' '""]+',
    caseSensitive: false,
  );

  /// Cümle sonu noktalama bağlantının parçası değildir.
  static const String _trailingPunctuation = '.,;:!?)]}»""\'';

  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    if (widget.isRevealing) _caret.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AssistantRichText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealing && !_caret.isAnimating) {
      _caret.repeat(reverse: true);
    } else if (!widget.isRevealing && _caret.isAnimating) {
      _caret.stop();
    }
  }

  @override
  void dispose() {
    _caret.dispose();
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
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
    // `AnimatedBuilder` bir Widget döndürdüğü için span ağacının *içine*
    // konulamaz; bu yüzden tüm metin imleç için her karede kurulur.
    return AnimatedBuilder(
      animation: _caret,
      builder: (context, _) => SelectableText.rich(
        _compose(context),
        cursorColor: AdminTechColors.cyan,
        selectionColor: AdminTechColors.cyan.withValues(alpha: 0.25),
      ),
    );
  }

  /// Satırları ve satır içi biçimleri tek bir span ağacına döker.
  TextSpan _compose(BuildContext context) {
    _disposeRecognizers();

    final children = <InlineSpan>[];

    final lines = widget.text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      children.addAll(_lineSpans(lines[i], isFirst: i == 0));
    }

    if (widget.isRevealing) {
      children.add(TextSpan(
        text: '\u258d',
        style: TextStyle(
          color: AdminTechColors.cyan
              .withValues(alpha: 0.35 + (_caret.value * 0.65)),
          fontSize: 13.5,
          height: 1.55,
        ),
      ));
    }

    return TextSpan(
      style: const TextStyle(
        color: AdminTechColors.textSecondary,
        fontSize: 13.5,
        height: 1.55,
      ),
      children: children,
    );
  }

  List<InlineSpan> _lineSpans(String line, {required bool isFirst}) {
    const base = TextStyle(
      color: AdminTechColors.textSecondary,
      fontSize: 13.5,
      height: 1.55,
    );

    final spans = <InlineSpan>[];

    if (!isFirst) {
      // Satır sonu ve boş satırlar arası nefes payı.
      spans.add(const TextSpan(text: '\n', style: base));
    }

    final trimmed = line.trimLeft();
    if (trimmed.isEmpty) {
      spans.add(const TextSpan(text: '\n', style: base));
      return spans;
    }

    var body = line;
    TextStyle lineStyle = base;

    if (trimmed.startsWith('•') || trimmed.startsWith('-')) {
      final indent = line.length - trimmed.length;
      spans.add(TextSpan(
          text: '${' ' * indent}•  ',
          style: base.copyWith(color: AdminTechColors.primary)));
      body = trimmed.substring(1);
    } else if (trimmed.startsWith('#')) {
      lineStyle = base.copyWith(
        color: AdminTechColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );
      body = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
    }

    spans.addAll(_inlineSpans(body, lineStyle));
    return spans;
  }

  /// Satır içindeki `**kalın**` ve bağlantıları işler.
  List<InlineSpan> _inlineSpans(String text, TextStyle style) {
    final spans = <InlineSpan>[];
    final bold = RegExp(r'\*\*(.+?)\*\*');

    var cursor = 0;

    for (final match in bold.allMatches(text)) {
      if (match.start > cursor) {
        spans.addAll(_linkSpans(text.substring(cursor, match.start), style));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: style.copyWith(
          color: AdminTechColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ));
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.addAll(_linkSpans(text.substring(cursor), style));
    }

    return spans;
  }

  List<InlineSpan> _linkSpans(String text, TextStyle style) {
    final spans = <InlineSpan>[];

    if (text.isEmpty) return spans;

    var cursor = 0;

    for (final match in _urlPattern.allMatches(text)) {
      var url = match.group(0)!;
      var consumedTo = match.end;

      while (url.isNotEmpty &&
          _trailingPunctuation.contains(url[url.length - 1])) {
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
        style: style.copyWith(
          color: AdminTechColors.cyan,
          decoration: TextDecoration.underline,
          decorationColor: AdminTechColors.cyan,
        ),
      ));

      cursor = consumedTo;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return spans;
  }
}

/// Yanıt gelene kadar hareket eden balon.
///
/// Üç parça birlikte çalışır: kenarı dolaşan ışık, nefes alan yüzey ve
/// sırayla yükselen noktalar. Sürekli döngüde olduğu için cevap
/// gelene kadar "canlı" görünür.
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
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
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, _) {
          final t = _loop.value;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AdminTechColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.md),
                topRight: const Radius.circular(AppRadius.md),
                bottomRight: const Radius.circular(AppRadius.md),
                bottomLeft: const Radius.circular(4),
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
                  color:
                      AdminTechColors.cyan.withValues(alpha: 0.10 + 0.14 * t),
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
                    backgroundColor:
                        AdminTechColors.borderSubtle.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation(AdminTechColors.cyan),
                  ),
                ),
                const SizedBox(width: 10),
                for (var i = 0; i < 3; i++) _Dot(phase: t, index: i),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Sırayla yükselip alçalan nokta.
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

extension on Widget {
  Widget animate(int delay) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, -2 * (1 - value)),
            child: child,
          ),
        ),
      );
}

class _QuickChip extends StatelessWidget {
  const _QuickChip(this.label, this.onTap);

  final String label;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AdminTechColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AdminTechColors.borderSubtle, width: 0.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AdminTechColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Başlıktaki ince ızgara dokusu; teknolojik his verir.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
