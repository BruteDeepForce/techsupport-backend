import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tickets/data/ticket_service.dart';
import '../../tickets/models/ticket_models.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';
import 'admin_web_customers_page.dart';
import 'admin_web_home_page.dart';
import 'admin_web_operations_page.dart';
import 'admin_web_route.dart';
import 'admin_web_stock_page.dart';
import 'admin_web_team_page.dart';
import 'admin_web_tickets_page.dart';

class AdminWebTicketDetailPage extends StatefulWidget {
  const AdminWebTicketDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<AdminWebTicketDetailPage> createState() =>
      _AdminWebTicketDetailPageState();
}

class _AdminWebTicketDetailPageState extends State<AdminWebTicketDetailPage> {
  final TicketService _ticketService = TicketService();
  final TechnicianService _technicianService = TechnicianService();
  late Future<Ticket> _ticketFuture;
  late Future<List<Technician>> _techniciansFuture;
  Technician? _selectedTechnician;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticketFuture = _ticketService.getTicket(widget.ticketId);
    _techniciansFuture = _technicianService.listTechnicians();
  }

  void _refreshTicket() {
    setState(() {
      _ticketFuture = _ticketService.getTicket(widget.ticketId);
    });
  }

  Future<void> _approveTicket(Ticket ticket) async {
    if (_selectedTechnician == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teknisyen seçin')));
      return;
    }
    try {
      await _ticketService.convertTicket(
        ticket.id,
        ConvertTicketRequest(
          technicianId: _selectedTechnician!.userId,
          technicianName: _selectedTechnician!.name,
          priority: _operationPriorityFromTicket(ticket.priority),
          operationType: 'Repair',
          internalNote: _noteController.text.trim(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Talep iş emrine dönüştürüldü')));
        _refreshTicket();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Onay işlemi başarısız')));
      }
    }
  }

  Future<void> _rejectTicket(Ticket ticket) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Talebi Reddet'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Gerekçe',
            hintText: 'Reddetme sebebini yazın',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('İptal')),
          ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) return;
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Reddet')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _ticketService.rejectTicket(
          ticket.id, reasonController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Talep reddedildi')));
        _refreshTicket();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reddetme işlemi başarısız')));
      }
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
                child: _WebSidebar(compact: true, active: _NavKey.tickets)),
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
                      child: FutureBuilder<Ticket>(
                        future: _ticketFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const _Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('Talep yüklenemedi'),
                              ),
                            );
                          }
                          final ticket = snapshot.data!;
                          final statusLabel = _statusLabel(ticket.status);
                          final statusColor = _statusColor(ticket.status);
                          final canApprove = ticket.status == 'Open';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Breadcrumb(),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ticket.title,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Talep #${_shortId(ticket.id)}',
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _Pill(label: statusLabel, color: statusColor),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ticket.description,
                                        style: const TextStyle(
                                            color: Color(0xFF475569),
                                            height: 1.5)),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _InfoChip(
                                            label: 'Öncelik',
                                            value:
                                                _priorityLabel(ticket.priority)),
                                        const SizedBox(width: 10),
                                        _InfoChip(
                                            label: 'Tarih',
                                            value:
                                                _formatDate(ticket.createdAtUtc)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _Card(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Teknisyen Ata',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 10),
                                          FutureBuilder<List<Technician>>(
                                            future: _techniciansFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const LinearProgressIndicator();
                                              }
                                              final techs =
                                                  snapshot.data ?? [];
                                              return DropdownButtonFormField<String>(
                                                value: _selectedTechnician?.userId,
                                                items: [
                                                  for (final tech in techs)
                                                    DropdownMenuItem(
                                                      value: tech.userId,
                                                      child: Text(tech.name),
                                                    )
                                                ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    final found = techs
                                                        .where(
                                                            (t) => t.userId == value)
                                                        .toList();
                                                    _selectedTechnician =
                                                        found.isEmpty
                                                            ? null
                                                            : found.first;
                                                  });
                                                },
                                                decoration: const InputDecoration(
                                                  labelText: 'Teknisyen',
                                                  filled: true,
                                                  fillColor: Color(0xFFF8FAFC),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _noteController,
                                            maxLines: 3,
                                            decoration: const InputDecoration(
                                              labelText: 'İç Not',
                                              hintText:
                                                  'Operasyon için not ekleyin',
                                              filled: true,
                                              fillColor: Color(0xFFF8FAFC),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 220,
                                    child: Column(
                                      children: [
                                        _PrimaryActionButton(
                                          label: 'Onayla / İş Emri',
                                          icon: Icons.check,
                                          onPressed: canApprove
                                              ? () => _approveTicket(ticket)
                                              : () {},
                                          enabled: canApprove,
                                        ),
                                        const SizedBox(height: 10),
                                        _DangerActionButton(
                                          label: 'Reddet',
                                          icon: Icons.close,
                                          onPressed: canApprove
                                              ? () => _rejectTicket(ticket)
                                              : () {},
                                          enabled: canApprove,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
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
        Text('Talep Detayı',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569))),
          Text(value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton(
      {required this.label,
      required this.icon,
      required this.onPressed,
      this.enabled = true});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _DangerActionButton extends StatelessWidget {
  const _DangerActionButton(
      {required this.label,
      required this.icon,
      required this.onPressed,
      this.enabled = true});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFB91C1C),
        side: const BorderSide(color: Color(0xFFFECACA)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFFFEF2F2),
      ),
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

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id;

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

String _operationPriorityFromTicket(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return 'Urgent';
    case 'high':
      return 'High';
    default:
      return 'Normal';
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
