import 'package:flutter/material.dart';

import '../../reports/data/reports_service.dart';
import '../../reports/models/report_models.dart';
import 'admin_web_operation_detail_page.dart';
import 'admin_web_route.dart';
import 'shared/admin_web_design.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';

class AdminWebHomePage extends StatefulWidget {
  const AdminWebHomePage({super.key});

  @override
  State<AdminWebHomePage> createState() => _AdminWebHomePageState();
}

class _AdminWebHomePageState extends State<AdminWebHomePage> {
  final ReportsService _reportsService = ReportsService();
  late Future<TenantDashboard> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _reportsService.getDashboard();
  }

  void _reload() {
    setState(() => _dashboardFuture = _reportsService.getDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AdminWebShell(
      active: AdminNavKey.home,
      dark: true,
      actions: [
        AdminWebRefreshButton(onPressed: _reload),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommandHeader(dashboardFuture: _dashboardFuture),
          const SizedBox(height: 18),
          _KpiRow(width: width, dashboardFuture: _dashboardFuture),
          const SizedBox(height: 18),
          _PrimaryGrid(width: width, dashboardFuture: _dashboardFuture),
          const SizedBox(height: 18),
          _ScheduleCard(dashboardFuture: _dashboardFuture),
          const SizedBox(height: 18),
          _SecondaryGrid(width: width, dashboardFuture: _dashboardFuture),
        ],
      ),
    );
  }
}

class AdminWebRefreshButton extends StatelessWidget {
  const AdminWebRefreshButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Yenile',
      iconSize: 18,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.07),
        side: const BorderSide(color: AdminTechColors.panelBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.refresh_rounded,
          color: AdminTechColors.textSecondary),
    );
  }
}

/// Üst komuta başlığı: karşılama, firma ve canlı saat.
class _CommandHeader extends StatelessWidget {
  const _CommandHeader({required this.dashboardFuture});

  final Future<TenantDashboard> dashboardFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TenantDashboard>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        final tenantName = snapshot.data?.summary.tenantName ?? '';
        return AdminTechCard(
          glow: AdminTechColors.indigo,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dar ekranda etiket ve tarih alt alta iner.
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('KOMUTA MERKEZI',
                            style: adminTechLabelStyle(
                                size: 10, color: AdminTechColors.cyan)),
                        Text(
                          _nowLabel(),
                          style: adminTechLabelStyle(size: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Merhaba, Suleyman',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AdminTechColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tenantName.isEmpty
                          ? 'Operasyonlarinizin anlik durumu burada.'
                          : '$tenantName • Operasyonlarinizin anlik durumu.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AdminTechColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              const AdminTechPulseDot(),
            ],
          ),
        );
      },
    );
  }

  static String _nowLabel() {
    final now = DateTime.now();
    const weekdays = [
      'Pazartesi',
      'Sali',
      'Carsamba',
      'Persembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    const months = [
      'Ocak',
      'Subat',
      'Mart',
      'Nisan',
      'Mayis',
      'Haziran',
      'Temmuz',
      'Agustos',
      'Eylul',
      'Ekim',
      'Kasim',
      'Aralik',
    ];
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} $hour:$minute';
  }
}

/// Dört ana gösterge; her biri son altı aylık sparkline taşır.
class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.width, required this.dashboardFuture});

  final double width;
  final Future<TenantDashboard> dashboardFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TenantDashboard>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        final dashboard = snapshot.data;
        final summary = dashboard?.summary;
        final loading = snapshot.connectionState == ConnectionState.waiting;

        final completed = (summary?.completedOperations ?? 0) +
            (summary?.deliveredOperations ?? 0);
        final open = summary?.openOperations ?? 0;

        final tiles = <_KpiSpec>[
          _KpiSpec(
            label: 'ACIK IS EMRI',
            value: open,
            icon: Icons.pending_actions_rounded,
            color: AdminTechColors.amber,
            series: _monthlySeries(dashboard, 'OpenOperation'),
          ),
          _KpiSpec(
            label: 'TAMAMLANAN',
            value: completed,
            icon: Icons.task_alt_rounded,
            color: AdminTechColors.green,
            series: _monthlySeries(dashboard, 'OperationCompleted'),
          ),
          _KpiSpec(
            label: 'MUSTERI',
            value: summary?.totalCustomers ?? 0,
            icon: Icons.people_alt_rounded,
            color: AdminTechColors.cyan,
            series: _monthlySeries(dashboard, 'CustomerCreated'),
          ),
          _KpiSpec(
            label: 'TOPLAM OPERASYON',
            value: summary?.totalOperations ?? 0,
            icon: Icons.insights_rounded,
            color: AdminTechColors.violet,
            series: _monthlySeries(dashboard, 'OperationCreated'),
          ),
        ];

        final columns = width >= 1180 ? 4 : (width >= 720 ? 2 : 1);

        // Kart yüksekliği içerikten türetilir; en-boy oranı dar ekranda
        // dikey taşmaya yol açıyordu.
        return LayoutBuilder(
          builder: (context, constraints) {
            const gap = 14.0;
            final cardWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final tile in tiles)
                  SizedBox(
                    width: cardWidth,
                    height: 112,
                    child: _KpiCard(
                      spec: tile,
                      loading: loading && dashboard == null,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _KpiSpec {
  const _KpiSpec({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.series,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final List<double> series;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.spec, required this.loading});

  final _KpiSpec spec;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AdminTechCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
      glow: spec.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: spec.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: spec.color.withValues(alpha: 0.30)),
                ),
                child: Icon(spec.icon, size: 16, color: spec.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  spec.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: adminTechLabelStyle(size: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                loading ? '--' : spec.value.toString(),
                style: adminTechValueStyle(size: 27),
              ),
              const Spacer(),
              SizedBox(
                width: 78,
                child: AdminTechSparkline(
                  values: spec.series,
                  color: spec.color,
                  height: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ana ızgara: durum halkası + operasyon trendi.
class _PrimaryGrid extends StatelessWidget {
  const _PrimaryGrid({required this.width, required this.dashboardFuture});

  final double width;
  final Future<TenantDashboard> dashboardFuture;

  @override
  Widget build(BuildContext context) {
    final stacked = width < 1080;
    final status = _StatusRingCard(dashboardFuture: dashboardFuture);
    final trend = _TrendCard(dashboardFuture: dashboardFuture);

    if (stacked) {
      return Column(
        children: [status, const SizedBox(height: 18), trend],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: status),
        const SizedBox(width: 18),
        Expanded(flex: 7, child: trend),
      ],
    );
  }
}

/// İş emri durumlarının halka ve dağılım çubuğuyla özeti.
class _StatusRingCard extends StatelessWidget {
  const _StatusRingCard({required this.dashboardFuture});

  final Future<TenantDashboard> dashboardFuture;

  @override
  Widget build(BuildContext context) {
    return AdminTechCard(
      glow: AdminTechColors.green,
      child: FutureBuilder<TenantDashboard>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          final dashboard = snapshot.data;
          final summary = dashboard?.summary;
          final open = summary?.openOperations ?? 0;
          final completed = (summary?.completedOperations ?? 0) +
              (summary?.deliveredOperations ?? 0);
          final failed = summary?.failedOperations ?? 0;
          final cancelled = dashboard?.metricTotal('OperationCancelled') ?? 0;
          final total = summary?.totalOperations ?? 0;

          final segments = <({String label, int value, Color color})>[
            (label: 'Acik', value: open, color: AdminTechColors.amber),
            (
              label: 'Tamamlanan',
              value: completed,
              color: AdminTechColors.green
            ),
            (label: 'Basarisiz', value: failed, color: AdminTechColors.red),
            (label: 'Iptal', value: cancelled, color: AdminTechColors.slate),
          ];

          final ratio = total == 0 ? 0.0 : completed / total;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminTechSectionTitle(
                title: 'Is Emri Durumu',
                subtitle: 'Toplam $total kayit',
                icon: Icons.donut_large_rounded,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  AdminTechRing(
                    progress: ratio,
                    centerLabel:
                        total == 0 ? '--' : '${(ratio * 100).round()}%',
                    caption: 'TAMAMLANMA',
                    size: 116,
                    color: AdminTechColors.green,
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Column(
                      children: [
                        AdminTechDistributionBar(segments: segments),
                        const SizedBox(height: 16),
                        for (final segment in segments)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _LegendRow(
                              label: segment.label,
                              value: segment.value,
                              color: segment.color,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: AdminTechColors.textSecondary,
            ),
          ),
        ),
        Text(value.toString(), style: adminTechValueStyle(size: 14)),
      ],
    );
  }
}

enum _TrendRange { daily, weekly, monthly, last6Months }

class _TrendPoint {
  const _TrendPoint(this.label, this.value);

  final String label;
  final int value;
}

class _TrendCard extends StatefulWidget {
  const _TrendCard({required this.dashboardFuture});

  final Future<TenantDashboard> dashboardFuture;

  @override
  State<_TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<_TrendCard> {
  _TrendRange _range = _TrendRange.last6Months;

  String get _rangeLabel {
    switch (_range) {
      case _TrendRange.daily:
        return 'Son 7 Gun';
      case _TrendRange.weekly:
        return 'Son 8 Hafta';
      case _TrendRange.monthly:
        return 'Son 12 Ay';
      case _TrendRange.last6Months:
        return 'Son 6 Ay';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminTechCard(
      glow: AdminTechColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminTechSectionTitle(
            title: 'Operasyon Trendi',
            subtitle: 'Olusturulan is emri • $_rangeLabel',
            icon: Icons.show_chart_rounded,
            trailing: _RangeSelector(
              range: _range,
              onChanged: (value) => setState(() => _range = value),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<TenantDashboard>(
            future: widget.dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AdminTechPlaceholder(
                  height: 190,
                  label: 'Trend hesaplaniyor...',
                  showSpinner: true,
                );
              }
              if (snapshot.hasError) {
                return const AdminTechPlaceholder(
                  height: 190,
                  label: 'Trend verisi alinamadi',
                  icon: Icons.error_outline_rounded,
                );
              }

              final points = _buildTrend(snapshot.data, _range);
              final total = points.fold<int>(0, (sum, p) => sum + p.value);

              if (total == 0) {
                return const AdminTechPlaceholder(
                  height: 190,
                  label: 'Bu aralikta kayit bulunmuyor',
                  icon: Icons.timeline_rounded,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(total.toString(),
                          style: adminTechValueStyle(size: 30)),
                      const SizedBox(width: 8),
                      const Text(
                        'is emri',
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminTechColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _TrendAreaChart(points: points),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.range, required this.onChanged});

  final _TrendRange range;
  final ValueChanged<_TrendRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final entry in {
          _TrendRange.daily: '7G',
          _TrendRange.weekly: '8H',
          _TrendRange.monthly: '12A',
          _TrendRange.last6Months: '6A',
        }.entries)
          AdminTechPill(
            label: entry.value,
            active: range == entry.key,
            onTap: () => onChanged(entry.key),
          ),
      ],
    );
  }
}

/// Işıklandırılmış alan grafiği; yükseklik ve etiketler aynı anda verilir.
class _TrendAreaChart extends StatelessWidget {
  const _TrendAreaChart({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 170,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _AreaPainter(
                values: points.map((p) => p.value.toDouble()).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Uzun aralıklarda etiket taşmasın diye sadece bazıları gösterilir.
        Row(
          children: [
            for (var i = 0; i < points.length; i++)
              Expanded(
                child: Text(
                  points[i].label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: adminTechLabelStyle(size: 9.5),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AreaPainter extends CustomPainter {
  const _AreaPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;

    const topPad = 8.0;
    const bottomPad = 6.0;
    final chartHeight = size.height - topPad - bottomPad;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = topPad + (chartHeight / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    var maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0) maxValue = 1;

    final stepX = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    final offsets = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          stepX * i,
          topPad + chartHeight - (values[i] / maxValue) * chartHeight,
        ),
    ];

    final line = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final point in offsets.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }

    final area = Path.from(line)
      ..lineTo(offsets.last.dx, size.height)
      ..lineTo(offsets.first.dx, size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x664F46E5), Color(0x0022D3EE)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..shader = AdminTechColors.accentGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // Uç noktada vurgu halkası; grafiğin nerede bittiği belli olur.
    final last = offsets.last;
    canvas.drawCircle(last, 5.5,
        Paint()..color = AdminTechColors.cyan.withValues(alpha: 0.22));
    canvas.drawCircle(last, 3.2, Paint()..color = AdminTechColors.cyan);
  }

  @override
  bool shouldRepaint(covariant _AreaPainter oldDelegate) =>
      oldDelegate.values != values;
}

/// Yaklaşan planlı operasyonların haftalık şeridi.
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.dashboardFuture});

  final Future<TenantDashboard> dashboardFuture;

  @override
  Widget build(BuildContext context) {
    return AdminTechCard(
      glow: AdminTechColors.violet,
      child: FutureBuilder<TenantDashboard>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          final planned = snapshot.data?.plannedOperations ?? const [];
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          final days =
              List.generate(7, (i) => weekStart.add(Duration(days: i)));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminTechSectionTitle(
                title: 'Plan Takvimi',
                subtitle: _monthYearLabel(weekStart),
                icon: Icons.calendar_month_rounded,
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AdminTechColors.violet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AdminTechColors.violet.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Text(
                    '${planned.length} PLAN',
                    style: adminTechLabelStyle(
                      size: 9.5,
                      weight: FontWeight.w800,
                      color: AdminTechColors.violet,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting)
                const AdminTechPlaceholder(
                  height: 150,
                  label: 'Planlar yukleniyor...',
                  showSpinner: true,
                )
              else if (snapshot.hasError)
                const AdminTechPlaceholder(
                  height: 150,
                  label: 'Plan takvimi alinamadi',
                  icon: Icons.event_busy_rounded,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Dar ekranda yatay kaydırma; geniş ekranda yedi eşit sütun.
                    final perDay = (constraints.maxWidth / 7) < 130;
                    final strip = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final day in days)
                          Expanded(
                            child: _DayColumn(
                              day: day,
                              today: today,
                              items: planned
                                  .where((item) =>
                                      _sameDate(item.scheduledAtLocal, day))
                                  .toList()
                                ..sort((a, b) => a.scheduledAtLocal
                                    .compareTo(b.scheduledAtLocal)),
                            ),
                          ),
                      ],
                    );

                    if (!perDay) return strip;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 7 * 150,
                        child: strip,
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.today,
    required this.items,
  });

  final DateTime day;
  final DateTime today;
  final List<PlannedOperationSnapshot> items;

  @override
  Widget build(BuildContext context) {
    final isToday = _sameDate(day, today);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        constraints: const BoxConstraints(minHeight: 132),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isToday
              ? AdminTechColors.cyan.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? AdminTechColors.cyan.withValues(alpha: 0.40)
                : AdminTechColors.panelBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _weekdayLabel(day),
                  style: adminTechLabelStyle(
                    size: 9.5,
                    color: isToday
                        ? AdminTechColors.cyan
                        : AdminTechColors.textTertiary,
                  ),
                ),
                const Spacer(),
                Text(
                  day.day.toString().padLeft(2, '0'),
                  style: adminTechValueStyle(
                    size: 15,
                    color: isToday
                        ? AdminTechColors.textPrimary
                        : AdminTechColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Text(
                'Plan yok',
                style: adminTechLabelStyle(size: 9.5, weight: FontWeight.w400),
              )
            else ...[
              for (final item in items.take(2)) _PlanChip(item: item),
              if (items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 2),
                  child: Text(
                    '+${items.length - 2} plan daha',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AdminTechColors.cyan,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.item});

  final PlannedOperationSnapshot item;

  @override
  Widget build(BuildContext context) {
    final local = item.scheduledAtLocal;
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final customer =
        item.customerName.isEmpty ? 'Musteri yok' : item.customerName;
    final title = item.title.isEmpty ? item.description : item.title;
    final canOpen = item.operationId.isNotEmpty;

    return InkWell(
      onTap: canOpen
          ? () => Navigator.of(context).push(
                adminWebRoute(
                  AdminWebOperationDetailPage(operationId: item.operationId),
                ),
              )
          : null,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AdminTechColors.panelBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AdminTechColors.indigo.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AdminTechColors.cyan,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AdminTechColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title.isEmpty ? 'Planli operasyon' : title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.35,
                color: AdminTechColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// İkincil ızgara: talep/operasyon çubukları, öncelik dağılımı ve kaynaklar.
class _SecondaryGrid extends StatelessWidget {
  const _SecondaryGrid({required this.width, required this.dashboardFuture});

  final double width;
  final Future<TenantDashboard> dashboardFuture;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      _ActivityCard(width: width, dashboardFuture: dashboardFuture),
      _BreakdownCard(dashboardFuture: dashboardFuture),
      _QuickLinksCard(width: width),
    ];

    if (width < 1080) {
      return Column(
        children: [
          children[0],
          const SizedBox(height: 18),
          children[1],
          const SizedBox(height: 18),
          children[2],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: children[0]),
        const SizedBox(width: 18),
        Expanded(flex: 4, child: children[1]),
        const SizedBox(width: 18),
        Expanded(flex: 4, child: children[2]),
      ],
    );
  }
}

/// Talep ve operasyon akışının aylık karşılaştırması.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.width, required this.dashboardFuture});

  final double width;
  final Future<TenantDashboard> dashboardFuture;

  @override
  Widget build(BuildContext context) {
    return AdminTechCard(
      glow: AdminTechColors.indigo,
      child: FutureBuilder<TenantDashboard>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          final dashboard = snapshot.data;
          final labels = _lastMonths(4);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AdminTechPlaceholder(
              height: 200,
              label: 'Kayitlar yukleniyor...',
              showSpinner: true,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminTechSectionTitle(
                title: 'Kayit Akisi',
                subtitle: 'Son 4 ay • talep ve operasyon',
                icon: Icons.stacked_bar_chart_rounded,
              ),
              const SizedBox(height: 20),
              _MetricBar(
                label: 'Yeni Talep',
                color: AdminTechColors.cyan,
                value: dashboard?.metricTotal('TicketCreated') ?? 0,
                series: _seriesFor(dashboard, 'TicketCreated', labels),
              ),
              const SizedBox(height: 18),
              _MetricBar(
                label: 'Acilan Is Emri',
                color: AdminTechColors.indigo,
                value: dashboard?.metricTotal('OperationCreated') ?? 0,
                series: _seriesFor(dashboard, 'OperationCreated', labels),
              ),
              const SizedBox(height: 18),
              _MetricBar(
                label: 'Kapanan Talep',
                color: AdminTechColors.green,
                value: dashboard?.metricTotal('TicketClosed') ?? 0,
                series: _seriesFor(dashboard, 'TicketClosed', labels),
              ),
              const SizedBox(height: 18),
              _MetricBar(
                label: 'Kabul Edilen Teklif',
                color: AdminTechColors.violet,
                value: dashboard?.metricTotal('OfferAccepted') ?? 0,
                series: _seriesFor(dashboard, 'OfferAccepted', labels),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.color,
    required this.value,
    required this.series,
  });

  final String label;
  final Color color;
  final int value;
  final List<double> series;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AdminTechColors.textSecondary,
                ),
              ),
            ),
            Text(value.toString(), style: adminTechValueStyle(size: 15)),
          ],
        ),
        const SizedBox(height: 8),
        AdminTechBars(values: series, color: color, height: 34),
      ],
    );
  }
}

/// Operasyon kırılımı: oluşturulan, tamamlanan, teslim edilen.
class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.dashboardFuture});

  final Future<TenantDashboard> dashboardFuture;

  @override
  Widget build(BuildContext context) {
    return AdminTechCard(
      glow: AdminTechColors.amber,
      child: FutureBuilder<TenantDashboard>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          final dashboard = snapshot.data;
          final summary = dashboard?.summary;
          final created = summary?.totalOperations ?? 0;
          final delivered = summary?.deliveredOperations ?? 0;
          final completed = summary?.completedOperations ?? 0;
          final failed = summary?.failedOperations ?? 0;

          final rows = <({String label, int value, Color color})>[
            (
              label: 'Tamamlanan',
              value: completed,
              color: AdminTechColors.green
            ),
            (
              label: 'Teslim edilen',
              value: delivered,
              color: AdminTechColors.cyan
            ),
            (label: 'Basarisiz', value: failed, color: AdminTechColors.red),
            (
              label: 'Olusturulan',
              value: created,
              color: AdminTechColors.indigo
            ),
          ];

          final maxValue =
              rows.fold<int>(0, (max, r) => r.value > max ? r.value : max);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminTechSectionTitle(
                title: 'Operasyon Kirilimi',
                subtitle: 'Durumlara gore toplamlar',
                icon: Icons.pie_chart_outline_rounded,
              ),
              const SizedBox(height: 20),
              for (final row in rows) ...[
                _BreakdownRow(
                  label: row.label,
                  value: row.value,
                  color: row.color,
                  ratio: maxValue == 0 ? 0 : row.value / maxValue,
                ),
                if (row != rows.last) const SizedBox(height: 14),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
    required this.ratio,
  });

  final String label;
  final int value;
  final Color color;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AdminTechColors.textSecondary,
                ),
              ),
            ),
            Text(value.toString(), style: adminTechValueStyle(size: 14)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 6, color: Colors.white.withValues(alpha: 0.07)),
              FractionallySizedBox(
                widthFactor: ratio.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.55), color],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sık kullanılan modüllere hızlı erişim.
class _QuickLinksCard extends StatelessWidget {
  const _QuickLinksCard({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    const links =
        <({String label, IconData icon, AdminNavKey target, Color color})>[
      (
        label: 'AI Asistan',
        icon: Icons.auto_awesome_rounded,
        target: AdminNavKey.aiChat,
        color: AdminTechColors.cyan,
      ),
      (
        label: 'Talepler',
        icon: Icons.confirmation_number_outlined,
        target: AdminNavKey.tickets,
        color: AdminTechColors.amber,
      ),
      (
        label: 'Operasyonlar',
        icon: Icons.receipt_long_outlined,
        target: AdminNavKey.operations,
        color: AdminTechColors.indigo,
      ),
      (
        label: 'Stok',
        icon: Icons.inventory_2_outlined,
        target: AdminNavKey.stock,
        color: AdminTechColors.green,
      ),
      (
        label: 'Muhasebe',
        icon: Icons.account_balance_wallet_outlined,
        target: AdminNavKey.accounting,
        color: AdminTechColors.violet,
      ),
      (
        label: 'Ekip',
        icon: Icons.group_outlined,
        target: AdminNavKey.team,
        color: AdminTechColors.slate,
      ),
    ];

    return AdminTechCard(
      glow: AdminTechColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminTechSectionTitle(
            title: 'Hizli Erisim',
            subtitle: 'Modullere tek tikla',
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 260
                  ? 2
                  : (constraints.maxWidth < 400 ? 3 : 2);
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                childAspectRatio: 2.15,
                children: [
                  for (final link in links)
                    _QuickLinkTile(
                      label: link.label,
                      icon: link.icon,
                      color: link.color,
                      onTap: () {
                        final item = adminNavItems()
                            .firstWhere((nav) => nav.key == link.target);
                        Navigator.of(context).pushReplacement(
                            adminNavRoute(item.pageBuilder(context)));
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  const _QuickLinkTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AdminTechColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                size: 13, color: AdminTechColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── Yardımcılar ─────────────────────────────────────────────────────────────

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _weekdayLabel(DateTime day) {
  const labels = ['Pzt', 'Sal', 'Car', 'Per', 'Cum', 'Cts', 'Paz'];
  return labels[day.weekday - 1];
}

String _monthYearLabel(DateTime day) {
  const months = [
    'Ocak',
    'Subat',
    'Mart',
    'Nisan',
    'Mayis',
    'Haziran',
    'Temmuz',
    'Agustos',
    'Eylul',
    'Ekim',
    'Kasim',
    'Aralik',
  ];
  return '${months[day.month - 1]} ${day.year}';
}

/// Son altı ayın ilk günleri; trend serileri için kullanılır.
List<DateTime> _lastMonths(int count) {
  final now = DateTime.now();
  return List.generate(
      count, (i) => DateTime(now.year, now.month - (count - 1 - i), 1));
}

/// Aylık metrik serisi; veri yoksa boş liste döner.
List<double> _monthlySeries(TenantDashboard? dashboard, String metricType) {
  if (dashboard == null) return const [];
  return _seriesFor(dashboard, metricType, _lastMonths(6));
}

List<double> _seriesFor(
  TenantDashboard? dashboard,
  String metricType,
  List<DateTime> buckets,
) {
  if (dashboard == null) return List.filled(buckets.length, 0);
  return [
    for (final bucket in buckets)
      dashboard.metricValue(metricType, 'Monthly', bucket).toDouble(),
  ];
}

List<_TrendPoint> _buildTrend(TenantDashboard? dashboard, _TrendRange range) {
  final buckets = _trendBuckets(range);
  final labels = _trendLabels(buckets, range);

  return List.generate(buckets.length, (i) {
    final value =
        dashboard == null ? 0 : _trendValue(dashboard, buckets[i], range);
    return _TrendPoint(labels[i], value);
  });
}

int _trendValue(TenantDashboard dashboard, DateTime bucket, _TrendRange range) {
  switch (range) {
    case _TrendRange.daily:
      return dashboard.metricValue('OperationCreated', 'Daily', bucket);
    case _TrendRange.weekly:
      // Haftalık kovada o günün oluşturulan iş emirleri toplanır; sunucu
      // tarafında haftalık metrik yazılmadığı için günlük kayıtlar birleştirilir.
      var value = 0;
      final start = DateTime(bucket.year, bucket.month, bucket.day);
      for (var i = 0; i < 7; i++) {
        value += dashboard.metricValue(
          'OperationCreated',
          'Daily',
          start.add(Duration(days: i)),
        );
      }
      return value;
    case _TrendRange.monthly:
    case _TrendRange.last6Months:
      return dashboard.metricValue('OperationCreated', 'Monthly', bucket);
  }
}

List<DateTime> _trendBuckets(_TrendRange range) {
  final now = DateTime.now();
  switch (range) {
    case _TrendRange.daily:
      return List.generate(
          7, (i) => DateTime(now.year, now.month, now.day - (6 - i)));
    case _TrendRange.weekly:
      final today = DateTime(now.year, now.month, now.day);
      final currentWeekStart =
          today.subtract(Duration(days: today.weekday - 1));
      return List.generate(
          8, (i) => currentWeekStart.subtract(Duration(days: 7 * (7 - i))));
    case _TrendRange.monthly:
      return List.generate(
          12, (i) => DateTime(now.year, now.month - (11 - i), 1));
    case _TrendRange.last6Months:
      return List.generate(
          6, (i) => DateTime(now.year, now.month - (5 - i), 1));
  }
}

List<String> _trendLabels(List<DateTime> buckets, _TrendRange range) {
  const monthLabels = [
    'Oca',
    'Sub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Agu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];

  if (range == _TrendRange.daily) {
    return buckets.map((d) => d.day.toString().padLeft(2, '0')).toList();
  }
  if (range == _TrendRange.weekly) {
    return List.generate(buckets.length, (i) => 'H${i + 1}');
  }
  return buckets.map((d) => monthLabels[d.month - 1]).toList();
}
