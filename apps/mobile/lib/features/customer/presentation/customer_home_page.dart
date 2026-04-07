import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../tickets/data/ticket_service.dart';
import '../../tickets/models/ticket_models.dart';
import 'customer_offers_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
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

  Future<void> _openCreateTicketDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String priority = 'Normal';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Talep'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Örn. Laptop açılmıyor',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Detayları yazın',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                items: const [
                  DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'High', child: Text('Yüksek')),
                  DropdownMenuItem(value: 'Urgent', child: Text('Acil')),
                ],
                onChanged: (value) {
                  if (value != null) priority = value;
                },
                decoration: const InputDecoration(labelText: 'Öncelik'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();
                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Başlık ve açıklama zorunlu')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Oluştur'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await _ticketService.createTicket(TicketCreateRequest(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          priority: priority,
        ));
        if (mounted) {
          _refreshTickets();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Talep oluşturuldu')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Talep oluşturulamadı')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearPageShell(
      title: 'Müşteri',
      subtitle: 'Müşteri Portalı',
      trailing: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text('AM',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
      ),
      tabBar: LinearTabBar(
        items: [
          const LinearTabItem(
              icon: Icons.grid_view_rounded, label: 'Ana Sayfa', active: true),
          LinearTabItem(
            icon: Icons.local_offer_outlined,
            label: 'Teklifler',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const CustomerOffersPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          const LinearTabItem(
              icon: Icons.devices_other_outlined, label: 'Cihazlar'),
          const LinearTabItem(icon: Icons.logout_rounded, label: 'Çıkış'),
        ],
      ),
      children: [
        FutureBuilder<List<Ticket>>(
          future: _ticketsFuture,
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
                    const Text('Talepler yüklenemedi'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: _refreshTickets,
                          child: const Text('Tekrar dene'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _openCreateTicketDialog,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('İş talebi oluştur'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            final tickets = snapshot.data ?? [];
            final openCount = tickets.where((t) => t.status == 'Open').length;
            final inProgressCount =
                tickets.where((t) => t.status == 'CreatedOperation').length;
            final closedCount =
                tickets.where((t) => t.status == 'Closed').length;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: LinearStatPill(
                            value: openCount.toString(),
                            label: 'Açık',
                            color: AppColors.statusBlue)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: LinearStatPill(
                            value: inProgressCount.toString(),
                            label: 'Devam Eden',
                            color: AppColors.statusYellow)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: LinearStatPill(
                            value: closedCount.toString(),
                            label: 'Çözülen',
                            color: AppColors.statusGreen)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearCommand(
                        icon: Icons.add_rounded,
                        label: 'Yeni Talep',
                        onTap: _openCreateTicketDialog,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearCommand(
                        icon: Icons.search_rounded,
                        label: 'Takip Et',
                        onTap: _refreshTickets,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearSection(
                  title: 'Son Talepler',
                  count: tickets.length,
                ),
                LinearCard(
                  padding: EdgeInsets.zero,
                  child: tickets.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Açılmış iş talebi yok'),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _openCreateTicketDialog,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('İş talebi oluştur'),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < tickets.length; i++)
                              LinearIssueRow(
                                id: _shortId(tickets[i].id),
                                title: tickets[i].title,
                                priority: _priorityColor(tickets[i].priority),
                                statusColor: _statusColor(tickets[i].status),
                                label: _statusLabel(tickets[i].status),
                                labelColor: _statusColor(tickets[i].status),
                                showDivider: i != tickets.length - 1,
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const LinearSection(title: 'Cihazlarım', count: 2),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _DeviceRow(
                title: 'Office Laptop #1',
                subtitle: 'Dell XPS 15  ·  DXP15-001-2024',
                status: 'Aktif',
                statusColor: AppColors.statusGreen,
              ),
              _DeviceRow(
                title: 'Reception Printer',
                subtitle: 'HP LaserJet Pro  ·  HPL-REC-2023',
                status: 'Bakımda',
                statusColor: AppColors.statusYellow,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id;

Color _priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return AppColors.statusRed;
    case 'high':
      return AppColors.statusOrange;
    default:
      return AppColors.statusBlue;
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'createdoperation':
      return AppColors.statusYellow;
    case 'repairing':
      return const Color.fromARGB(255, 15, 11, 245);
    case 'closed':
      return AppColors.statusGreen;
    case 'rejected':
      return AppColors.statusRed;
    default:
      return AppColors.statusBlue;
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'createdoperation':
      return 'İşlem Başlatıldı';
    case 'repairing':
      return 'Onarım/Bakım';
    case 'closed':
      return 'Kapalı';
    case 'rejected':
      return 'Reddedildi';
    default:
      return 'Yeni Talep';
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          const Icon(Icons.devices_other_outlined,
              color: AppColors.textTertiary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          LinearBadge(label: status, color: statusColor),
        ],
      ),
    );
  }
}
