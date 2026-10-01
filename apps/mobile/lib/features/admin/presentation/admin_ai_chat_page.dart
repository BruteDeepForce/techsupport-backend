import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/admin_design.dart';
import '../../../core/design/app_design.dart';

class AdminAIChatPage extends StatefulWidget {
  const AdminAIChatPage({super.key});

  @override
  State<AdminAIChatPage> createState() => _AdminAIChatPageState();
}

class _AdminAIChatPageState extends State<AdminAIChatPage> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

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
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

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

    Future.delayed(const Duration(milliseconds: 1200), () {
      final response = _getAIResponse(text.trim());
      setState(() {
        _messages.add(_ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _getAIResponse(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('stok') || lower.contains('parça')) {
      return '📊 **Stok Durumu Raporu**\n\n'
          'Toplam stok: 1.247 adet\n'
          'Kritik seviye: 23 parça (4 farklı ürün)\n'
          'Rezerve edilmiş: 89 adet\n\n'
          'En düşük stokta olanlar:\n'
          '• USB-C Kablo (3 adet)\n'
          '• HDMI Kartı (2 adet)\n'
          '• SSD 1TB (5 adet)\n\n'
          'Bu parçlar için otomatik yeniden sipariş önerisinde bulunmamı ister misiniz?';
    }
    if (lower.contains('teknisyen') || lower.contains('atama')) {
      return '👷 **Uzman Teknisyen Analizi**\n\n'
          'Aktif teknisyenler: 8\n'
          'Ortalama iş başına aylık: 12.4 tamamlanmış\n\n'
          'Önerilen atama: **Mehmet Kaya** \n'
          'Neden? • 4 yıl deneyim • Ağırlıklık: Donanım • Güncel iş yükü en düşük\n\n'
          'Alternatif: Ayşe Yılmaz (2.5 yıl, Donanım, ort. yük: 11)';
    }
    if (lower.contains('müşteri') || lower.contains('analiz')) {
      return '👥 **Müşteri Analizi**\n\n'
          'Toplam müşteri: 342\n'
          'Aktif (30g): 127\n'
          'Satisf. puanı: 4.7/5\n\n'
          'Bu ay 3 müşteri çok memnuniyetsiz (tekrarlayan şikayetler).\n'
          'İlgili talepler: #TS-102, #TS-245, #TS-301\n\n'
          'Detaylı raporu görüntülemek ister misiniz?';
    }
    if (lower.contains('rapor') || lower.contains('özet')) {
      return '📈 **Aylık Operasyon Raporu**\n\n'
          'Haziran 2026\n'
          '• Toplam tamamlanan: 156\n'
          '• Ortalama süre: 2.3 gün\n'
          '• Çözüm oranı: 97.4%\n'
          '• Kritik arızalar: 12\n'
          '• Tekrar gelenler: 3\n\n'
          'Geçen aya göre %8.2 iyileşme sağlandı.';
    }
    return '🤖 AI Asistanınız burada. Sorularınız için hazırım. '
        'Örneğin: "Stok durumu nedir?", "En iyi teknisyen kim?" veya "Rapor ver"';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
    const deepBlue = Color(0xFF1E3A8A);

    return AdminDarkScope(
      child: Builder(builder: (context) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: AdminTechColors.canvas,
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 20,
                    right: 20,
                    bottom: 24,
                  ),
                  color: deepBlue,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Asistan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Soru & Komut',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
          colors: [AdminTechColors.primary, AdminTechColors.cyan],
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
    final isMarkdown = message.text.contains('**') ||
        message.text.contains('\n') ||
        message.text.contains('•') ||
        message.text.contains('📊') ||
        message.text.contains('👷') ||
        message.text.contains('👥') ||
        message.text.contains('📈') ||
        message.text.contains('🤖');

    return Container(
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
      child: isMarkdown
          ? _buildMarkdownMessage(message.text)
          : Text(
              message.text,
              style: const TextStyle(
                color: AdminTechColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
    );
  }

  Widget _buildMarkdownMessage(String text) {
    final List<Widget> widgets = [];
    final lines = text.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                color: AdminTechColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      } else if (line.startsWith('•') || line.startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                Text(
                  '•',
                  style: TextStyle(
                    color: AdminTechColors.primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    line.substring(1).trim(),
                    style: const TextStyle(
                      color: AdminTechColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
      } else {
        final cleaned = line.replaceAll(RegExp(r'\*\*(.*?)\*\*'), '\$1');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              cleaned,
              style: TextStyle(
                color: AdminTechColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
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
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminTechColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.md),
            topRight: const Radius.circular(AppRadius.md),
            bottomRight: const Radius.circular(AppRadius.md),
            bottomLeft: const Radius.circular(4),
          ),
          border: Border.all(color: AdminTechColors.borderSubtle, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AdminTechColors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ).animate(i),
          ],
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
