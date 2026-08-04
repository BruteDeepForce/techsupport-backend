import 'package:flutter/material.dart';

import '../../shared/admin_web_nav.dart';
import '../../shared/admin_web_shell.dart';
import '../../shared/admin_web_topbar.dart';

class AdminWebHrLeavesPage extends StatefulWidget {
  const AdminWebHrLeavesPage({super.key});

  @override
  State<AdminWebHrLeavesPage> createState() => _AdminWebHrLeavesPageState();
}

class _AdminWebHrLeavesPageState extends State<AdminWebHrLeavesPage> {
  String _status = 'Bekleyen';
  String _type = 'Tümü';

  Future<void> _showCreateLeaveDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _CreateLeaveDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      active: AdminNavKey.hr,
      actions: [
        AdminWebActionButton(
          label: 'Yeni İzin Talebi',
          icon: Icons.add,
          onPressed: _showCreateLeaveDialog,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İzin Yönetimi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'İzin taleplerini filtreleyin, inceleyin ve onaylayın.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          _CardShell(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _FilterField(
                  label: 'Durum',
                  value: _status,
                  items: const ['Bekleyen', 'Onaylandı', 'Reddedildi', 'Tümü'],
                  onChanged: (value) => setState(() => _status = value),
                ),
                _FilterField(
                  label: 'İzin Türü',
                  value: _type,
                  items: const [
                    'Tümü',
                    'Yıllık İzin',
                    'Hastalık',
                    'Mazeret',
                    'Ücretsiz İzin'
                  ],
                  onChanged: (value) => setState(() => _type = value),
                ),
                const _DateField(label: 'Başlangıç Tarihi'),
                const _DateField(label: 'Bitiş Tarihi'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _CardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'İzin Talepleri',
                  subtitle: 'Liste önizlemesi',
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        const WidgetStatePropertyAll(Color(0xFFF8FAFC)),
                    columns: const [
                      DataColumn(label: Text('Personel')),
                      DataColumn(label: Text('Tür')),
                      DataColumn(label: Text('Tarih')),
                      DataColumn(label: Text('Açıklama')),
                      DataColumn(label: Text('Durum')),
                      DataColumn(label: Text('İşlemler')),
                    ],
                    rows: [
                      _row('Batuhan Kaya', 'Yıllık İzin', '15.06 - 18.06',
                          'Aile ziyareti', 'Bekleyen'),
                      _row('Zehra Demir', 'Hastalık', '14.06 - 14.06',
                          'Rapor yüklenecek', 'Bekleyen'),
                      _row('Mert Çetin', 'Ücretsiz İzin', '20.06 - 22.06',
                          'Özel neden', 'Onaylandı'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _row(
      String employee, String type, String date, String reason, String status) {
    return DataRow(
      cells: [
        DataCell(Text(employee)),
        DataCell(Text(type)),
        DataCell(Text(date)),
        DataCell(Text(reason)),
        DataCell(Text(status)),
        DataCell(
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('Detay')),
              TextButton(onPressed: () {}, child: const Text('Onayla')),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: [
              for (final item in items)
                DropdownMenuItem(value: item, child: Text(item))
            ],
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: Color(0xFF64748B)))),
          const Icon(Icons.calendar_today_outlined,
              size: 16, color: Color(0xFF64748B)),
        ],
      ),
    );
  }
}

class _CreateLeaveDialog extends StatelessWidget {
  const _CreateLeaveDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yeni İzin Talebi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            const _DialogField(label: 'Personel'),
            const SizedBox(height: 10),
            Row(
              children: const [
                Expanded(child: _DialogField(label: 'Başlangıç Tarihi')),
                SizedBox(width: 12),
                Expanded(child: _DialogField(label: 'Bitiş Tarihi')),
              ],
            ),
            const SizedBox(height: 10),
            const _DialogField(label: 'İzin Türü'),
            const SizedBox(height: 10),
            const _DialogField(label: 'Açıklama', lines: 4),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal')),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kaydet')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({required this.label, this.lines = 1});

  final String label;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
