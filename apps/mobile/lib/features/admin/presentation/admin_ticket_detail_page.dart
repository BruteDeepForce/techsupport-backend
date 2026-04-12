import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../tickets/data/ticket_service.dart';
import '../../tickets/models/ticket_models.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';

class AdminTicketDetailPage extends StatefulWidget {
  const AdminTicketDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<AdminTicketDetailPage> createState() => _AdminTicketDetailPageState();
}

class _AdminTicketDetailPageState extends State<AdminTicketDetailPage> {
  final TicketService _ticketService = TicketService();
  final TechnicianService _technicianService = TechnicianService();
  late Future<Ticket> _ticketFuture;
  late Future<List<Technician>> _techniciansFuture;

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
    Technician? selectedTechnician;
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Talebi Onayla'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<List<Technician>>(
                      future: _techniciansFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                              'Teknisyen listesi alınamadı: ${snapshot.error}');
                        }
                        final techs = snapshot.data ?? [];
                        if (techs.isEmpty) {
                          return const Text('Aktif teknisyen bulunamadı.');
                        }
                        return DropdownButtonFormField<String>(
                          value: selectedTechnician?.id,
                          items: [
                            for (final tech in techs)
                              DropdownMenuItem(
                                value: tech.userId,
                                child: Text(tech.name),
                              ),
                          ],
                          onChanged: (value) {
                            final tech = techs
                                .where((t) => t.userId == value)
                                .toList();
                            setDialogState(() {
                              selectedTechnician =
                                  tech.isEmpty ? null : tech.first;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Teknisyen Ata',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'İç Not (opsiyonel)',
                        hintText: 'Operasyon için not ekleyin',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedTechnician == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teknisyen seçin')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && selectedTechnician != null) {
      try {
        await _ticketService.convertTicket(
          ticket.id,
          ConvertTicketRequest(
            technicianId: selectedTechnician!.userId,
            technicianName: selectedTechnician!.name,
            priority: _operationPriorityFromTicket(ticket.priority),
            operationType: 'Repair',
            internalNote: noteController.text.trim(),
          ),
        );
        if (mounted) {
          _refreshTicket();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Talep operasyona dönüştürüldü')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Onay başarısız: $e')),
          );
        }
      }
    }
  }

  Future<void> _rejectTicket(Ticket ticket) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gerekçe zorunlu')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Reddet'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _ticketService.rejectTicket(
            ticket.id, reasonController.text.trim());
        if (mounted) {
          _refreshTicket();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Talep reddedildi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reddetme başarısız: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Ticket>(
      future: _ticketFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text(snapshot.error.toString())),
          );
        }
        final ticket = snapshot.data!;
        final statusLabel = _statusLabel(ticket.status);
        final statusColor = _statusColor(ticket.status);
        final canApprove = ticket.status == 'Open';
        final canReject = ticket.status == 'Open';

        return LinearPageShell(
          title: 'Talep Detayı',
          subtitle: _shortId(ticket.id),
          showBack: true,
          tabBar: const SizedBox.shrink(),
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.more_vert_rounded,
                color: Colors.white, size: 18),
          ),
          children: [
            LinearCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LinearBadge(label: statusLabel, color: statusColor),
                      Text(_formatDate(ticket.createdAtUtc),
                          style: const TextStyle(
                              color: AppColors.textTertiary, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(ticket.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text(ticket.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const LinearSection(title: 'Cihaz ve Kullanıcı Bilgisi'),
            LinearCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _DetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Talep Eden',
                      value: _shortId(ticket.customerId)),
                  _DetailRow(
                      icon: Icons.laptop_mac_rounded,
                      label: 'Cihaz',
                      value: ticket.deviceId ?? 'Cihaz bilgisi yok'),
                  _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Durum',
                      value: statusLabel,
                      showDivider: false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canApprove ? () => _approveTicket(ticket) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm)),
                    ),
                    child: const Text('Talebi Onayla (İş Emri Oluştur)',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: canReject ? () => _rejectTicket(ticket) : null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.statusRed),
                      foregroundColor: AppColors.statusRed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm)),
                    ),
                    child: const Text('Talebi Reddet',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const LinearSection(title: 'İşlem Geçmişi'),
            LinearCard(
              child: Column(
                children: [
                  _HistoryItem(
                      label: 'Talep oluşturuldu',
                      time: _formatTime(ticket.createdAtUtc),
                      isFirst: true,
                      isLast: ticket.status == 'Open'),
                  if (ticket.status != 'Open')
                    _HistoryItem(
                        label: 'Durum: $statusLabel',
                        time: _formatTime(DateTime.now()),
                        isLast: true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id;

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day.$month.$year, $hour:$minute';
}

String _formatTime(DateTime dt) {
  final local = dt.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'createdoperation':
      return 'Operasyon';
    case 'closed':
      return 'Çözüldü';
    case 'rejected':
      return 'Reddedildi';
    default:
      return 'Açık';
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'createdoperation':
      return AppColors.statusYellow;
    case 'closed':
      return AppColors.statusGreen;
    case 'rejected':
      return AppColors.statusRed;
    default:
      return AppColors.statusBlue;
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

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.showDivider = true});
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 1))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 11)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem(
      {required this.label,
      required this.time,
      this.isFirst = false,
      this.isLast = false});
  final String label;
  final String time;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: isFirst ? AppColors.accent : AppColors.border,
                  shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(width: 2, height: 20, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(time,
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
