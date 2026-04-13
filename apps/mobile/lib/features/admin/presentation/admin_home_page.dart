import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../reports/data/reports_service.dart';
import '../../reports/models/report_models.dart';
import 'admin_tickets_page.dart';
import 'admin_devices_page.dart';
import 'admin_team_page.dart';
import 'admin_work_orders_page.dart';
import 'admin_ai_autonomous_page.dart';
import 'inventory_management_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final ReportsService _reportsService = ReportsService();

  // Metrics we map into the UI. Default values keep UI identical until data loads.
  String totalValue = '0';
  String resolutionRate = '0%';
  String criticalCount = '0';

  String openCount = '0';
  String inProgressCount = '0';
  String resolvedCount = '0';

  String devicesCount = '0';
  String maintenanceCount = '0';
  String personnelCount = '0';

  // Selected period for metrics display. Options: 'Daily', 'Monthly', 'AllTime'
  String _selectedPeriod = 'AllTime';

  List<ReportSummary> recentReports = [];

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    try {
      final metrics = await _reportsService.getMetrics();

      // Group metrics by metricType (case-insensitive) for easier lookup.
      final Map<String, List<ReportMetric>> byType = {};
      for (final m in metrics) {
        final key = m.metricType.toLowerCase();
        byType.putIfAbsent(key, () => []).add(m);
      }

      // Helper to pick the most relevant value for a metricType based on
      // the currently selected period: Daily, Monthly or AllTime.
      int? pickValue(String metricType) {
        final list = byType[metricType.toLowerCase()];
        if (list == null || list.isEmpty) return null;

        // If user selected AllTime, prefer periodType == AllTime
        if (_selectedPeriod == 'AllTime') {
          for (final e in list) {
            if (e.periodType.toLowerCase() == 'alltime') return e.value;
          }
          // fallback to most recent daily or any
        }

        // If user selected Monthly, try to find a Monthly periodType first.
        if (_selectedPeriod == 'Monthly') {
          for (final e in list) {
            if (e.periodType.toLowerCase() == 'monthly') return e.value;
          }
          // As a fallback, choose the latest daily within this month
          final now = DateTime.now().toUtc();
          final monthMatches = list.where((e) {
            if (e.periodDate == null) return false;
            try {
              final d = DateTime.parse(e.periodDate!);
              return d.year == now.year && d.month == now.month;
            } catch (_) {
              return false;
            }
          }).toList();
          if (monthMatches.isNotEmpty) {
            monthMatches.sort(
                (a, b) => (b.periodDate ?? '').compareTo(a.periodDate ?? ''));
            return monthMatches.first.value;
          }
          // otherwise fall back to AllTime or any
        }

        // If user selected Daily, prefer the latest daily entry.
        if (_selectedPeriod == 'Daily') {
          final daily =
              list.where((e) => e.periodType.toLowerCase() == 'daily').toList();
          if (daily.isNotEmpty) {
            daily.sort(
                (a, b) => (b.periodDate ?? '').compareTo(a.periodDate ?? ''));
            return daily.first.value;
          }
        }

        // Generic fallback order: AllTime -> latest daily -> any
        for (final e in list) {
          if (e.periodType.toLowerCase() == 'alltime') return e.value;
        }
        list.sort((a, b) => (b.periodDate ?? '').compareTo(a.periodDate ?? ''));
        return list.first.value;
      }

      // Map specific backend metric types to the UI fields.
      final createdAll =
          pickValue('operationcreatedcount') ?? pickValue('operationcreated');
      final completedAll = pickValue('operationcompletedcount') ??
          pickValue('operationcompleted');
      final openAll =
          pickValue('openoperationcount') ?? pickValue('openoperation');
      final assignedAll = pickValue('operationassignedtotechniciancount') ??
          pickValue('operationassignedtotechnician');
      final customerCreatedAll =
          pickValue('customercreatedcount') ?? pickValue('customercreated');

      // Total: prefer total operations created (AllTime)
      if (createdAll != null) totalValue = createdAll.toString();

      // Resolution rate: completed / created (AllTime) -> percentage
      if (createdAll != null && completedAll != null && createdAll > 0) {
        final pct = ((completedAll / createdAll) * 100).round();
        resolutionRate = '$pct%';
      }

      // Critical: no dedicated metric in sample -> leave default unless present
      final critical =
          pickValue('criticalcount') ?? pickValue('operationcriticalcount');
      if (critical != null) criticalCount = critical.toString();

      // Second row
      if (openAll != null) openCount = openAll.toString();
      if (assignedAll != null) inProgressCount = assignedAll.toString();
      if (completedAll != null) resolvedCount = completedAll.toString();

      // Third row (best-effort mapping)
      final deviceCount = pickValue('devicecount') ?? pickValue('devicescount');
      if (deviceCount != null) devicesCount = deviceCount.toString();

      final maintenance = pickValue('maintenancecount') ??
          pickValue('operationmaintenancecount');
      if (maintenance != null) maintenanceCount = maintenance.toString();

      // Personnel: prefer a dedicated personnel/technician count, otherwise use assigned-to-technician
      final personnel =
          pickValue('personnelcount') ?? pickValue('techniciancount');
      if (personnel != null) {
        personnelCount = personnel.toString();
      } else if (assignedAll != null) {
        personnelCount = assignedAll.toString();
      } else if (customerCreatedAll != null) {
        // fallback: show customers created as a small informative stat
        personnelCount = customerCreatedAll.toString();
      }

      final page = await _reportsService.listReports(page: 1, pageSize: 5);
      setState(() {
        recentReports = page.items;
      });
    } catch (e) {
      // Swallow errors for now; UI will show default values. Could add SnackBar or error state.
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearPageShell(
      title: 'Genel Bakış',
      subtitle: 'Admin Portal',
      trailing: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text('AU',
            style: TextStyle(
                color: AppColors.textSecondary,
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
        ],
      ),
      children: [
        // Period selector for metrics (Günlük / Aylık / Tümü)
        Row(
          children: [
            const Expanded(child: SizedBox()),
            ChoiceChip(
              label: const Text('Günlük'),
              selected: _selectedPeriod == 'Daily',
              onSelected: (v) {
                if (v) {
                  setState(() => _selectedPeriod = 'Daily');
                  _loadReportsData();
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Aylık'),
              selected: _selectedPeriod == 'Monthly',
              onSelected: (v) {
                if (v) {
                  setState(() => _selectedPeriod = 'Monthly');
                  _loadReportsData();
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Tümü'),
              selected: _selectedPeriod == 'AllTime',
              onSelected: (v) {
                if (v) {
                  setState(() => _selectedPeriod = 'AllTime');
                  _loadReportsData();
                }
              },
            ),
          ],
        ),
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
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0.8)
                ],
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

        // ── Unified metrics strip (Separated Cards) ────────────────
        LinearCard(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              children: [
                _MetricCell(
                    value: totalValue,
                    label: 'Toplam',
                    color: AppColors.accent),
                const VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(
                    value: resolutionRate,
                    label: 'Çözüm Oranı',
                    color: AppColors.textPrimary),
                const VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(
                    value: criticalCount,
                    label: 'Kritik',
                    color: AppColors.statusGreen),
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
                    color: AppColors.statusYellow),
                const VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(
                    value: inProgressCount,
                    label: 'Devam',
                    color: AppColors.statusBlue),
                const VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(
                    value: resolvedCount,
                    label: 'Çözüldü',
                    color: AppColors.statusGreen),
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
                    value: devicesCount,
                    label: 'Cihaz',
                    color: AppColors.textPrimary),
                const VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(
                    value: maintenanceCount,
                    label: 'Bakımda',
                    color: AppColors.statusOrange),
                const VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.borderSubtle),
                _MetricCell(
                    value: personnelCount,
                    label: 'Personel',
                    color: AppColors.textPrimary),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Recent issues ────────────────────────────────────────
        LinearSection(
          title: 'Son Talepler',
          trailing: GestureDetector(
            child: Text('Tümü',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.accent)),
          ),
        ),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < recentReports.length; i++)
                LinearIssueRow(
                  id: recentReports[i].id.split('-').last.toUpperCase(),
                  title: recentReports[i].name,
                  priority: AppColors.statusBlue,
                  statusColor: AppColors.statusBlue,
                  label: '',
                  labelColor: AppColors.textTertiary,
                  assignee: null,
                  showDivider: i != recentReports.length - 1,
                  onTap: () => Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                      transitionDuration: Duration.zero,
                    ),
                  ),
                ),
              if (recentReports.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('Yükleniyor...')),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Device status ────────────────────────────────────────
        const LinearSection(title: 'Cihaz Durumu'),
        LinearCard(
          child: Column(
            children: const [
              _ProgressRow(
                  label: 'Aktif',
                  count: '2',
                  color: AppColors.statusGreen,
                  pct: 0.5),
              SizedBox(height: 12),
              _ProgressRow(
                  label: 'Bakımda',
                  count: '1',
                  color: AppColors.statusYellow,
                  pct: 0.25),
              SizedBox(height: 12),
              _ProgressRow(
                  label: 'Pasif',
                  count: '1',
                  color: AppColors.statusGray,
                  pct: 0.25),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Inventory Status ─────────────────────────────────────
        const LinearSection(title: 'Stok Yönetimi'),
        LinearCard(
          child: Column(
            children: const [
              _ProgressRow(
                  label: 'Yedek Parça',
                  count: '142',
                  color: AppColors.accent,
                  pct: 0.75),
              SizedBox(height: 12),
              _ProgressRow(
                  label: 'Kritik Seviye',
                  count: '3',
                  color: AppColors.statusRed,
                  pct: 0.1),
              SizedBox(height: 12),
              _ProgressRow(
                  label: 'Yolda',
                  count: '12',
                  color: AppColors.statusBlue,
                  pct: 0.15),
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
            backgroundColor: AppColors.bgElevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
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
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
