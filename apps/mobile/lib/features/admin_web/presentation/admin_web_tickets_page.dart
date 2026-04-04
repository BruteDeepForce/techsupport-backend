import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tickets/data/ticket_service.dart';
import '../../tickets/models/ticket_models.dart';
import 'admin_web_customers_page.dart';
import 'admin_web_home_page.dart';
import 'admin_web_operations_page.dart';
import 'admin_web_route.dart';
import 'admin_web_stock_page.dart';
import 'admin_web_team_page.dart';
import 'admin_web_ticket_detail_page.dart';

class AdminWebTicketsPage extends StatefulWidget {
  const AdminWebTicketsPage({super.key});

  @override
  State<AdminWebTicketsPage> createState() => _AdminWebTicketsPageState();
}

class _AdminWebTicketsPageState extends State<AdminWebTicketsPage> {
  final TicketService _ticketService = TicketService();
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _ticketService.listTickets();
  }

  void _refreshTickets() {
    setState(() {
      _ticketsFuture = _ticketService.listTickets();
    });
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
                child: _WebSidebar(compact: true, active: _NavKey.tickets),
              ),
        body: Row(
          children: [
            if (showSidebar)
              const SizedBox(
                width: 260,
                child: _WebSidebar(active: _NavKey.tickets),
              ),
            Expanded(
              child: Column(
                children: [
                  const _TopBar(showMenu: false),
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
                                      'Talep Yönetimi',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Açık talepleri görüntüleyin ve iş emrine dönüştürün',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _SecondaryActionButton(
                                label: 'Yenile',
                                icon: Icons.refresh,
                                onPressed: _refreshTickets,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _TicketsTableCard(
                            ticketsFuture: _ticketsFuture,
                            onOpenTicket: (ticketId) => Navigator.of(context)
                                .push(MaterialPageRoute<void>(
                                    builder: (_) =>
                                        AdminWebTicketDetailPage(
                                            ticketId: ticketId))),
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

enum _NavKey { home, tickets, operations, team, customers, stock, other }

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
                child:
                    Text('ST', style: TextStyle(fontSize: 11, color: Colors.white)),
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
          _SecondaryActionButton(
            label: 'İş Emri',
            icon: Icons.add,
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
        Text('Talep Yönetimi',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _TicketsTableCard extends StatelessWidget {
  const _TicketsTableCard({
    required this.ticketsFuture,
    required this.onOpenTicket,
  });

  final Future<List<Ticket>> ticketsFuture;
  final void Function(String ticketId) onOpenTicket;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ticket>>(
      future: ticketsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Talepler yüklenemedi'),
            ),
          );
        }
        final tickets = snapshot.data ?? [];
        if (tickets.isEmpty) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Henüz talep yok.'),
            ),
          );
        }

        return _TableCard(
          child: Column(
            children: [
              const _TableHeader(),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              for (final ticket in tickets)
                _TableRow(
                  id: ticket.id,
                  title: ticket.title,
                  priority: ticket.priority,
                  status: ticket.status,
                  createdAtUtc: ticket.createdAtUtc,
                  onTap: () => onOpenTicket(ticket.id),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text('Başlık',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 1,
            child: Text('Öncelik',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 1,
            child: Text('Durum',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 1,
            child: Text('Tarih',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569))),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
    required this.createdAtUtc,
    required this.onTap,
  });

  final String id;
  final String title;
  final String priority;
  final String status;
  final DateTime createdAtUtc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A))),
            ),
            Expanded(
              flex: 1,
              child: _Pill(
                label: _priorityLabel(priority),
                color: _priorityColor(priority),
              ),
            ),
            Expanded(
              flex: 1,
              child: _Pill(
                label: _statusLabel(status),
                color: _statusColor(status),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(_formatDate(createdAtUtc),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B))),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  return '$day.$month.$year';
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'createdoperation':
      return 'Operasyon';
    case 'closed':
      return 'Kapalı';
    case 'rejected':
      return 'Reddedildi';
    default:
      return 'Açık';
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'createdoperation':
      return const Color(0xFFF59E0B);
    case 'closed':
      return const Color(0xFF10B981);
    case 'rejected':
      return const Color(0xFFEF4444);
    default:
      return const Color(0xFF3B82F6);
  }
}

String _priorityLabel(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return 'Acil';
    case 'high':
      return 'Yüksek';
    default:
      return 'Normal';
  }
}

Color _priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return const Color(0xFFEF4444);
    case 'high':
      return const Color(0xFFF97316);
    default:
      return const Color(0xFF3B82F6);
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
