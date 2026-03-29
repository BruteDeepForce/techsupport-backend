import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import 'admin_ai_chat_page.dart';

class AdminAIAutonomousPage extends StatefulWidget {
  const AdminAIAutonomousPage({super.key});

  @override
  State<AdminAIAutonomousPage> createState() => _AdminAIAutonomousPageState();
}

class _AdminAIAutonomousPageState extends State<AdminAIAutonomousPage> {
  bool _autoMessaging = true;
  bool _autoAssignment = true;
  bool _stockForecasting = false;
  bool _faultPricePrediction = false;
  bool _supplyChainAutomation = false;
  bool _techSuccessAnalysis = false;
  bool _partFailureAnalysis = false;

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'AI Otonom Mod',
      subtitle: 'Sistem Yönetimi',
      showBack: true,
      tabBar: const SizedBox.shrink(),
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
      ),
      children: [
        // ── AI Business Assistant (Chat Trigger) ────────────────────
        const _AIBusinessAssistant(),

        const SizedBox(height: 24),

        // ── AI Automation Controls ──────────────────────────────────
        const LinearSection(title: 'OTOMASYON KONTROLLERİ'),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _ControlRow(
                title: 'Müşteriyle Otomatik Mesajlaşma',
                subtitle: 'AI, gelen talepleri yanıtlar ve özetler.',
                value: _autoMessaging,
                onChanged: (v) => setState(() => _autoMessaging = v),
              ),
              _ControlRow(
                title: 'Otomatik Teknisyen Atama',
                subtitle: 'Yük ve uzmanlığa göre akıllı atama.',
                value: _autoAssignment,
                onChanged: (v) => setState(() => _autoAssignment = v),
              ),
              _ControlRow(
                title: 'AI Stok Tahmini',
                subtitle: 'Parça bitmeden otomatik sipariş önerisi.',
                value: _stockForecasting,
                onChanged: (v) => setState(() => _stockForecasting = v),
              ),
              _ControlRow(
                title: 'Arıza ve Fiyat Tahmini',
                subtitle: 'Müşteriye otomatik maliyet öngörüsü sunar.',
                value: _faultPricePrediction,
                onChanged: (v) => setState(() => _faultPricePrediction = v),
              ),
              _ControlRow(
                title: 'Tedarik Zinciri Otomasyonu',
                subtitle: 'Parça siparişi ve mesaj hazırlama.',
                value: _supplyChainAutomation,
                onChanged: (v) => setState(() => _supplyChainAutomation = v),
              ),
              _ControlRow(
                title: 'Teknisyen Başarı Analizi',
                subtitle: 'Başarı oranı ve uzmanlık takibi.',
                value: _techSuccessAnalysis,
                onChanged: (v) => setState(() => _techSuccessAnalysis = v),
              ),
              _ControlRow(
                title: 'Parça Arıza Analizi',
                subtitle: 'Kronik arıza ve parça kalite takibi.',
                value: _partFailureAnalysis,
                onChanged: (v) => setState(() => _partFailureAnalysis = v),
                showDivider: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Recent AI Actions ────────────────────────────────────────
        const LinearSection(title: 'SON OTONOM İŞLEMLER', count: 3),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _AILogRow(
                action: 'Teknisyen Atandı',
                target: 'Talep #TS-918 -> Ahmet Mert',
                time: '2dk önce',
              ),
              _AILogRow(
                action: 'Yanıt Gönderildi',
                target: 'Müşteri Can Yılmaz (Özetlendi)',
                time: '15dk önce',
              ),
              _AILogRow(
                action: 'İş Emri Oluşturuldu',
                target: 'Kritik Arıza: Server Rack 4',
                time: '1sa önce',
                showDivider: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Chat Summaries ──────────────────────────────────────────
        const LinearSection(title: 'MÜŞTERİ KONUŞMA ÖZETLERİ'),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _ChatSummaryRow(
                customer: 'Fatma Kardaş',
                summary: 'Klavye sorunu için cihazını yarın getireceğini belirtti.',
                mood: 'Pozitif',
                moodColor: AppColors.statusGreen,
              ),
              _ChatSummaryRow(
                customer: 'Selim Akarsu',
                summary: 'Acil VPN erişimi bekliyor, işleri yarım kalmış.',
                mood: 'Endişeli',
                moodColor: AppColors.statusOrange,
                showDivider: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _AIStat extends StatelessWidget {
  const _AIStat({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({required this.title, required this.subtitle, required this.value, required this.onChanged, this.showDivider = true});
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _AILogRow extends StatelessWidget {
  const _AILogRow({required this.action, required this.target, required this.time, this.showDivider = true});
  final String action;
  final String target;
  final String time;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)) : null,
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.cyanAccent, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(target, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ChatSummaryRow extends StatelessWidget {
  const _ChatSummaryRow({required this.customer, required this.summary, required this.mood, required this.moodColor, this.showDivider = true});
  final String customer;
  final String summary;
  final String mood;
  final Color moodColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(customer, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
              LinearBadge(label: mood, color: moodColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _AIBusinessAssistant extends StatelessWidget {
  const _AIBusinessAssistant();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            const Color(0xFF3730A3), // Indigo 800
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forum_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'AI İŞ ASİSTANI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '7/24 DESTEK',
                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Firmanız hakkındaki her şeyi yapay zekaya sorun. Stok durumu, ekip verimliliği veya müşteri analizi hakkında anında yanıt alın.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAIChatPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'AI DANIŞMANIYLA KONUŞ',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
