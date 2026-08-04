import 'package:flutter/material.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/data/hr_services.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/model/hr_models.dart';

class AdminWebHrPerformanceSectionPage extends StatefulWidget {
  const AdminWebHrPerformanceSectionPage({
    super.key,
    required this.onOpenEmployee,
  });

  final void Function(String? employeeId, String employeeName) onOpenEmployee;

  @override
  State<AdminWebHrPerformanceSectionPage> createState() =>
      _AdminWebHrPerformanceSectionPageState();
}

class _AdminWebHrPerformanceSectionPageState
    extends State<AdminWebHrPerformanceSectionPage> {
  final HRService _hrService = HRService();
  late Future<_PerformanceSectionData> _pageFuture;
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _pageFuture = _loadPage();
  }

  Future<_PerformanceSectionData> _loadPage() async {
    final results = await Future.wait([
      _hrService.getPerformanceReports(
        year: _selectedYear,
        month: _selectedMonth,
      ),
      _hrService.getLargeDetailEmployees(),
    ]);

    return _PerformanceSectionData(
      reports: results[0] as List<HRPerformanceReportResponse>,
      employees: results[1] as HREmployeeLargeDetailResponse,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _pageFuture = _loadPage();
    });
  }

  Future<void> _showPerformanceDetailDialog(_PerformanceRowData row) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _PerformanceDetailDialog(
        hrService: _hrService,
        employeeId: row.employeeId,
        employeeName: row.employeeName,
        year: _selectedYear,
        month: _selectedMonth,
        onOpenEmployee: () {
          Navigator.of(context).pop();
          widget.onOpenEmployee(row.employeeId, row.employeeName);
        },
      ),
    );
  }

  List<int> _yearOptions() {
    final currentYear = DateTime.now().year;
    return List<int>.generate(5, (index) => currentYear - 2 + index);
  }

  static const List<_MonthOption> _monthOptions = [
    _MonthOption(1, 'Ocak'),
    _MonthOption(2, 'Şubat'),
    _MonthOption(3, 'Mart'),
    _MonthOption(4, 'Nisan'),
    _MonthOption(5, 'Mayıs'),
    _MonthOption(6, 'Haziran'),
    _MonthOption(7, 'Temmuz'),
    _MonthOption(8, 'Ağustos'),
    _MonthOption(9, 'Eylül'),
    _MonthOption(10, 'Ekim'),
    _MonthOption(11, 'Kasım'),
    _MonthOption(12, 'Aralık'),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PerformanceSectionData>(
      future: _pageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _PerformanceCardShell(
            child: Text('Performans verileri yüklenemedi: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const _PerformanceCardShell(
            child: Text('Performans verisi bulunamadı.'),
          );
        }

        final data = snapshot.data!;
        final employeeMap = {
          for (final employee in data.employees.employees) employee.id: employee,
        };

        final rows = data.reports
            .map(
              (report) => _PerformanceRowData(
                employeeId: report.employeeId,
                employeeName: employeeMap[report.employeeId]?.fullName ??
                    'Personel bulunamadı',
                positionName: employeeMap[report.employeeId]?.positionName ??
                    'Pozisyon atanmadı',
                status:
                    _resolvePerformanceStatus(report.totalOverdueTasks, report.penaltyCount),
                report: report,
              ),
            )
            .toList()
          ..sort((a, b) => b.report.totalCompletedTasks
              .compareTo(a.report.totalCompletedTasks));

        final totalCompleted = data.reports.fold<int>(
          0,
          (sum, report) => sum + report.totalCompletedTasks,
        );
        final totalPending = data.reports.fold<int>(
          0,
          (sum, report) => sum + report.totalPendingTasks,
        );
        final totalPenalties = data.reports.fold<int>(
          0,
          (sum, report) => sum + report.penaltyCount,
        );
        final totalAttendance = data.reports.fold<int>(
          0,
          (sum, report) => sum + report.shiftAttendanceCount,
        );

        final topPerformer = rows.isEmpty ? null : rows.first;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8FBFF), Color(0xFFF1F5F9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: _PerformanceSectionTitle(
                            title: 'Performans Dashboard',
                            subtitle:
                                'Aylık görev, devam ve disiplin metriklerini tek ekranda takip edin.',
                          ),
                        ),
                        const SizedBox(width: 12),
                        _PerformanceFilterBox(
                          child: DropdownButton<int>(
                            value: _selectedMonth,
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(14),
                            items: _monthOptions
                                .map(
                                  (item) => DropdownMenuItem<int>(
                                    value: item.value,
                                    child: Text(item.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedMonth = value;
                                _pageFuture = _loadPage();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        _PerformanceFilterBox(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(14),
                            items: _yearOptions()
                                .map(
                                  (year) => DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedYear = value;
                                _pageFuture = _loadPage();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Yenile'),
                        ),
                      ],
                    ),
                    if (topPerformer != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_outlined,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dönemin Öne Çıkan Personeli',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${topPerformer.employeeName} • ${topPerformer.positionName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${topPerformer.report.totalCompletedTasks} tamamlanan iş',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final cardWidth = width >= 1240
                      ? (width - 36) / 4
                      : width >= 860
                          ? (width - 12) / 2
                          : width;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _PerformanceStatCard(
                          title: 'Raporlanan Personel',
                          value: data.reports.length.toString(),
                          note: 'Seçili ay için snapshot üretilen kayıt',
                          accent: const Color(0xFF2563EB),
                          icon: Icons.groups_2_outlined,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _PerformanceStatCard(
                          title: 'Tamamlanan İş',
                          value: totalCompleted.toString(),
                          note: 'Toplam tamamlanan görev sayısı',
                          accent: const Color(0xFF16A34A),
                          icon: Icons.task_alt_outlined,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _PerformanceStatCard(
                          title: 'Bekleyen / Geciken',
                          value: '$totalPending / ${data.reports.fold<int>(0, (sum, item) => sum + item.totalOverdueTasks)}',
                          note: 'Aksiyon gerektiren görev yoğunluğu',
                          accent: const Color(0xFFD97706),
                          icon: Icons.pending_actions_outlined,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _PerformanceStatCard(
                          title: 'Ceza / Mesai Devam',
                          value: '$totalPenalties / $totalAttendance',
                          note: 'Disiplin ve vardiya devam özeti',
                          accent: const Color(0xFF7C3AED),
                          icon: Icons.analytics_outlined,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _PerformanceCardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: _PerformanceSectionTitle(
                            title: 'Personel Performans Listesi',
                            subtitle:
                                'Satıra tıklayarak detay metrik görünümünü açın.',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(999),
                            border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '${rows.length} kayıt',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Personel',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Tamamlanan',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Bekleyen',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Ceza / Ödül',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Devam',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Durum',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 44),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          if (rows.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'Seçili ay için performans snapshot kaydı bulunamadı.',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            )
                          else
                            for (var i = 0; i < rows.length; i++) ...[
                              _PerformanceTableRow(
                                data: rows[i],
                                onTap: () => _showPerformanceDetailDialog(rows[i]),
                              ),
                              if (i != rows.length - 1)
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE2E8F0),
                                ),
                            ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _resolvePerformanceStatus(int overdue, int penalties) {
    if (penalties > 0 || overdue > 3) {
      return 'Riskli';
    }
    if (overdue > 0) {
      return 'İzleniyor';
    }
    return 'Dengeli';
  }
}

class _PerformanceSectionData {
  const _PerformanceSectionData({
    required this.reports,
    required this.employees,
  });

  final List<HRPerformanceReportResponse> reports;
  final HREmployeeLargeDetailResponse employees;
}

class _PerformanceRowData {
  const _PerformanceRowData({
    required this.employeeId,
    required this.employeeName,
    required this.positionName,
    required this.status,
    required this.report,
  });

  final String employeeId;
  final String employeeName;
  final String positionName;
  final String status;
  final HRPerformanceReportResponse report;
}

class _MonthOption {
  const _MonthOption(this.value, this.label);

  final int value;
  final String label;
}

class _PerformanceDetailDialog extends StatelessWidget {
  const _PerformanceDetailDialog({
    required this.hrService,
    required this.employeeId,
    required this.employeeName,
    required this.year,
    required this.month,
    required this.onOpenEmployee,
  });

  final HRService hrService;
  final String employeeId;
  final String employeeName;
  final int year;
  final int month;
  final VoidCallback onOpenEmployee;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 760,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F0F172A),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: FutureBuilder<HRPerformanceReportResponse>(
          future: hrService.getEmployeePerformanceReport(
            employeeId,
            year: year,
            month: month,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Text('Detay yüklenemedi: ${snapshot.error}');
            }

            if (!snapshot.hasData) {
              return const Text('Detay verisi bulunamadı.');
            }

            final report = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _PerformanceSectionTitle(
                        title: employeeName,
                        subtitle: '$month.$year dönemi performans özeti',
                      ),
                    ),
                    TextButton(
                      onPressed: onOpenEmployee,
                      child: const Text('Personel Detayı'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _DetailMetricCard(
                      label: 'Atanan İş',
                      value: report.totalAssignedTasks.toString(),
                    ),
                    _DetailMetricCard(
                      label: 'Tamamlanan İş',
                      value: report.totalCompletedTasks.toString(),
                    ),
                    _DetailMetricCard(
                      label: 'Bekleyen İş',
                      value: report.totalPendingTasks.toString(),
                    ),
                    _DetailMetricCard(
                      label: 'Geciken İş',
                      value: report.totalOverdueTasks.toString(),
                    ),
                    _DetailMetricCard(
                      label: 'Zamanında',
                      value: '${report.totalCompletedOnTime ?? 0}',
                    ),
                    _DetailMetricCard(
                      label: 'Geç Tamamlanan',
                      value: '${report.totalCompletedLate ?? 0}',
                    ),
                    _DetailMetricCard(
                      label: 'Ödül',
                      value: report.rewardCount.toString(),
                    ),
                    _DetailMetricCard(
                      label: 'Ceza',
                      value: report.penaltyCount.toString(),
                    ),
                    _DetailMetricCard(
                      label: 'İzin',
                      value: report.leaveCount.toString(),
                    ),
                    _DetailMetricCard(
                      label: 'Vardiya Katılım',
                      value: report.shiftAttendanceCount.toString(),
                    ),
                    _DetailMetricCard(
                      label: 'Katılınmayan Vardiya',
                      value: report.notJoinedShiftCount.toString(),
                    ),
                    _DetailMetricCard(
                      label: 'Mesai',
                      value: report.overtimeCount.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kapat'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PerformanceTableRow extends StatelessWidget {
  const _PerformanceTableRow({
    required this.data,
    required this.onTap,
  });

  final _PerformanceRowData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (data.status) {
      'Riskli' => const Color(0xFFDC2626),
      'İzleniyor' => const Color(0xFFD97706),
      _ => const Color(0xFF16A34A),
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.employeeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.positionName,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Expanded(child: Text('${data.report.totalCompletedTasks}')),
            Expanded(child: Text('${data.report.totalPendingTasks}')),
            Expanded(
              child: Text(
                '${data.report.penaltyCount} / ${data.report.rewardCount}',
              ),
            ),
            Expanded(
              child: Text(
                '${data.report.shiftAttendanceCount} / ${data.report.notJoinedShiftCount}',
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.chevron_right_rounded),
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceStatCard extends StatelessWidget {
  const _PerformanceStatCard({
    required this.title,
    required this.value,
    required this.note,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String value;
  final String note;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMetricCard extends StatelessWidget {
  const _DetailMetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCardShell extends StatelessWidget {
  const _PerformanceCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PerformanceSectionTitle extends StatelessWidget {
  const _PerformanceSectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _PerformanceFilterBox extends StatelessWidget {
  const _PerformanceFilterBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(child: child),
    );
  }
}
