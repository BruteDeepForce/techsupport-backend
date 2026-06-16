import 'package:flutter/material.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/data/hr_services.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/model/hr_models.dart';

import '../../shared/admin_web_nav.dart';
import '../../shared/admin_web_shell.dart';
import '../../shared/admin_web_topbar.dart';

class AdminWebHrEmployeeDetailPage extends StatefulWidget {
  const AdminWebHrEmployeeDetailPage({
    super.key,
    this.employeeId,
    required this.employeeName,
  });

  final String? employeeId;
  final String employeeName;

  @override
  State<AdminWebHrEmployeeDetailPage> createState() =>
      _AdminWebHrEmployeeDetailPageState();
}

class _AdminWebHrEmployeeDetailPageState
    extends State<AdminWebHrEmployeeDetailPage> {
  final HRService _hrService = HRService();
  Future<HREmployeeDetailResponse>? _employeeFuture;

  @override
  void initState() {
    super.initState();
    if (widget.employeeId != null && widget.employeeId!.isNotEmpty) {
      _employeeFuture = _hrService.getEmployeeById(widget.employeeId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      active: AdminNavKey.hr,
      actions: [
        AdminWebActionButton(
          label: 'Düzenle',
          icon: Icons.edit_outlined,
          onPressed: () {},
        ),
      ],
      body: _employeeFuture == null
          ? _FallbackDetail(employeeName: widget.employeeName)
          : FutureBuilder<HREmployeeDetailResponse>(
              future: _employeeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _CardShell(
                    child:
                        Text('Personel detayı yüklenemedi: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const _CardShell(
                    child: Text('Personel detayı bulunamadı.'),
                  );
                }

                final employee = snapshot.data!;
                return _EmployeeDetailContent(employee: employee);
              },
            ),
    );
  }
}

class _EmployeeDetailContent extends StatelessWidget {
  const _EmployeeDetailContent({required this.employee});

  final HREmployeeDetailResponse employee;

  @override
  Widget build(BuildContext context) {
    final leaves = employee.employeeLeaves;
    final latestSalary = employee.employeeSalaries.isNotEmpty
        ? employee.employeeSalaries
            .reduce((a, b) => a.createdAtUtc.isAfter(b.createdAtUtc) ? a : b)
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İnsan Kaynakları / Personeller / Detay',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFE0EAFF),
                  child: Text(
                    employee.fullName.isNotEmpty
                        ? employee.fullName.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        employee.positionName ?? 'Pozisyon Atanmadı',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                _StatusPill(
                  label: employee.status.toLowerCase() == 'active'
                      ? 'Aktif'
                      : 'Pasif',
                  color: employee.status.toLowerCase() == 'active'
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Toplam İzin',
                  value: leaves.length.toString(),
                  accent: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Bekleyen Avans',
                  value: employee.employeeAdvances
                      .where((advance) =>
                          advance.status.toLowerCase() == 'pending')
                      .length
                      .toString(),
                  accent: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Disiplin Kayıtları',
                  value: employee.disciplineEmployeeRecords.length.toString(),
                  accent: const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Ödül Kayıtları',
                  value: employee.rewardEmployeeRecords.length.toString(),
                  accent: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(width: 320, child: _ProfileCard(employee: employee)),
              SizedBox(
                width: 420,
                child: _EmploymentCard(
                  employee: employee,
                  latestSalary: latestSalary,
                ),
              ),
              SizedBox(
                width: 420,
                child: _HistoryCard(employee: employee),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'İzin Geçmişi',
                  subtitle: 'Personel bazlı izin kayıtlarının önizlemesi',
                ),
                const SizedBox(height: 12),
                if (leaves.isEmpty)
                  const Text(
                    'Bu personele ait izin kaydı bulunmuyor.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          const WidgetStatePropertyAll(Color(0xFFF8FAFC)),
                      columns: const [
                        DataColumn(label: Text('Tarih')),
                        DataColumn(label: Text('Süre')),
                        DataColumn(label: Text('Durum')),
                        DataColumn(label: Text('Talep Tarihi')),
                      ],
                      rows: leaves.map((leave) {
                        final days =
                            leave.endDate.difference(leave.startDate).inDays +
                                1;
                        return DataRow(cells: [
                          DataCell(Text(
                            '${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}',
                          )),
                          DataCell(Text('$days Gün')),
                          DataCell(Text(_statusLabel(leave.status))),
                          DataCell(Text(_formatDate(leave.createdAtUtc))),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return '—';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }

  static String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Bekliyor';
      case 'approved':
        return 'Onaylandı';
      case 'rejected':
        return 'Reddedildi';
      default:
        return status;
    }
  }
}

class _FallbackDetail extends StatelessWidget {
  const _FallbackDetail({required this.employeeName});

  final String employeeName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employeeName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Bu kayıt için doğrudan employee id gelmediği için canlı detay yüklenemedi.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.employee});

  final HREmployeeDetailResponse employee;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFE2E8F0),
            backgroundImage: employee.profileImageUrl != null &&
                    employee.profileImageUrl!.isNotEmpty
                ? NetworkImage(employee.profileImageUrl!)
                : null,
            child: employee.profileImageUrl == null ||
                    employee.profileImageUrl!.isEmpty
                ? const Icon(Icons.person_outline_rounded,
                    size: 32, color: Color(0xFF64748B))
                : null,
          ),
          const SizedBox(height: 12),
          Text(employee.fullName,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            employee.positionName ?? 'Pozisyon Atanmadı',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'E-posta', value: employee.email ?? '—'),
          _InfoRow(label: 'Telefon', value: employee.phone ?? '—'),
          _InfoRow(
              label: 'Durum',
              value: employee.status.toLowerCase() == 'active'
                  ? 'Aktif'
                  : 'Pasif'),
        ],
      ),
    );
  }
}

class _EmploymentCard extends StatelessWidget {
  const _EmploymentCard({
    required this.employee,
    required this.latestSalary,
  });

  final HREmployeeDetailResponse employee;
  final HREmployeeDetailSalary? latestSalary;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Çalışma Bilgileri',
            subtitle: 'HR tarafındaki temel özlük alanları',
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Şube', value: _branchLabel(employee.branchId)),
          _InfoRow(
              label: 'Departman',
              value: _departmentLabel(employee.departmentId)),
          _InfoRow(label: 'Pozisyon', value: employee.positionName ?? '—'),
          _InfoRow(
            label: 'İşe Başlama',
            value:
                _EmployeeDetailContent._formatDate(employee.jobsStartDateUtc),
          ),
          _InfoRow(
            label: 'Son Maaş',
            value: latestSalary != null
                ? '${latestSalary!.netSalary.toStringAsFixed(0)} ₺'
                : 'Tanımlı değil',
          ),
        ],
      ),
    );
  }

  String _branchLabel(String branchId) {
    if (branchId.isEmpty ||
        branchId == '00000000-0000-0000-0000-000000000000') {
      return 'Merkez';
    }
    return 'Şube Tanımlı';
  }

  String _departmentLabel(String? departmentId) {
    if (departmentId == null ||
        departmentId.isEmpty ||
        departmentId == '00000000-0000-0000-0000-000000000000') {
      return 'Merkez Departman';
    }
    return 'Departman Tanımlı'; //! departman durumunda
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.employee});

  final HREmployeeDetailResponse employee;

  @override
  Widget build(BuildContext context) {
    final records = <_HistoryItem>[
      if (employee.employeeLeaves.isNotEmpty)
        _HistoryItem(
          title: 'Son izin talebi',
          subtitle:
              '${_EmployeeDetailContent._formatDate(employee.employeeLeaves.first.createdAtUtc)} tarihinde oluşturuldu',
        ),
      if (employee.employeeAdvances.isNotEmpty)
        _HistoryItem(
          title: 'Son avans kaydı',
          subtitle:
              '${employee.employeeAdvances.first.amount.toStringAsFixed(0)} ₺ • ${employee.employeeAdvances.first.status}',
        ),
      if (employee.rewardEmployeeRecords.isNotEmpty)
        _HistoryItem(
          title: 'Ödül kaydı bulundu',
          subtitle: employee.rewardEmployeeRecords.first.description,
        ),
      if (employee.disciplineEmployeeRecords.isNotEmpty)
        _HistoryItem(
          title: 'Disiplin kaydı bulundu',
          subtitle: employee.disciplineEmployeeRecords.first.description,
        ),
    ];

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Son Hareketler',
            subtitle: 'Son izin, avans ve kayıt özetleri',
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            const Text(
              'Son hareket kaydı bulunmuyor.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            for (var i = 0; i < records.length; i++) ...[
              _HistoryRow(
                  title: records[i].title, subtitle: records[i].subtitle),
              if (i != records.length - 1)
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
            ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child:
                Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
      ],
    );
  }
}

class _HistoryItem {
  const _HistoryItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}
