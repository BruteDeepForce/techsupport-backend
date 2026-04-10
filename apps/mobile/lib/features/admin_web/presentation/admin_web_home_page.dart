import 'package:flutter/material.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';
import '../../operations/data/operation_service.dart';
import '../../operations/models/operation_models.dart';

class AdminWebHomePage extends StatefulWidget {
  const AdminWebHomePage({super.key});

  @override
  State<AdminWebHomePage> createState() => _AdminWebHomePageState();
}

class _AdminWebHomePageState extends State<AdminWebHomePage> {
  final OperationService _operationService = OperationService();
  late Future<List<OperationRecord>> _operationsFuture;

  @override
  void initState() {
    super.initState();
    _operationsFuture = _operationService.listOperations();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AdminWebShell(
      active: AdminNavKey.home,
      actions: [
        AdminWebActionButton(
          label: 'İş Emri',
          icon: Icons.add,
          onPressed: () {},
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Greeting(),
          const SizedBox(height: 16),
          const _TabStrip(),
          const SizedBox(height: 16),
          const _CalendarCard(),
          const SizedBox(height: 16),
          const _StatusListCard(),
          const SizedBox(height: 20),
          _MiniStatsGrid(width: width),
          const SizedBox(height: 20),
          _ChartSection(width: width, operationsFuture: _operationsFuture),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Merhaba, Süleyman Tuysuzoglu',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        SizedBox(height: 6),
      ],
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Genel İstatistikler',
                style: TextStyle(
                    color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              const Text('Takvimim',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const Spacer(),
              _Pill(label: 'Hafta', active: true),
              const SizedBox(width: 6),
              const _Pill(label: 'Ay'),
              const SizedBox(width: 6),
              const _Pill(label: 'Bugün'),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Mart 2026', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Row(
            children: const [
              _DayCard(day: 'Pzt', date: '23'),
              _DayCard(day: 'Sal', date: '24'),
              _DayCard(day: 'Çar', date: '25'),
              _DayCard(day: 'Per', date: '26'),
              _DayCard(day: 'Cum', date: '27'),
              _DayCard(day: 'Cts', date: '28'),
              _DayCard(day: 'Paz', date: '29', active: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.date, this.active = false});

  final String day;
  final String date;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        height: 86,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF0F7FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: const TextStyle(color: Color(0xFF64748B))),
            const Spacer(),
            Row(
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('+', style: TextStyle(color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusListCard extends StatelessWidget {
  const _StatusListCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Durum Listesi',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: const [
              _StatusPill(
                  color: Color(0xFFFBBF24), label: 'Bekliyor', value: '0'),
              SizedBox(width: 12),
              _StatusPill(
                  color: Color(0xFF3B82F6), label: 'Devam Ediyor', value: '0'),
              SizedBox(width: 12),
              _StatusPill(
                  color: Color(0xFF22C55E), label: 'Tamamlandı', value: '0'),
              SizedBox(width: 12),
              _StatusPill(color: Color(0xFF64748B), label: 'İptal', value: '0'),
            ],
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('Toplam 0 kayıt',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MiniStatsGrid extends StatelessWidget {
  const _MiniStatsGrid({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = width >= 1200
        ? 4
        : width >= 900
            ? 3
            : 2;
    final childAspectRatio = width >= 1200
        ? 2.1
        : width >= 900
            ? 2.0
            : 1.7;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      padding: EdgeInsets.zero,
      children: const [
        _MiniCard(
            title: 'Bekleyen İş Emirleri',
            value: '0',
            caption: '0 acil, 0 normal',
            color: Color(0xFFEFF6FF),
            icon: Icons.receipt_long_outlined),
        _MiniCard(
            title: 'Tamamlanan Emirler',
            value: '0',
            caption: 'Toplam: 0',
            color: Color(0xFFEFFDF4),
            icon: Icons.check_circle_outline),
        _MiniCard(
            title: 'Yaklaşan Bakımlar',
            value: '0',
            caption: 'Önümüzdeki 7 gün',
            color: Color(0xFFFFF7ED),
            icon: Icons.build_outlined),
        _MiniCard(
            title: 'Düşük Stok',
            value: '0',
            caption: '0 stok yok',
            color: Color(0xFFFFF1F2),
            icon: Icons.inventory_2_outlined),
        _MiniCard(
            title: 'Firma & Kişiler',
            value: '0',
            caption: '0 aktif müşteri',
            color: Color(0xFFF1F5FF),
            icon: Icons.groups_outlined),
        _MiniCard(
            title: 'Cihazlar',
            value: '1',
            caption: '1 aktif',
            color: Color(0xFFF0F9FF),
            icon: Icons.devices_outlined),
        _MiniCard(
            title: 'Toplam Gelir',
            value: '₺0',
            caption: '0 teklifler',
            color: Color(0xFFF0FDF4),
            icon: Icons.payments_outlined),
        _MiniCard(
            title: 'Bekleyen Teklifler',
            value: '0',
            caption: '0 toplam',
            color: Color(0xFFF1F5F9),
            icon: Icons.request_quote_outlined),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChartSection extends StatefulWidget {
  const _ChartSection({required this.width, required this.operationsFuture});

  final double width;
  final Future<List<OperationRecord>> operationsFuture;

  @override
  State<_ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<_ChartSection> {
  _TrendRange _range = _TrendRange.last6Months;

  String get _rangeLabel {
    switch (_range) {
      case _TrendRange.daily:
        return 'Son 7 Gün';
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
    final stacked = widget.width < 1200;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: stacked ? 1 : 2,
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Aylık Trend',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(_rangeLabel,
                        style: const TextStyle(color: Color(0xFF94A3B8))),
                    const SizedBox(height: 12),
                    _TrendRangeRow(
                      range: _range,
                      onChanged: (val) => setState(() => _range = val),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<OperationRecord>>(
                      future: widget.operationsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _ChartPlaceholder(
                              height: 170, caption: 'Yükleniyor...');
                        }
                        if (snapshot.hasError) {
                          return const _ChartPlaceholder(
                              height: 170, caption: 'Trend alınamadı');
                        }
                        final ops = snapshot.data ?? [];
                        final data = _buildTrend(ops, _range);
                        return _TrendChart(data: data);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maliyet Özeti',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('İş emri maliyet dağılımı',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 16),
                    _CostRow(
                        color: Color(0xFFBFDBFE),
                        label: 'Toplam Parça Maliyeti',
                        value: '₺0'),
                    SizedBox(height: 8),
                    _CostRow(
                        color: Color(0xFFFFEDD5),
                        label: 'Toplam İşçilik Maliyeti',
                        value: '₺0'),
                    SizedBox(height: 8),
                    _CostRow(
                        color: Color(0xFFDCFCE7),
                        label: 'Toplam Maliyet',
                        value: '₺0'),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aylık Maliyet Trendi',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Son 6 Ay',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 16),
                    _ChartPlaceholder(height: 150, caption: 'Chart'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Öncelik Dağılımı',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Önceliğe göre iş emirleri',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 16),
                    _ChartPlaceholder(
                        height: 130, caption: 'düşük / normal / acil'),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Son İş Emirleri',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Son 5 iş emri',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    SizedBox(height: 24),
                    _EmptyState(label: 'Henüz iş emri bulunmuyor'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Teknisyen Durumu',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(height: 6),
              Text('Aktif teknisyenler',
                  style: TextStyle(color: Color(0xFF94A3B8))),
              SizedBox(height: 24),
              _EmptyState(label: 'Veri bulunamadı'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.height, required this.caption});

  final double height;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: Text(caption, style: const TextStyle(color: Color(0xFF94A3B8))),
    );
  }
}

enum _TrendRange { daily, weekly, monthly, last6Months }

class _TrendPoint {
  const _TrendPoint(this.label, this.value);

  final String label;
  final int value;
}

List<_TrendPoint> _buildTrend(List<OperationRecord> ops, _TrendRange range) {
  final now = DateTime.now();
  final monthLabels = const [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];

  List<DateTime> buckets;
  List<String> labels;

  switch (range) {
    case _TrendRange.daily:
      buckets = List.generate(
          7, (i) => DateTime(now.year, now.month, now.day - (6 - i)));
      labels = buckets
          .map((d) => '${d.day.toString().padLeft(2, '0')}')
          .toList();
      break;
    case _TrendRange.weekly:
      buckets = List.generate(
        8,
        (i) => DateTime(now.year, now.month, now.day - (7 * (7 - i))),
      );
      labels = List.generate(8, (i) => 'H${i + 1}');
      break;
    case _TrendRange.monthly:
      buckets = List.generate(12, (i) => DateTime(now.year, now.month - (11 - i), 1));
      labels = buckets.map((d) => monthLabels[d.month - 1]).toList();
      break;
    case _TrendRange.last6Months:
      buckets = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));
      labels = buckets.map((d) => monthLabels[d.month - 1]).toList();
      break;
  }

  final counts = List<int>.filled(buckets.length, 0);
  for (final op in ops) {
    final d = op.occurredAtUtc.toLocal();
    for (int i = 0; i < buckets.length; i++) {
      final b = buckets[i];
      if (range == _TrendRange.daily) {
        if (d.year == b.year && d.month == b.month && d.day == b.day) {
          counts[i] += 1;
          break;
        }
      } else if (range == _TrendRange.weekly) {
        final start = b;
        final end = start.add(const Duration(days: 7));
        if (!d.isBefore(start) && d.isBefore(end)) {
          counts[i] += 1;
          break;
        }
      } else {
        if (d.year == b.year && d.month == b.month) {
          counts[i] += 1;
          break;
        }
      }
    }
  }

  return List.generate(buckets.length, (i) {
    return _TrendPoint(labels[i], counts[i]);
  });
}

class _TrendRangeRow extends StatelessWidget {
  const _TrendRangeRow({required this.range, required this.onChanged});

  final _TrendRange range;
  final ValueChanged<_TrendRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _TrendRangePill(
          label: 'Gün',
          active: range == _TrendRange.daily,
          onTap: () => onChanged(_TrendRange.daily),
        ),
        _TrendRangePill(
          label: 'Hafta',
          active: range == _TrendRange.weekly,
          onTap: () => onChanged(_TrendRange.weekly),
        ),
        _TrendRangePill(
          label: 'Ay',
          active: range == _TrendRange.monthly,
          onTap: () => onChanged(_TrendRange.monthly),
        ),
        _TrendRangePill(
          label: '6 Ay',
          active: range == _TrendRange.last6Months,
          onTap: () => onChanged(_TrendRange.last6Months),
        ),
      ],
    );
  }
}

class _TrendRangePill extends StatelessWidget {
  const _TrendRangePill(
      {required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.data});

  final List<_TrendPoint> data;

  @override
  Widget build(BuildContext context) {
    final maxValue =
        data.map((e) => e.value).fold<int>(0, (a, b) => a > b ? a : b);
    final displayMax = maxValue == 0 ? 6 : maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Toplam operasyon',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const SizedBox(width: 8),
            Text(
              data.fold<int>(0, (sum, e) => sum + e.value).toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: CustomPaint(
            painter: _TrendPainter(
              values: data.map((e) => e.value.toDouble()).toList(),
              maxValue: displayMax.toDouble(),
            ),
            child: Container(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: data
              .map((e) => Text(
                    e.label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.values, required this.maxValue});

  final List<double> values;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    final gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = size.height - (size.height / gridCount) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    if (values.isEmpty) return;
    final stepX = size.width / (values.length - 1);
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = stepX * i;
      final v = values[i];
      final ratio = maxValue == 0 ? 0.0 : (v / maxValue);
      final y = size.height - (ratio * size.height);
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(0, size.height);
    for (int i = 0; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x334F46E5),
          Color(0x004F46E5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF4F46E5);
    for (final p in points) {
      canvas.drawCircle(p, 3.6, dotPaint);
      canvas.drawCircle(
          p, 6, dotPaint..color = const Color(0x204F46E5));
      dotPaint.color = const Color(0xFF4F46E5);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.maxValue != maxValue;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8))),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 16, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
