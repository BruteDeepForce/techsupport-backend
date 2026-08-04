import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../operations/data/operation_service.dart';
import '../../operations/models/operation_models.dart';

class TechnicianWebHomePage extends StatefulWidget {
  const TechnicianWebHomePage({super.key});

  @override
  State<TechnicianWebHomePage> createState() => _TechnicianWebHomePageState();
}

class _TechnicianWebHomePageState extends State<TechnicianWebHomePage> {
  final OperationService _operationService = OperationService();
  late Future<List<OperationRecord>> _opsFuture;

  @override
  void initState() {
    super.initState();
    _opsFuture = _operationService.listOperations();
  }

  void _refresh() {
    setState(() {
      _opsFuture = _operationService.listOperations();
    });
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
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      const Text('Teknisyen Paneli',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A))),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Yenile'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Atanan işlerinizi yönetin',
                      style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 20),
                  FutureBuilder<List<OperationRecord>>(
                    future: _opsFuture,
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
                            child: Text('İşler yüklenemedi'),
                          ),
                        );
                      }
                      final ops = snapshot.data ?? [];
                      if (ops.isEmpty) {
                        return const _Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Atanmış iş yok.'),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final op in ops)
                            _OpCard(
                              title: op.title,
                              description: op.description,
                              status: _statusLabel(op.status),
                              statusColor: _statusColor(op.status),
                              priority: _priorityLabel(op.priority),
                              priorityColor: _priorityColor(op.priority),
                              createdAt: _formatDate(op.occurredAtUtc),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpCard extends StatelessWidget {
  const _OpCard({
    required this.title,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
    required this.createdAt,
  });

  final String title;
  final String description;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pill(label: status, color: statusColor),
              const SizedBox(width: 8),
              _Pill(label: priority, color: priorityColor),
              const Spacer(),
              Text(createdAt,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF475569))),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Detay'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tamamla'),
              ),
            ],
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 12),
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
      return const Color(0xFF10B981);
    case 'waitingforapproval':
      return const Color(0xFFF59E0B);
    case 'repairing':
    case 'testing':
      return const Color(0xFFFBBF24);
    case 'diagnosing':
      return const Color(0xFF3B82F6);
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
