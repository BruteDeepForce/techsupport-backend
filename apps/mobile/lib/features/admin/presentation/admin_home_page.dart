import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../customer/data/customer_service.dart';
import '../../device/data/device_service.dart';
import '../../device/model/device_model.dart';
import '../../operations/data/operation_service.dart';
import '../../operations/models/operation_models.dart';
import '../../reports/data/reports_service.dart';
import '../../reports/models/report_models.dart';
import '../../stock/data/stock_service.dart';
import '../../stock/models/stock_models.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';
import 'admin_tickets_page.dart';
import 'admin_devices_page.dart';
import 'admin_team_page.dart';
import 'admin_work_orders_page.dart';
import 'admin_ai_autonomous_page.dart';
import 'inventory_management_page.dart';
import 'admin_accounting_page.dart';
import 'package:techsupport_mobile/core/design/admin_design.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final ReportsService _reportsService = ReportsService();
  final OperationService _operationService = OperationService();
  final StockService _stockService = StockService();
  final CustomerService _customerService = CustomerService();
  final DeviceService _deviceService = DeviceService();
  final TechnicianService _technicianService = TechnicianService();

  // Metrics we map into the UI. Default values keep UI identical until data loads.
  String totalValue = '0';
  String resolutionRate = '0%';
  String criticalCount = '0';

  String openCount = '0';
  String inProgressCount = '0';
  String resolvedCount = '0';

  String maintenanceCount = '0';
  String personnelCount = '0';
  String stockTotalCount = '0';
  String stockCriticalCount = '0';
  String stockReservedCount = '0';

  // Selected period for metrics display. Options: 'Daily', 'Monthly', 'AllTime'
  String _selectedPeriod = 'AllTime';

  List<OperationRecord> recentOperations = [];
  bool _loadingDashboard = true;

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    try {
      setState(() => _loadingDashboard = true);
      final results = await Future.wait<dynamic>([
        _reportsService.getDashboard(),
        _operationService.listOperations(),
        _stockService.listItems(),
        _technicianService.listTechnicians(),
      ]);

      final dashboard = results[0] as TenantDashboard;
      final operations = (results[1] as List<OperationRecord>)
        ..sort((a, b) => b.occurredAtUtc.compareTo(a.occurredAtUtc));
      final stockItems = results[2] as List<StockItem>;
      final technicians = results[3] as List<Technician>;
      final summary = dashboard.summary;

      final completed =
          summary.completedOperations + summary.deliveredOperations;
      final total = summary.totalOperations;
      final resolution =
          total > 0 ? '${((completed / total) * 100).round()}%' : '0%';
      final inProgress = operations
          .where((op) =>
              op.status.toLowerCase() == 'repairing' ||
              op.status.toLowerCase() == 'diagnosing' ||
              op.status.toLowerCase() == 'testing')
          .length;
      final critical = operations
          .where((op) =>
              op.priority.toLowerCase() == 'urgent' ||
              op.priority.toLowerCase() == 'high')
          .length;
      final stockTotal =
          stockItems.fold<int>(0, (sum, item) => sum + item.quantityAvailable);
      final stockCritical =
          stockItems.where((item) => item.quantityAvailable <= 3).length;
      final stockReserved =
          stockItems.fold<int>(0, (sum, item) => sum + item.quantityReserved);

      var nextTotalValue = totalValue;
      var nextResolutionRate = resolutionRate;
      var nextCriticalCount = criticalCount;
      var nextOpenCount = openCount;
      var nextInProgressCount = inProgressCount;
      var nextResolvedCount = resolvedCount;
      var nextMaintenanceCount = maintenanceCount;
      var nextPersonnelCount = personnelCount;
      nextTotalValue = total.toString();
      nextResolutionRate = resolution;
      nextCriticalCount = critical.toString();
      nextOpenCount = summary.openOperations.toString();
      nextInProgressCount = inProgress.toString();
      nextResolvedCount = completed.toString();
      nextMaintenanceCount = dashboard.plannedOperations.length.toString();
      nextPersonnelCount = technicians.length.toString();
      if (!mounted) return;
      setState(() {
        totalValue = nextTotalValue;
        resolutionRate = nextResolutionRate;
        criticalCount = nextCriticalCount;
        openCount = nextOpenCount;
        inProgressCount = nextInProgressCount;
        resolvedCount = nextResolvedCount;
        maintenanceCount = nextMaintenanceCount;
        personnelCount = nextPersonnelCount;
        stockTotalCount = stockTotal.toString();
        stockCriticalCount = stockCritical.toString();
        stockReservedCount = stockReserved.toString();
        recentOperations = operations.take(5).toList();
        _loadingDashboard = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingDashboard = false);
    }
  }

  Future<void> _showQuickOperationForm() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedCustomerId;
    String? selectedCustomerUserId;
    String? selectedCustomerName;
    String? selectedDeviceId;
    String? selectedTechnicianId;
    String? selectedTechnicianName;
    Future<List<DeviceRecord>>? devicesFuture;
    String priority = 'Normal';
    String type = 'Repair';

    final customers = await _customerService.listCustomers();
    final technicians = await _technicianService.listTechnicians();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminTechColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hızlı İş Emri',
                        style: TextStyle(
                            color: AdminTechColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedCustomerId,
                      items: [
                        for (final c in customers)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (v) {
                        final match =
                            customers.where((c) => c.id == v).toList();
                        setLocalState(() {
                          selectedCustomerId = v;
                          selectedCustomerUserId =
                              match.isEmpty ? null : match.first.appUserId;
                          selectedCustomerName =
                              match.isEmpty ? null : match.first.name;
                          selectedDeviceId = null;
                          if (selectedCustomerUserId != null &&
                              selectedCustomerUserId!.isNotEmpty) {
                            devicesFuture = _deviceService
                                .getCustomerDevices(selectedCustomerUserId);
                          } else {
                            devicesFuture = Future.value([]);
                          }
                        });
                      },
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Müşteri seçin' : null,
                      decoration: const InputDecoration(labelText: 'Müşteri'),
                    ),
                    const SizedBox(height: 10),
                    if (devicesFuture == null)
                      const _QuickFormHint('Önce müşteri seçin')
                    else
                      FutureBuilder<List<DeviceRecord>>(
                        future: devicesFuture,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const _QuickFormHint(
                                'Cihazlar yükleniyor...');
                          }
                          if (snap.hasError) {
                            return const _QuickFormHint('Cihazlar yüklenemedi');
                          }
                          final devices = snap.data ?? [];
                          if (devices.isEmpty) {
                            return const _QuickFormHint(
                                'Müşteriye bağlı cihaz bulunamadı');
                          }
                          return DropdownButtonFormField<String>(
                            value: selectedDeviceId,
                            items: [
                              for (final d in devices)
                                DropdownMenuItem(
                                  value: d.id,
                                  child: Text('${d.brand} ${d.model}'),
                                ),
                            ],
                            onChanged: (v) =>
                                setLocalState(() => selectedDeviceId = v),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Cihaz seçin' : null,
                            decoration:
                                const InputDecoration(labelText: 'Cihaz'),
                          );
                        },
                      ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: titleController,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Başlık girin' : null,
                      decoration: const InputDecoration(labelText: 'Başlık'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Açıklama girin'
                          : null,
                      decoration: const InputDecoration(labelText: 'Açıklama'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      value: selectedTechnicianId,
                      hint: const Text('Teknisyen seçme'),
                      items: [
                        for (final t in technicians)
                          DropdownMenuItem<String?>(
                              value: t.userId, child: Text(t.name)),
                      ],
                      onChanged: (v) {
                        final match =
                            technicians.where((t) => t.userId == v).toList();
                        setLocalState(() {
                          selectedTechnicianId = v;
                          selectedTechnicianName =
                              match.isEmpty ? null : match.first.name;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Teknisyen'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: priority,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Low', child: Text('Düşük')),
                              DropdownMenuItem(
                                  value: 'Normal', child: Text('Normal')),
                              DropdownMenuItem(
                                  value: 'High', child: Text('Yüksek')),
                              DropdownMenuItem(
                                  value: 'Urgent', child: Text('Acil')),
                            ],
                            onChanged: (v) =>
                                setLocalState(() => priority = v ?? 'Normal'),
                            decoration:
                                const InputDecoration(labelText: 'Öncelik'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: type,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Repair', child: Text('Onarım')),
                              DropdownMenuItem(
                                  value: 'Maintenance', child: Text('Bakım')),
                              DropdownMenuItem(
                                  value: 'Installation',
                                  child: Text('Kurulum')),
                            ],
                            onChanged: (v) =>
                                setLocalState(() => type = v ?? 'Repair'),
                            decoration: const InputDecoration(labelText: 'Tür'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          await _operationService.createOperation(
                            customerId: selectedCustomerId!,
                            deviceId: selectedDeviceId!,
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            technicianId: selectedTechnicianId,
                            technicianName: selectedTechnicianName,
                            customerName: selectedCustomerName,
                            priority: priority,
                            type: type,
                          );
                          if (!mounted) return;
                          Navigator.of(ctx).pop();
                          _loadReportsData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('İş emri oluşturuldu')),
                          );
                        },
                        child: const Text('İş Emri Oluştur'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearPageShell.dark(
      title: 'Genel Bakış',
      subtitle: 'Admin Portal',
      trailing: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AdminTechColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AdminTechColors.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text('AU',
            style: TextStyle(
                color: AdminTechColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
      ),
      tabBar: LinearTabBar(
        items: [
          const LinearTabItem(
              icon: Icons.grid_view_rounded, label: 'Bakış', active: true),
          LinearTabItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Talep',
            count: 6,
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                transitionDuration: Duration.zero,
              ),
            ),
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
        // Period selector for metrics (Günlük / Aylık / Tümü)

        const SizedBox(height: 12),
        // ── AI Autonomous Mode Card (Corporate Blue Edition) ───────────────
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminAIAutonomousPage())),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 8, 0, 168),
                  AdminTechColors.primary.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AdminTechColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Otonom Yönetim',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Otomasyon ve Akıllı Servis Merkezi',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 14),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: _showQuickOperationForm,
          child: LinearCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminTechColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: const Icon(Icons.add_task_rounded,
                      color: AdminTechColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Hızlı İş Emri',
                          style: TextStyle(
                              color: AdminTechColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 3),
                      Text('Müşteri, cihaz ve açıklama ile hızlı kayıt aç',
                          style: TextStyle(
                              color: AdminTechColors.textTertiary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AdminTechColors.textTertiary, size: 14),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Unified metrics strip (Separated Cards) ────────────────
        LinearCard(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              children: [
                _MetricCell(
                    value: totalValue,
                    label: 'Toplam',
                    color: AdminTechColors.primary),
                const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AdminTechColors.borderSubtle),
                _MetricCell(
                    value: resolutionRate,
                    label: 'Çözüm Oranı',
                    color: AdminTechColors.textPrimary),
                const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AdminTechColors.borderSubtle),
                _MetricCell(
                    value: criticalCount,
                    label: 'Kritik',
                    color: AdminTechColors.statusGreen),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        LinearCard(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              children: [
                _MetricCell(
                    value: openCount,
                    label: 'Açık',
                    color: AdminTechColors.statusAmber),
                const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AdminTechColors.borderSubtle),
                _MetricCell(
                    value: inProgressCount,
                    label: 'Devam',
                    color: AdminTechColors.statusBlue),
                const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AdminTechColors.borderSubtle),
                _MetricCell(
                    value: resolvedCount,
                    label: 'Çözüldü',
                    color: AdminTechColors.statusGreen),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Recent operations ─────────────────────────────────────
        LinearSection(
          title: 'Son İş Emirleri',
          trailing: GestureDetector(
            child: Text('Tümü',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AdminTechColors.primary)),
          ),
        ),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < recentOperations.length; i++)
                LinearIssueRow(
                  id: _shortId(recentOperations[i].id),
                  title: recentOperations[i].title,
                  priority: _priorityColor(recentOperations[i].priority),
                  statusColor: _statusColor(recentOperations[i].status),
                  label: _statusLabel(recentOperations[i].status),
                  labelColor: AdminTechColors.textTertiary,
                  assignee: recentOperations[i].technicianName.isEmpty
                      ? null
                      : recentOperations[i].technicianName,
                  showDivider: i != recentOperations.length - 1,
                  onTap: () => Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const AdminWorkOrdersPage(),
                      transitionDuration: Duration.zero,
                    ),
                  ),
                ),
              if (recentOperations.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(_loadingDashboard
                        ? 'Yükleniyor...'
                        : 'Henüz iş emri bulunmuyor'),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Inventory Status ─────────────────────────────────────
        const LinearSection(title: 'Stok Yönetimi'),
        LinearCard(
          child: Column(
            children: [
              _ProgressRow(
                  label: 'Toplam Stok',
                  count: stockTotalCount,
                  color: AdminTechColors.primary,
                  pct: _stockPct(stockTotalCount, stockTotalCount)),
              const SizedBox(height: 12),
              _ProgressRow(
                  label: 'Kritik Seviye',
                  count: stockCriticalCount,
                  color: AdminTechColors.statusRed,
                  pct: _stockPct(stockCriticalCount, stockTotalCount)),
              const SizedBox(height: 12),
              _ProgressRow(
                  label: 'Rezerve',
                  count: stockReservedCount,
                  color: AdminTechColors.statusBlue,
                  pct: _stockPct(stockReservedCount, stockTotalCount)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.count,
    required this.color,
    required this.pct,
  });

  final String label;
  final String count;
  final Color color;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(1)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            Text(count, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 4,
            backgroundColor: AdminTechColors.surfaceRaised,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _QuickFormHint extends StatelessWidget {
  const _QuickFormHint(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AdminTechColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AdminTechColors.borderSubtle),
      ),
      child: Text(
        label,
        style:
            const TextStyle(color: AdminTechColors.textTertiary, fontSize: 12),
      ),
    );
  }
}

String _shortId(String id) {
  if (id.isEmpty) return '-';
  return id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
}

double _stockPct(String value, String total) {
  final current = int.tryParse(value) ?? 0;
  final max = int.tryParse(total) ?? 0;
  if (max <= 0) return 0;
  final pct = current / max;
  if (pct < 0) return 0;
  if (pct > 1) return 1;
  return pct;
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
      return AdminTechColors.statusGreen;
    case 'waitingforapproval':
    case 'repairing':
    case 'testing':
      return AdminTechColors.statusAmber;
    case 'diagnosing':
      return AdminTechColors.statusBlue;
    default:
      return AdminTechColors.statusGray;
  }
}

Color _priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
    case 'high':
      return AdminTechColors.statusRed;
    case 'low':
      return AdminTechColors.statusGray;
    default:
      return AdminTechColors.statusBlue;
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AdminTechColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
