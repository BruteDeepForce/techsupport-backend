import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_web_customers_page.dart';
import 'admin_web_operations_page.dart';
import 'admin_web_route.dart';
import 'admin_web_offers_page.dart';
import 'admin_web_stock_page.dart';
import 'admin_web_team_page.dart';
import 'admin_web_tickets_page.dart';
import 'admin_web_offers_page.dart';

class AdminWebHomePage extends StatelessWidget {
  const AdminWebHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showSidebar = width >= 1100;
    final textTheme = GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        drawer:
            showSidebar ? null : const Drawer(child: _Sidebar(compact: true)),
        body: Row(
          children: [
            if (showSidebar)
              const SizedBox(
                width: 260,
                child: _Sidebar(),
              ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(showMenu: !showSidebar),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Greeting(),
                          const SizedBox(height: 16),
                          const _TabStrip(),
                          const SizedBox(height: 16),
                          const _CalendarCard(),
                          const SizedBox(height: 16),
                          const _StatusListCard(),
                          const SizedBox(height: 20),
                          _MiniStatsGrid(width: width),
                          const SizedBox(height: 20),
                          _ChartSection(width: width),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1E33), Color(0xFF0A1728)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F223A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/branding/logo.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                if (!compact)
                  const Text(
                    'Lineer Destek',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                const _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Ana Menü',
                  active: true,
                ),
                _NavItem(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Talepler',
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebTicketsPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Operasyonlar',
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebOperationsPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Teklifler',
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebOffersPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.group_outlined,
                  label: 'Ekip Yönetimi',
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebTeamPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Müşteri Yönetimi',
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebCustomersPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.local_offer_sharp,
                  label: 'Teklifler',
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebOffersPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Stok Yönetimi',
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebStockPage()),
                  ),
                ),
                const _NavItem(icon: Icons.payments_outlined, label: 'Finans'),
                const _NavItem(
                    icon: Icons.query_stats_rounded,
                    label: 'Analiz & Raporlar'),
                const _NavItem(icon: Icons.settings_outlined, label: 'Ayarlar'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF14263F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Depolama',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.55,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF1D3554),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF60A5FA)),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('4.88 GB / 8 GB',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9FB3C8))),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text('Depolama Ekle',
                        style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2C4469)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFF1C2F4A),
                  child: Text('ST',
                      style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Süleyman TÜY... \nTR',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9FB3C8)),
                  ),
                ),
                Icon(Icons.logout, size: 18, color: Color(0xFF9FB3C8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1B3A5C) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF9FB3C8)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : const Color(0xFF9FB3C8),
                )),
            const Spacer(),
            if (!active)
              const Icon(Icons.expand_more, size: 14, color: Color(0xFF7B8FA8)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showMenu});

  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          const Spacer(),
          _PrimaryButton(
            icon: Icons.add,
            label: 'İş Emri',
            onPressed: () {},
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              children: const [
                Text('TR', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(width: 6),
                Icon(Icons.expand_more, size: 16),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.wb_sunny_outlined, color: Color(0xFF64748B)),
          const SizedBox(width: 10),
          const Icon(Icons.notifications_none_rounded,
              color: Color(0xFF64748B)),
          const SizedBox(width: 10),
          const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
          const SizedBox(width: 12),
          Row(
            children: const [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE2E8F0),
                child: Text('ST', style: TextStyle(fontSize: 11)),
              ),
              SizedBox(width: 8),
              Text('Süleyman T...',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Merhaba, Süleyman 👋',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        SizedBox(height: 6),
      ],
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Genel İstatistikler',
                style: TextStyle(
                    color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Center(
              child: Text('Depo',
                  style: TextStyle(
                      color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              const Text('Takvimim',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const Spacer(),
              _Pill(label: 'Hafta', active: true),
              const SizedBox(width: 6),
              const _Pill(label: 'Ay'),
              const SizedBox(width: 6),
              const _Pill(label: 'Bugün'),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Mart 2026', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Row(
            children: const [
              _DayCard(day: 'Pzt', date: '23'),
              _DayCard(day: 'Sal', date: '24'),
              _DayCard(day: 'Çar', date: '25'),
              _DayCard(day: 'Per', date: '26'),
              _DayCard(day: 'Cum', date: '27'),
              _DayCard(day: 'Cts', date: '28'),
              _DayCard(day: 'Paz', date: '29', active: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.date, this.active = false});

  final String day;
  final String date;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        height: 86,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF0F7FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: const TextStyle(color: Color(0xFF64748B))),
            const Spacer(),
            Row(
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('+', style: TextStyle(color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusListCard extends StatelessWidget {
  const _StatusListCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Durum Listesi',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: const [
              _StatusPill(
                  color: Color(0xFFFBBF24), label: 'Bekliyor', value: '0'),
              SizedBox(width: 12),
              _StatusPill(
                  color: Color(0xFF3B82F6), label: 'Devam Ediyor', value: '0'),
              SizedBox(width: 12),
              _StatusPill(
                  color: Color(0xFF22C55E), label: 'Tamamlandı', value: '0'),
              SizedBox(width: 12),
              _StatusPill(color: Color(0xFF64748B), label: 'İptal', value: '0'),
            ],
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('Toplam 0 kayıt',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MiniStatsGrid extends StatelessWidget {
  const _MiniStatsGrid({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = width >= 1200
        ? 4
        : width >= 900
            ? 3
            : 2;
    final childAspectRatio = width >= 1200
        ? 2.1
        : width >= 900
            ? 2.0
            : 1.7;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      padding: EdgeInsets.zero,
      children: const [
        _MiniCard(
            title: 'Bekleyen İş Emirleri',
            value: '0',
            caption: '0 acil, 0 normal',
            color: Color(0xFFEFF6FF),
            icon: Icons.receipt_long_outlined),
        _MiniCard(
            title: 'Tamamlanan Emirler',
            value: '0',
            caption: 'Toplam: 0',
            color: Color(0xFFEFFDF4),
            icon: Icons.check_circle_outline),
        _MiniCard(
            title: 'Yaklaşan Bakımlar',
            value: '0',
            caption: 'Önümüzdeki 7 gün',
            color: Color(0xFFFFF7ED),
            icon: Icons.build_outlined),
        _MiniCard(
            title: 'Düşük Stok',
            value: '0',
            caption: '0 stok yok',
            color: Color(0xFFFFF1F2),
            icon: Icons.inventory_2_outlined),
        _MiniCard(
            title: 'Firma & Kişiler',
            value: '0',
            caption: '0 aktif müşteri',
            color: Color(0xFFF1F5FF),
            icon: Icons.groups_outlined),
        _MiniCard(
            title: 'Cihazlar',
            value: '1',
            caption: '1 aktif',
            color: Color(0xFFF0F9FF),
            icon: Icons.devices_outlined),
        _MiniCard(
            title: 'Toplam Gelir',
            value: '₺0',
            caption: '0 teklifler',
            color: Color(0xFFF0FDF4),
            icon: Icons.payments_outlined),
        _MiniCard(
            title: 'Bekleyen Teklifler',
            value: '0',
            caption: '0 toplam',
            color: Color(0xFFF1F5F9),
            icon: Icons.request_quote_outlined),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final stacked = width < 1200;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: stacked ? 1 : 2,
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Aylık Trend',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Son 6 Ay',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 16),
                    _ChartPlaceholder(
                        height: 170, caption: 'Toplam / Tamamlandı'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Duruma göre iş emirleri',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Mevcut dağılım',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 24),
                    _EmptyState(label: 'Veri bulunamadı'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maliyet Özeti',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('İş emri maliyet dağılımı',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 16),
                    _CostRow(
                        color: Color(0xFFBFDBFE),
                        label: 'Toplam Parça Maliyeti',
                        value: '₺0'),
                    SizedBox(height: 8),
                    _CostRow(
                        color: Color(0xFFFFEDD5),
                        label: 'Toplam İşçilik Maliyeti',
                        value: '₺0'),
                    SizedBox(height: 8),
                    _CostRow(
                        color: Color(0xFFDCFCE7),
                        label: 'Toplam Maliyet',
                        value: '₺0'),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aylık Maliyet Trendi',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Son 6 Ay',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 16),
                    _ChartPlaceholder(height: 150, caption: 'Chart'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Öncelik Dağılımı',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Önceliğe göre iş emirleri',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 16),
                    _ChartPlaceholder(
                        height: 130, caption: 'düşük / normal / acil'),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Son İş Emirleri',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Son 5 iş emri',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 24),
                    _EmptyState(label: 'Henüz iş emri bulunmuyor'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Teknisyen Durumu',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(height: 6),
              Text('Aktif teknisyenler',
                  style: TextStyle(color: Color(0xFF94A3B8))),
              SizedBox(height: 24),
              _EmptyState(label: 'Veri bulunamadı'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.height, required this.caption});

  final double height;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: Text(caption, style: const TextStyle(color: Color(0xFF94A3B8))),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8))),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 16, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
