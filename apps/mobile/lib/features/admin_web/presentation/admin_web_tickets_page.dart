import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tickets/data/ticket_service.dart';
import '../../tickets/models/ticket_models.dart';
import 'admin_web_ticket_detail_page.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_sidebar.dart';
import 'shared/admin_web_topbar.dart';

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
                child: AdminWebSidebar(
                    compact: true, radius: 0, active: AdminNavKey.tickets),
              ),
        body: Row(
          children: [
            if (showSidebar) const AdminWebSidebarPanel(active: AdminNavKey.tickets),
            Expanded(
              child: Column(
                children: [
                  const AdminWebTopBar(showMenu: false),
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
                            onOpenTicket: (ticketId) => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) =>
                                        AdminWebTicketDetailPage(ticketId: ticketId))),
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

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text('Yönetim', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Talep Yönetimi', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
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
                  username: ticket.customername,
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
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 2,
            child: Text('Kullanıcı',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 1,
            child: Text('Öncelik',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 1,
            child: Text('Durum',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 1,
            child: Text('Tarih',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
    required this.username,
    required this.priority,
    required this.status,
    required this.createdAtUtc,
    required this.onTap,
  });

  final String id;
  final String title;
  final String? username;
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
              flex: 2,
              child: Text(
                username ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
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
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
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
      return 'İşlem Başlatıldı';
    case 'repairing':
      return 'Onarım/İşlem';
    case 'closed':
      return 'Kapalı';
    case 'rejected':
      return 'Reddedildi';
    default:
      return 'Yeni Talep';
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
