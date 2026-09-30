import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../operations/data/operation_service.dart';
import '../../operations/models/operation_models.dart';
import 'admin_home_page.dart';
import 'admin_tickets_page.dart';
import 'admin_devices_page.dart';
import 'admin_team_page.dart';
import 'admin_accounting_page.dart';
import 'inventory_management_page.dart';

class AdminWorkOrdersPage extends StatefulWidget {
  const AdminWorkOrdersPage({super.key});

  @override
  State<AdminWorkOrdersPage> createState() => _AdminWorkOrdersPageState();
}

class _AdminWorkOrdersPageState extends State<AdminWorkOrdersPage> {
  final OperationService _operationService = OperationService();
  late Future<List<OperationRecord>> _operationsFuture;
  int _selectedFilterIndex = 0;

  static const List<String> _filterLabels = [
    'Aktif',
    'Bekleyen',
    'Biten',
    'Planlı',
  ];

  @override
  void initState() {
    super.initState();
    _operationsFuture = _operationService.listOperations();
  }

  void _refresh() {
    setState(() {
      _operationsFuture = _operationService.listOperations();
    });
  }

  List<OperationRecord> _filterOperations(List<OperationRecord> operations) {
    switch (_selectedFilterIndex) {
      case 1:
        return operations
            .where((op) => op.status.toLowerCase() == 'waitingforapproval')
            .toList();
      case 2:
        return operations
            .where((op) =>
                op.status.toLowerCase() == 'completed' ||
                op.status.toLowerCase() == 'delivered')
            .toList();
      case 3:
        return operations
            .where((op) => op.future.toLowerCase() == 'scheduled')
            .toList();
      default:
        return operations
            .where((op) =>
                op.status.toLowerCase() != 'completed' &&
                op.status.toLowerCase() != 'delivered')
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'İş Emirleri',
      subtitle: 'Admin Portal',
      trailing: InkWell(
        onTap: _refresh,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
        ),
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
          LinearTabItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Talepler',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          const LinearTabItem(
            icon: Icons.assignment_rounded,
            label: 'İş Emri',
            active: true,
          ),
          LinearTabItem(
            icon: Icons.devices_other_outlined,
            label: 'Cihazlar',
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
          LinearTabItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Muhasebe',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminAccountingPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('İş Emri Yönetimi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Operasyon kayıtları backend üzerinden listelenir.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const AdminHomePage(),
                    transitionDuration: Duration.zero,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.accent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
                ),
                child: const Text('Hızlı Giriş', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _WorkOrderFilterTabs(
          labels: _filterLabels,
          selectedIndex: _selectedFilterIndex,
          onChanged: (index) => setState(() => _selectedFilterIndex = index),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<OperationRecord>>(
          future: _operationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearCard(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.hasError) {
              return LinearCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('İş emirleri yüklenemedi'),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _refresh, child: const Text('Tekrar dene')),
                  ],
                ),
              );
            }
            final operations = (snapshot.data ?? [])
              ..sort((a, b) => b.occurredAtUtc.compareTo(a.occurredAtUtc));
            final filtered = _filterOperations(operations);
            return Column(
              children: [
                LinearSection(title: _filterLabels[_selectedFilterIndex], count: filtered.length),
                LinearCard(
                  padding: EdgeInsets.zero,
                  child: filtered.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('İş emri bulunamadı'),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < filtered.length; i++)
                              _WorkOrderRow(
                                id: _shortId(filtered[i].id),
                                title: filtered[i].title,
                                tech: filtered[i].technicianName.isEmpty ? '-' : filtered[i].technicianName,
                                status: _statusLabel(filtered[i].status),
                                statusColor: _statusColor(filtered[i].status),
                                customer: filtered[i].customerName,
                                scheduledAtUtc: filtered[i].scheduledAtUtc,
                                showDivider: i != filtered.length - 1,
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WorkOrderRow extends StatelessWidget {
  const _WorkOrderRow({
    required this.id,
    required this.title,
    required this.tech,
    required this.status,
    required this.statusColor,
    this.customer,
    this.scheduledAtUtc,
    this.showDivider = true,
  });
  final String id;
  final String title;
  final String tech;
  final String status;
  final Color statusColor;
  final String? customer;
  final DateTime? scheduledAtUtc;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(AppRadius.xs)),
            child: Icon(Icons.build_circle_outlined, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(id, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    LinearBadge(label: status, color: statusColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'Müşteri: ${customer == null || customer!.isEmpty ? '-' : customer} • Teknisyen: $tech',
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
                if (scheduledAtUtc != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Plan: ${_formatDateTime(scheduledAtUtc!)}',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.border, size: 20),
        ],
      ),
    );
  }
}

class _WorkOrderFilterTabs extends StatelessWidget {
  const _WorkOrderFilterTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppColors.bgElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
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
      return 'Onay';
    case 'repairing':
      return 'Onarım';
    case 'testing':
      return 'Test';
    case 'completed':
      return 'Bitti';
    case 'delivered':
      return 'Teslim';
    default:
      return 'Aktif';
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'delivered':
      return AppColors.statusGreen;
    case 'waitingforapproval':
    case 'repairing':
    case 'testing':
      return AppColors.statusOrange;
    case 'diagnosing':
      return AppColors.statusBlue;
    default:
      return AppColors.statusGreen;
  }
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day.$month.${local.year} $hour:$minute';
}
