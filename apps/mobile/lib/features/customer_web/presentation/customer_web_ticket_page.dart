import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tickets/data/ticket_service.dart';
import '../../tickets/models/ticket_models.dart';

class CustomerWebTicketPage extends StatefulWidget {
  const CustomerWebTicketPage({super.key});

  @override
  State<CustomerWebTicketPage> createState() => _CustomerWebTicketPageState();
}

class _CustomerWebTicketPageState extends State<CustomerWebTicketPage> {
  final TicketService _ticketService = TicketService();
  late Future<List<Ticket>> _ticketsFuture;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _priority = 'Normal';

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

  Future<void> _createTicket() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Başlık ve açıklama zorunlu')));
      return;
    }
    try {
      await _ticketService.createTicket(TicketCreateRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
      ));
      if (mounted) {
        _titleController.clear();
        _descriptionController.clear();
        _priority = 'Normal';
        _refreshTickets();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Talep oluşturuldu')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Talep oluşturulamadı')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text('Müşteri Portalı',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  const Text('Yeni iş talebi oluşturun ve taleplerinizi takip edin',
                      style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 20),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Yeni Talep',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Başlık',
                            filled: true,
                            fillColor: Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                            filled: true,
                            fillColor: Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _priority,
                          items: const [
                            DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                            DropdownMenuItem(value: 'High', child: Text('Yüksek')),
                            DropdownMenuItem(value: 'Urgent', child: Text('Acil')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _priority = val);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Öncelik',
                            filled: true,
                            fillColor: Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _createTicket,
                            icon: const Icon(Icons.add),
                            label: const Text('İş talebi oluştur'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Taleplerim',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  _TicketsListCard(ticketsFuture: _ticketsFuture),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketsListCard extends StatelessWidget {
  const _TicketsListCard({required this.ticketsFuture});

  final Future<List<Ticket>> ticketsFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ticket>>(
      future: ticketsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return const _Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Talepler yüklenemedi'),
            ),
          );
        }
        final tickets = snapshot.data ?? [];
        if (tickets.isEmpty) {
          return const _Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Henüz talep yok.'),
            ),
          );
        }
        return _Card(
          child: Column(
            children: [
              for (final ticket in tickets)
                ListTile(
                  title: Text(ticket.title),
                  subtitle: Text(_formatDate(ticket.createdAtUtc)),
                  trailing: _Pill(
                    label: _statusLabel(ticket.status),
                    color: _statusColor(ticket.status),
                  ),
                ),
            ],
          ),
        );
      },
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
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
