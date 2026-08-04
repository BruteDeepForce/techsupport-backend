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
      _reloadEmployee();
    }
  }

  void _reloadEmployee() {
    if (widget.employeeId == null || widget.employeeId!.isEmpty) return;
    setState(() {
      _employeeFuture = _hrService.getEmployeeById(widget.employeeId!);
    });
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
                return _EmployeeDetailContent(
                  employee: employee,
                  hrService: _hrService,
                  onSalaryChanged: _reloadEmployee,
                );
              },
            ),
    );
  }
}

class _EmployeeDetailContent extends StatelessWidget {
  const _EmployeeDetailContent({
    required this.employee,
    required this.hrService,
    required this.onSalaryChanged,
  });

  final HREmployeeDetailResponse employee;
  final HRService hrService;
  final VoidCallback onSalaryChanged;

  @override
  Widget build(BuildContext context) {
    final leaves = employee.employeeLeaves;
    final latestSalary = _currentSalary(employee.employeeSalaries) ??
        _latestSalary(employee.employeeSalaries);

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
          _SalarySection(
            employee: employee,
            hrService: hrService,
            onChanged: onSalaryChanged,
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

  static HREmployeeDetailSalary? _currentSalary(
      List<HREmployeeDetailSalary> salaries) {
    final now = DateTime.now();
    final active = salaries
        .where((salary) =>
            !salary.effectiveFrom.isAfter(now) &&
            (salary.effectiveTo == null || !salary.effectiveTo!.isBefore(now)))
        .toList()
      ..sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));

    return active.isEmpty ? null : active.first;
  }

  static HREmployeeDetailSalary? _latestSalary(
      List<HREmployeeDetailSalary> salaries) {
    if (salaries.isEmpty) return null;
    final sorted = [...salaries]
      ..sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));
    return sorted.first;
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

class _SalarySection extends StatelessWidget {
  const _SalarySection({
    required this.employee,
    required this.hrService,
    required this.onChanged,
  });

  final HREmployeeDetailResponse employee;
  final HRService hrService;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final salaries = [...employee.employeeSalaries]
      ..sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));
    final activeSalary = _EmployeeDetailContent._currentSalary(salaries);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle(
                  title: 'Maaş Yönetimi',
                  subtitle:
                      'Aktif maaş, geçmiş kayıtlar ve personel bazlı maaş aksiyonları',
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showSalaryDialog(
                  context,
                  hrService: hrService,
                  employee: employee,
                  onChanged: onChanged,
                ),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Yeni Maaş Tanımla'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _ActiveSalaryCard(
                  salary: activeSalary,
                  onEdit: activeSalary == null
                      ? null
                      : () => _showSalaryDialog(
                            context,
                            hrService: hrService,
                            employee: employee,
                            salary: activeSalary,
                            onChanged: onChanged,
                          ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SalarySummaryCard(
                  title: 'Toplam Kayıt',
                  value: salaries.length.toString(),
                  accent: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SalarySummaryCard(
                  title: 'Aktif Maaş',
                  value: activeSalary == null ? 'Yok' : 'Var',
                  accent: activeSalary == null
                      ? const Color(0xFF64748B)
                      : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (salaries.isEmpty)
            const Text(
              'Bu personele ait maaş kaydı bulunmuyor.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Geçerlilik',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Brüt',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Net',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Kayıt',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 96),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  for (var i = 0; i < salaries.length; i++) ...[
                    _SalaryRow(
                      salary: salaries[i],
                      isActive: activeSalary?.id == salaries[i].id,
                      onEdit: () => _showSalaryDialog(
                        context,
                        hrService: hrService,
                        employee: employee,
                        salary: salaries[i],
                        onChanged: onChanged,
                      ),
                    ),
                    if (i != salaries.length - 1)
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showSalaryDialog(
    BuildContext context, {
    required HRService hrService,
    required HREmployeeDetailResponse employee,
    required VoidCallback onChanged,
    HREmployeeDetailSalary? salary,
  }) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => _SalaryFormDialog(
        hrService: hrService,
        employee: employee,
        salary: salary,
      ),
    );

    if (changed == true) {
      onChanged();
    }
  }
}

class _ActiveSalaryCard extends StatelessWidget {
  const _ActiveSalaryCard({
    required this.salary,
    required this.onEdit,
  });

  final HREmployeeDetailSalary? salary;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mevcut Aktif Maaş',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Maaşı Güncelle'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (salary == null)
            const Text(
              'Aktif maaş kaydı tanımlı değil.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SalaryValuePill(
                  label: 'Brüt',
                  value: _formatMoney(salary!.grossSalary),
                ),
                _SalaryValuePill(
                  label: 'Net',
                  value: _formatMoney(salary!.netSalary),
                ),
                _SalaryValuePill(
                  label: 'Başlangıç',
                  value: _EmployeeDetailContent._formatDate(
                    salary!.effectiveFrom,
                  ),
                ),
                _SalaryValuePill(
                  label: 'Bitiş',
                  value: _EmployeeDetailContent._formatDate(
                    salary!.effectiveTo,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SalarySummaryCard extends StatelessWidget {
  const _SalarySummaryCard({
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

class _SalaryValuePill extends StatelessWidget {
  const _SalaryValuePill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryRow extends StatelessWidget {
  const _SalaryRow({
    required this.salary,
    required this.isActive,
    required this.onEdit,
  });

  final HREmployeeDetailSalary salary;
  final bool isActive;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_EmployeeDetailContent._formatDate(salary.effectiveFrom)} - ${_EmployeeDetailContent._formatDate(salary.effectiveTo)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive ? 'Aktif kayıt' : 'Geçmiş kayıt',
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text(_formatMoney(salary.grossSalary))),
          Expanded(child: Text(_formatMoney(salary.netSalary))),
          Expanded(
            child:
                Text(_EmployeeDetailContent._formatDate(salary.createdAtUtc)),
          ),
          SizedBox(
            width: 110,
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onEdit,
                child: const Text('Düzelt'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryFormDialog extends StatefulWidget {
  const _SalaryFormDialog({
    required this.hrService,
    required this.employee,
    this.salary,
  });

  final HRService hrService;
  final HREmployeeDetailResponse employee;
  final HREmployeeDetailSalary? salary;

  @override
  State<_SalaryFormDialog> createState() => _SalaryFormDialogState();
}

class _SalaryFormDialogState extends State<_SalaryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _grossController;
  late final TextEditingController _netController;
  late DateTime _effectiveFrom;
  DateTime? _effectiveTo;
  bool _isSubmitting = false;
  String? _submitError;

  bool get _isEdit => widget.salary != null;

  @override
  void initState() {
    super.initState();
    final salary = widget.salary;
    _grossController = TextEditingController(
      text: salary?.grossSalary.toStringAsFixed(2) ?? '',
    );
    _netController = TextEditingController(
      text: salary?.netSalary.toStringAsFixed(2) ?? '',
    );
    _effectiveFrom = salary?.effectiveFrom ?? DateTime.now();
    _effectiveTo = salary?.effectiveTo;
  }

  @override
  void dispose() {
    _grossController.dispose();
    _netController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate =
        isStart ? _effectiveFrom : (_effectiveTo ?? _effectiveFrom);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _effectiveFrom = picked;
        if (_effectiveTo != null && _effectiveTo!.isBefore(_effectiveFrom)) {
          _effectiveTo = _effectiveFrom;
        }
      } else {
        _effectiveTo = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      if (_isEdit) {
        await widget.hrService.updateEmployeeSalary(
          widget.salary!.id,
          HRUpdateEmployeeSalaryRequest(
            grossSalary: num.parse(_grossController.text.replaceAll(',', '.')),
            netSalary: num.parse(_netController.text.replaceAll(',', '.')),
            effectiveFrom: _effectiveFrom,
            effectiveTo: _effectiveTo,
          ),
        );
      } else {
        await widget.hrService.createEmployeeSalary(
          HRCreateEmployeeSalaryRequest(
            branchId: widget.employee.branchId,
            employeeId: widget.employee.id,
            grossSalary: num.parse(_grossController.text.replaceAll(',', '.')),
            netSalary: num.parse(_netController.text.replaceAll(',', '.')),
            effectiveFrom: _effectiveFrom,
            effectiveTo: _effectiveTo,
          ),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = 'Maaş kaydı kaydedilemedi: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        _isEdit ? 'Maaşı Güncelle' : 'Yeni Maaş Tanımla',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SalaryTextField(
                      controller: _grossController,
                      label: 'Brüt Maaş',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SalaryTextField(
                      controller: _netController,
                      label: 'Net Maaş',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Geçerlilik Başlangıcı',
                      value: _EmployeeDetailContent._formatDate(_effectiveFrom),
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'Geçerlilik Bitişi',
                      value: _EmployeeDetailContent._formatDate(_effectiveTo),
                      onTap: () => _pickDate(false),
                      onClear: _effectiveTo == null
                          ? null
                          : () => setState(() => _effectiveTo = null),
                    ),
                  ),
                ],
              ),
              if (_submitError != null) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _submitError!,
                    style: const TextStyle(color: Color(0xFFDC2626)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_isEdit ? 'Güncelle' : 'Kaydet'),
        ),
      ],
    );
  }
}

class _SalaryTextField extends StatelessWidget {
  const _SalaryTextField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        final parsed = num.tryParse((value ?? '').replaceAll(',', '.'));
        if (parsed == null || parsed <= 0) {
          return 'Geçerli tutar girin';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: const Color(0xFF64748B),
                tooltip: 'Tarihi temizle',
              ),
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(num value) => '${value.toStringAsFixed(2)} ₺';

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
