import 'package:flutter/material.dart';
import '../../../core/design/app_design.dart';

class AdminAIChatPage extends StatefulWidget {
  const AdminAIChatPage({super.key});

  @override
  State<AdminAIChatPage> createState() => _AdminAIChatPageState();
}

class _AdminAIChatPageState extends State<AdminAIChatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isAi': true,
      'text': 'Merhaba Sercan Bey. Ben AI İş Asistanınız. Firmanızın stok durumu, ekip performansı veya operasyonel verileri hakkında size nasıl yardımcı olabilirim?',
      'time': '13:23',
    },
  ];

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.initState();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    final text = _controller.text;
    setState(() {
      _messages.add({
        'isAi': false,
        'text': text,
        'time': 'Şimdi',
      });
      _controller.clear();
    });

    _scrollToBottom();

    // Mock AI Response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'isAi': true,
          'text': 'Verileriniz taranıyor... Şu anki stok seviyelerinizde Apple Magic Keyboard kritik seviyede görünüyor (+12 talep bekleniyor). Ekip verimliliği ise geçen aya göre %14 artışta.',
          'time': 'Şimdi',
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.only(top: 40, bottom: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1E3A8A), // Deep Corporate Blue
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI İş Danışmanı', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('7/24 Akıllı Analiz', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.1).animate(_pulseController),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      _AICoreVisual(controller: _pulseController),
                      const SizedBox(height: 12),
                      const Text(
                        'SİSTEM ANALİZ MODUNDA',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                ..._messages.map((m) => _ChatBubble(
                      isAi: m['isAi'],
                      text: m['text'],
                      time: m['time'],
                    )),
                const SizedBox(height: 10),
                // ── Suggestion Chips ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SuggestionChip(
                        label: 'Stok Durumu',
                        onTap: () {
                          _controller.text = 'Mevcut stok durumu nedir?';
                          _sendMessage();
                        },
                      ),
                      _SuggestionChip(
                        label: 'Ekip Verimliliği',
                        onTap: () {
                          _controller.text = 'Bu hafta ekip performansı nasıl?';
                          _sendMessage();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Bottom Input Section ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Light Slate
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E3A8A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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

class _AICoreVisual extends StatelessWidget {
  const _AICoreVisual({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
          ),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                    blurRadius: 15 * controller.value,
                    spreadRadius: 2 * controller.value,
                  ),
                ],
              ),
              child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 18),
            ),
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.isAi, required this.text, required this.time});
  final bool isAi;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isAi ? const Color(0xFF1E3A8A).withValues(alpha: 0.1) : const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAi ? 0 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isAi ? const Color(0xFF1E3A8A) : Colors.white,
                fontSize: 14,
                fontWeight: isAi ? FontWeight.w500 : FontWeight.normal,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isAi ? Colors.black38 : Colors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E3A8A).withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
