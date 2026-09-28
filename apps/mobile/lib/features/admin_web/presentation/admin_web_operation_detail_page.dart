import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../operations/data/operation_service.dart';
import '../../operations/models/operation_models.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_sidebar.dart';

class AdminWebOperationDetailPage extends StatefulWidget {
  const AdminWebOperationDetailPage({super.key, required this.operationId});

  final String operationId;

  @override
  State<AdminWebOperationDetailPage> createState() =>
      _AdminWebOperationDetailPageState();
}

class _AdminWebOperationDetailPageState
    extends State<AdminWebOperationDetailPage> {
  final OperationService _operationService = OperationService();
  late Future<OperationRecord> _opFuture;

  @override
  void initState() {
    super.initState();
    _opFuture = _operationService.getOperation(widget.operationId);
  }

  void _refresh() {
    setState(() {
      _opFuture = _operationService.getOperation(widget.operationId);
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
                child: AdminWebSidebar(compact: true, active: AdminNavKey.operations),
              ),
        body: Row(
          children: [
            if (showSidebar)
              const SizedBox(
                width: 260,
                child: AdminWebSidebar(active: AdminNavKey.operations),
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
                                      'İş Emri Detayı',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Seçilen iş emrinin ayrıntıları',
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
                                onPressed: _refresh,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<OperationRecord>(
                            future: _opFuture,
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
                                    child: Text('İş emri yüklenemedi'),
                                  ),
                                );
                              }
                              final op = snapshot.data;
                              if (op == null) {
                                return const _Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('Kayıt bulunamadı'),
                                  ),
                                );
                              }
                              return Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1100),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      op.title,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      op.description,
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xFF64748B),
                                                          height: 1.4),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      children: [
                                                        _StatusPill(
                                                          label: _statusLabel(
                                                              op.status),
                                                          color: _statusColor(
                                                              op.status),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        _StatusPill(
                                                          label: _priorityLabel(
                                                              op.priority),
                                                          color: const Color(
                                                              0xFF2563EB),
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
                                                  const Text('İş Emri',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFF64748B))),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _shortId(op.id),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  const Text('Tarih',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFF64748B))),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _formatTime(
                                                        op.occurredAtUtc),
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Wrap(
                                            spacing: 16,
                                            runSpacing: 16,
                                            children: [
                                              _DetailTile(
                                                label: 'Müşteri',
                                                value:
                                                    _shortId(op.customerName),
                                              ),
                                              _DetailTile(
                                                label: 'Cihaz',
                                                value: _shortId(op.deviceId),
                                              ),
                                              _DetailTile(
                                                label: 'Teknisyen',
                                                value: op.technicianName.isEmpty
                                                    ? '-'
                                                    : _shortId(
                                                        op.technicianName),
                                              ),
                                              _DetailTile(
                                                label: 'Tür',
                                                value: op.type,
                                              ),
                                              _DetailTile(
                                                label: 'Öncelik',
                                                value:
                                                    _priorityLabel(op.priority),
                                              ),
                                              _DetailTile(
                                                label: 'Durum',
                                                value: _statusLabel(op.status),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
        Text('Operasyonlar',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Detay', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

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

String _shortId(String id) {
  if (id.isEmpty) return '-';
  return id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'diagnosing':
      return 'Teşhis';
    case 'waitingforapproval':
      return 'Onay Bekliyor';
    case 'repairing':
      return 'Onarım';
    case 'testing':
      return 'Test';
    case 'completed':
      return 'Tamamlandı';
    case 'delivered':
      return 'Teslim';
    default:
      return 'Yeni';
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'delivered':
      return const Color(0xFF22C55E);
    case 'waitingforapproval':
      return const Color(0xFFF59E0B);
    case 'repairing':
    case 'testing':
      return const Color(0xFFF59E0B);
    case 'diagnosing':
      return const Color(0xFF3B82F6);
    default:
      return const Color(0xFF64748B);
  }
}

String _priorityLabel(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return 'Kritik';
    case 'high':
      return 'Yüksek';
    case 'medium':
      return 'Orta';
    default:
      return 'Normal';
  }
}

String _formatTime(DateTime dt) {
  final local = dt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}
