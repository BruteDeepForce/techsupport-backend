import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../tickets/data/ticket_service.dart';
import '../../tickets/models/ticket_models.dart';
import 'admin_home_page.dart';
import 'admin_devices_page.dart';
import 'admin_team_page.dart';
import 'admin_work_orders_page.dart';
import 'inventory_management_page.dart';
import 'admin_ticket_detail_page.dart';

class AdminTicketsPage extends StatefulWidget {
  const AdminTicketsPage({super.key});

  @override
  State<AdminTicketsPage> createState() => _AdminTicketsPageState();
}

class _AdminTicketsPageState extends State<AdminTicketsPage> {
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
    return LinearPageShell(
      title: 'Talepler',
      subtitle: 'Admin Portal',
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 18),
      ),
      tabBar: LinearTabBar(
        items: [
          LinearTabItem(
            icon: Icons.grid_view_rounded,
            label: 'Bakış',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminHomePage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          const LinearTabItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Talep',
            count: 6,
            active: true,
          ),
          LinearTabItem(
            icon: Icons.assignment_rounded, 
            label: 'İş Emri',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminWorkOrdersPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.devices_other_outlined, 
            label: 'Cihaz',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminDevicesPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.inventory_2_outlined,
            label: 'Stok',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const InventoryManagementPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.group_outlined, 
            label: 'Ekip',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminTeamPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
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
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refreshTickets,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              );
            }
            final tickets = snapshot.data ?? [];
            final openCount =
                tickets.where((t) => t.status == 'Open').length;
            final inProgressCount = tickets
                .where((t) => t.status == 'CreatedOperation')
                .length;
            final closedCount =
                tickets.where((t) => t.status == 'Closed').length;

            return Column(
              children: [
                LinearCard(
                  padding: EdgeInsets.zero,
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _TicketMetric(
                            value: openCount.toString(),
                            label: 'Açık',
                            color: AppColors.statusYellow),
                        const VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: AppColors.borderSubtle),
                        _TicketMetric(
                            value: inProgressCount.toString(),
                            label: 'Devam',
                            color: AppColors.statusBlue),
                        const VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: AppColors.borderSubtle),
                        _TicketMetric(
                            value: closedCount.toString(),
                            label: 'Çözüldü',
                            color: AppColors.statusGreen),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search_rounded,
                                color: AppColors.textTertiary, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Talep no veya başlık ara...',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textTertiary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _refreshTickets,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: AppColors.textSecondary, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const LinearFilterTabs(
                  labels: ['Hepsi', 'Acil', 'Kritik', 'Düşük'],
                  selectedIndex: 0,
                ),
                const SizedBox(height: 16),
                LinearSection(title: 'Aktif Talepler', count: tickets.length),
                LinearCard(
                  padding: EdgeInsets.zero,
                  child: tickets.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Talep bulunamadı'),
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
                                assignee: null,
                                showDivider: i != tickets.length - 1,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AdminTicketDetailPage(
                                          ticketId: tickets[i].id)),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
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
      return 'Operasyon';
    case 'closed':
      return 'Çözüldü';
    case 'rejected':
      return 'Reddedildi';
    default:
      return 'Açık';
  }
}

class _TicketMetric extends StatelessWidget {
  const _TicketMetric({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
