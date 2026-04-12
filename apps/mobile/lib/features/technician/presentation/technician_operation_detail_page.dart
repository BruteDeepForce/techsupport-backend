import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../operations/data/operation_service.dart';
import '../../operations/models/operation_models.dart';
import 'technician_payment_page.dart';
import 'technician_stock_page.dart';

class TechnicianOperationDetailPage extends StatefulWidget {
  const TechnicianOperationDetailPage({super.key, required this.operationId});

  final String operationId;

  @override
  State<TechnicianOperationDetailPage> createState() =>
      _TechnicianOperationDetailPageState();
}

class _TechnicianOperationDetailPageState
    extends State<TechnicianOperationDetailPage> {
  final OperationService _operationService = OperationService();
  late Future<OperationRecord> _operationFuture;

  @override
  void initState() {
    super.initState();
    _operationFuture = _operationService.getOperation(widget.operationId);
  }

  void _refresh() {
    setState(() {
      _operationFuture = _operationService.getOperation(widget.operationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'İş Emri',
      subtitle: 'Detay',
      showBack: true,
      tabBar: const SizedBox.shrink(),
      children: [
        FutureBuilder<OperationRecord>(
          future: _operationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return LinearCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detay yüklenemedi'),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              );
            }
            final op = snapshot.data;
            if (op == null) {
              return const LinearCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Kayıt bulunamadı'),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          LinearPriority(color: _priorityColor(op.priority)),
                          const SizedBox(width: 8),
                          Text(
                            _shortId(op.id),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          LinearBadge(
                            label: _statusLabel(op.status),
                            color: _statusColor(op.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        op.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        op.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _InfoPill(Icons.devices_other_outlined,
                              _shortId(op.deviceId)),
                          _InfoPill(Icons.person_outline_rounded,
                              _shortId(op.customerId)),
                          _InfoPill(Icons.flag_outlined,
                              _priorityLabel(op.priority)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LinearCard(
                  child: Column(
                    children: [
                      _InfoRow('Durum', _statusLabel(op.status)),
                      _InfoRow('Öncelik', _priorityLabel(op.priority)),
                      _InfoRow('Tür', _operationTypeLabel(op.type)),
                      _InfoRow('Müşteri', _shortId(op.customerId)),
                      _InfoRow('Cihaz', _shortId(op.deviceId)),
                      _InfoRow('Teknisyen',
                          op.technicianUserId == null
                              ? '-'
                              : _shortId(op.technicianUserId!)),
                      _InfoRow('Tarih', _formatDate(op.occurredAtUtc)),
                      if (op.scheduledAtUtc != null)
                        _InfoRow(
                            'Planlanan', _formatDate(op.scheduledAtUtc!)),
                    ],
                  ),
                ),
                if (op.internalnote.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  LinearCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İç Not',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          op.internalnote,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const TechnicianStockPage(),
                          ),
                        ),
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Parça Talebi'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => TechnicianPaymentPage(
                              operationId: op.id,
                              title: op.title,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Ödeme Al'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill(this.icon, this.value);

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'new':
      return 'Yeni';
    case 'inprogress':
      return 'Devam Ediyor';
    case 'completed':
      return 'Tamamlandı';
    case 'delivered':
      return 'Teslim Edildi';
    case 'cancelled':
      return 'İptal';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'new':
      return AppColors.statusBlue;
    case 'inprogress':
      return AppColors.statusYellow;
    case 'completed':
      return AppColors.statusGreen;
    case 'delivered':
      return AppColors.statusPurple;
    case 'cancelled':
      return AppColors.statusRed;
    default:
      return AppColors.statusGray;
  }
}

String _priorityLabel(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return 'Acil';
    case 'high':
      return 'Yüksek';
    case 'normal':
      return 'Normal';
    case 'low':
      return 'Düşük';
    default:
      return priority;
  }
}

Color _priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return AppColors.statusRed;
    case 'high':
      return AppColors.statusOrange;
    case 'normal':
      return AppColors.statusBlue;
    case 'low':
      return AppColors.statusGreen;
    default:
      return AppColors.statusGray;
  }
}

String _operationTypeLabel(String type) {
  switch (type.toLowerCase()) {
    case 'repair':
      return 'Onarım';
    case 'maintenance':
      return 'Bakım';
    case 'installation':
      return 'Kurulum';
    default:
      return type;
  }
}
