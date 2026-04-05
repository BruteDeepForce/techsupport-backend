import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../offers/data/offer_service.dart';
import '../../offers/models/offer_models.dart';
import 'admin_web_customers_page.dart';
import 'admin_web_home_page.dart';
import 'admin_web_offers_page.dart';
import 'admin_web_operations_page.dart';
import 'admin_web_route.dart';
import 'admin_web_stock_page.dart';
import 'admin_web_team_page.dart';
import 'admin_web_tickets_page.dart';

class AdminWebOfferDetailPage extends StatefulWidget {
  const AdminWebOfferDetailPage({super.key, required this.offerId});

  final String offerId;

  @override
  State<AdminWebOfferDetailPage> createState() =>
      _AdminWebOfferDetailPageState();
}

class _AdminWebOfferDetailPageState extends State<AdminWebOfferDetailPage> {
  final OfferService _offerService = OfferService();
  late Future<OfferSummary> _offerFuture;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _offerFuture = _offerService.getOfferById(widget.offerId);
  }

  void _refresh() {
    setState(() {
      _offerFuture = _offerService.getOfferById(widget.offerId);
    });
  }

  Future<void> _approve() async {
    setState(() => _acting = true);
    try {
      final ok = await _offerService.approveAdmin(widget.offerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Teklif onaylandı' : 'Onay başarısız')));
      _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Onay başarısız')));
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _acting = true);
    try {
      final ok = await _offerService.rejectAdmin(widget.offerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Teklif reddedildi' : 'Reddetme başarısız')));
      _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reddetme başarısız')));
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showSidebar = width >= 1100;
    final textTheme = GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FB),
        drawer: showSidebar
            ? null
            : const Drawer(
                child: _WebSidebar(compact: true, active: _NavKey.offers),
              ),
        body: Row(
          children: [
            if (showSidebar)
              const SizedBox(
                width: 260,
                child: _WebSidebar(active: _NavKey.offers),
              ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(showMenu: false, onRefresh: _refresh),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Breadcrumb(),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Teklif Detayı',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Teklife ait kalemleri ve toplam tutarı inceleyin',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<OfferSummary>(
                            future: _offerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const _Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return const _Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('Teklif yüklenemedi'),
                                  ),
                                );
                              }
                              final offer = snapshot.data;
                              if (offer == null) {
                                return const _Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('Kayıt bulunamadı'),
                                  ),
                                );
                              }

                              final itemCount = offer.items
                                  .fold<int>(0, (sum, i) => sum + i.quantity);
                              final status = (offer.status ?? 'Pending');
                              final isPending =
                                  status.toLowerCase() == 'pending';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Teklif ${_shortId(offer.id)}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Operasyon: ${_shortId(offer.operationId)}',
                                                  style: const TextStyle(
                                                      color: Color(0xFF64748B)),
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    _Pill(
                                                      label:
                                                          'Kalem: $itemCount',
                                                      color: const Color(
                                                          0xFF2563EB),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _Pill(
                                                      label:
                                                          _statusLabel(status),
                                                      color:
                                                          _statusColor(status),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _Pill(
                                                      label:
                                                          '${offer.amount.toStringAsFixed(2)} ${offer.currency}',
                                                      color: const Color(
                                                          0xFFF59E0B),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text('Teknisyen',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Color(0xFF64748B))),
                                              const SizedBox(height: 4),
                                              Text(_shortId(
                                                  offer.technicianUserId)),
                                              const SizedBox(height: 12),
                                              const Text('Müşteri',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Color(0xFF64748B))),
                                              const SizedBox(height: 4),
                                              Text(offer.customerId ?? '-'),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  OutlinedButton(
                                                    onPressed: _acting ||
                                                            !isPending
                                                        ? null
                                                        : _reject,
                                                    child: const Text('Reddet'),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  FilledButton(
                                                    onPressed: _acting ||
                                                            !isPending
                                                        ? null
                                                        : _approve,
                                                    child: const Text('Onayla'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _Card(
                                    child: Column(
                                      children: [
                                        const _ItemsHeader(),
                                        const Divider(
                                            height: 1,
                                            color: Color(0xFFE2E8F0)),
                                        for (final item in offer.items)
                                          _ItemRow(item: item),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
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

enum _NavKey { home, tickets, operations, offers, team, customers, stock, other }

class _WebSidebar extends StatelessWidget {
  const _WebSidebar({this.compact = false, required this.active});

  final bool compact;
  final _NavKey active;

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
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/branding/logo.png',
                    width: 20,
                    height: 20,
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
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Ana Menü',
                  active: active == _NavKey.home,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebHomePage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Talepler',
                  active: active == _NavKey.tickets,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebTicketsPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Operasyonlar',
                  active: active == _NavKey.operations,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebOperationsPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Teklifler',
                  active: active == _NavKey.offers,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebOffersPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.group_outlined,
                  label: 'Ekip Yönetimi',
                  active: active == _NavKey.team,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebTeamPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Müşteri Yönetimi',
                  active: active == _NavKey.customers,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebCustomersPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Stok Yönetimi',
                  active: active == _NavKey.stock,
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
          _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF60A5FA)),
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
  const _TopBar({required this.showMenu, required this.onRefresh});

  final bool showMenu;
  final VoidCallback onRefresh;

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
          _SecondaryActionButton(
            label: 'Yenile',
            icon: Icons.refresh,
            onPressed: onRefresh,
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
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE2E8F0),
            child: Text('ST', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text('Yönetim',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Teklifler',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Detay', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'adminapproved':
      return 'Admin Onayladı';
    case 'customerapproved':
      return 'Müşteri Onayladı';
    case 'adminrejected':
      return 'Admin Reddetti';
    case 'customerrejected':
      return 'Müşteri Reddetti';
    default:
      return 'Beklemede';
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'adminapproved':
    case 'customerapproved':
      return const Color(0xFF22C55E);
    case 'adminrejected':
    case 'customerrejected':
      return const Color(0xFFEF4444);
    default:
      return const Color(0xFFF59E0B);
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton(
      {required this.label, required this.icon, required this.onPressed});

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
        foregroundColor: const Color(0xFF0F172A),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _ItemsHeader extends StatelessWidget {
  const _ItemsHeader();

  @override
  Widget build(BuildContext context) {
    final headers = ['Stok Id', 'Miktar', 'Birim Fiyat'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: headers
            .map((h) => Expanded(
                  child: Text(
                    h,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OfferItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(_shortId(item.stockItemId))),
          Expanded(child: Text('${item.quantity}')),
          Expanded(child: Text(item.unitPrice.toStringAsFixed(2))),
        ],
      ),
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
