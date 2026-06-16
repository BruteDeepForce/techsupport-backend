import 'package:flutter/material.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/data/hr_services.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/model/hr_models.dart';

class AdminWebHrLeaveSectionPage extends StatefulWidget {
  const AdminWebHrLeaveSectionPage({
    super.key,
    required this.onOpenLeaves,
  });

  final VoidCallback onOpenLeaves;

  @override
  State<AdminWebHrLeaveSectionPage> createState() =>
      _AdminWebHrLeaveSectionPageState();
}

class _AdminWebHrLeaveSectionPageState
    extends State<AdminWebHrLeaveSectionPage> {
  final HRService _hrService = HRService();
  late final Future<HRLargeLeaveResponseList> _leavesFuture;
  late final Future<HREmployeeLargeDetailResponse> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _leavesFuture = _hrService.getLeaves();
    _employeesFuture = _hrService.getLargeDetailEmployees();
  }

  Future<void> _showCreateLeaveDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _CreateLeaveDialog(
        employeesFuture: _employeesFuture,
        hrService: _hrService,
      ),
    );
  }

  Future<void> _showLeaveDetailDialog(HRLeaveResponse leave) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İzin Detayı - ${leave.employeeFullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personel: ${leave.employeeFullName}'),
            const SizedBox(height: 8),
            Text('İzin Türü: ${_typeLabel(leave.type)}'),
            const SizedBox(height: 8),
            Text(
                'Tarih Aralığı: ${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}'),
            const SizedBox(height: 8),
            Text('Durum: ${_statusLabel(leave.status)}'),
            if (leave.reason.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Açıklama:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(leave.reason),
            ],
          ],
        ),
        //! onay işlemleri yönetim butonları
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final message =
                    await _hrService.decideLeave(leave.id, 'Approved');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
                Navigator.of(context).pop();
                setState(() {
                  _leavesFuture = _hrService.getLeaves();
                });
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hata: $error')),
                );
              }
            },
            child: const Text('Onayla'),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reddetme Nedeni'),
                  content: TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Reddetme nedenini girin',
                    ),
                    onChanged: (value) {
                      // Reddetme nedeni burada saklanabilir
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Kapat'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final message = await _hrService.decideLeave(
                              leave.id, 'Rejected');
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                          Navigator.of(context)
                              .pop(); // Nedeni girme dialogunu kapat
                          Navigator.of(context).pop(); // Detay dialogunu kapat
                          setState(() {
                            _leavesFuture = _hrService.getLeaves();
                          });
                        } catch (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Hata: $error')),
                          );
                        }
                      },
                      child: const Text('Reddet'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle(
                  title: 'İzin Önizleme',
                  subtitle: 'İzin yönetimi ekranı açılmadan önce temel görünüm',
                ),
              ),
              FilledButton.icon(
                onPressed: _showCreateLeaveDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('İzin Girişi'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<HRLargeLeaveResponseList>(
            future: _leavesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.allLeaves.isEmpty) {
                return const Text('İzin verisi bulunamadı.');
              }

              final leaves = snapshot.data!;
              final previewLeaves = leaves.allLeaves.take(5).toList();
              final pendingCount = leaves.pendingLeaves.length;
              final approvedCount = leaves.approvedLeaves.length;
              final rejectedCount = leaves.rejectedLeaves.length;
              final activePreviewCount = previewLeaves
                  .where((leave) => leave.status.toLowerCase() == 'pending')
                  .length;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _LeaveStatCard(
                          title: 'Bekleyen Talepler',
                          value: pendingCount.toString(),
                          subtitle: 'Aksiyon bekleyen izin kayıtları',
                          accent: const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LeaveStatCard(
                          title: 'Onaylananlar',
                          value: approvedCount.toString(),
                          subtitle: 'Tamamlanan izin kararları',
                          accent: const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LeaveStatCard(
                          title: 'Reddedilenler',
                          value: rejectedCount.toString(),
                          subtitle: 'Uygun bulunmayan talepler',
                          accent: const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LeaveStatCard(
                          title: 'Önizleme',
                          value: activePreviewCount.toString(),
                          subtitle: 'Bu listede bekleyen kayıt sayısı',
                          accent: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                          child: Row(
                            children: [
                              const Expanded(
                                child: _SectionTitle(
                                  title: 'Son izin talep ve durumları',
                                  subtitle:
                                      'Hızlı inceleme için son kayıt önizlemeleri',
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  '${previewLeaves.length} kayıt',
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
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
                                flex: 2,
                                child: Text(
                                  'İzin Türü',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Tarih Aralığı',
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
                        //! previewRow buradan gönderiyoruz.
                        for (var i = 0; i < previewLeaves.length; i++) ...[
                          _LeavePreviewRow(
                              leave: previewLeaves[i],
                              onTap: () {
                                _showLeaveDetailDialog(previewLeaves[i]);
                              }),
                          if (i != previewLeaves.length - 1)
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }

  static String _statusLabel(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return 'Bekliyor';
      case 'approved':
        return 'Onaylandı';
      case 'rejected':
        return 'Reddedildi';
      default:
        return value;
    }
  }

  static String _typeLabel(String value) {
    switch (value) {
      case 'Vacation':
        return 'Yıllık İzin';
      case 'PersonalLeave':
        return 'Mazeret İzni';
      case 'SickLeave':
        return 'Hastalık İzni';
      case 'MaternityLeave':
        return 'Doğum İzni';
      case 'PaternityLeave':
        return 'Babalık İzni';
      case 'UnpaidLeave':
        return 'Ücretsiz İzin';
      default:
        return value;
    }
  }
}

class _LeaveStatCard extends StatelessWidget {
  const _LeaveStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String value;
  final String subtitle;
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
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeavePreviewRow extends StatelessWidget {
  const _LeavePreviewRow({required this.leave, required this.onTap});

  final HRLeaveResponse leave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(leave.status);
    final name = leave.employeeFullName.trim();
    final avatar = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE0EAFF), Color(0xFFF1F5F9)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      avatar,
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.employeeFullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          leave.reason,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _AdminWebHrLeaveSectionPageState._typeLabel(leave.type),
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${_AdminWebHrLeaveSectionPageState._formatDate(leave.startDate)} - ${_AdminWebHrLeaveSectionPageState._formatDate(leave.endDate)}',
                style: const TextStyle(color: Color(0xFF475569)),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _AdminWebHrLeaveSectionPageState._statusLabel(leave.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 44,
              child: Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD97706);
      case 'approved':
        return const Color(0xFF15803D);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }
}

class _CreateLeaveDialog extends StatefulWidget {
  const _CreateLeaveDialog({
    required this.employeesFuture,
    required HRService hrService,
  }) : _hrService = hrService;

  final Future<HREmployeeLargeDetailResponse> employeesFuture;
  final HRService _hrService;

  @override
  State<_CreateLeaveDialog> createState() => _CreateLeaveDialogState();
}

class _CreateLeaveDialogState extends State<_CreateLeaveDialog> {
  String? _selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _reason;
  String? _leaveType;
  bool _isSubmitting = false;

  Future<void> _submitCreateLeave() async {
    if (_selectedEmployeeId == null ||
        _leaveType == null ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen zorunlu alanları doldurun.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final leaveId = await widget._hrService.createLeave(
        HRLeaveCreateRequest(
          employeeId: _selectedEmployeeId!,
          type: _leaveType!,
          reason: _reason ?? '',
          startDate: _startDate!,
          endDate: _endDate!,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İzin başarıyla oluşturuldu (ID: $leaveId)')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İzin oluşturulurken hata: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 920,
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<HREmployeeLargeDetailResponse>(
          future: widget.employeesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 220,
                child: Center(
                  child: Text('Personeller yüklenemedi: ${snapshot.error}'),
                ),
              );
            }

            final employees =
                snapshot.data?.employees ?? const <EmployeeResponse>[];

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yeni İzin Kaydı',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Personel için yeni izin talebi oluşturun. Formu eksiksiz doldurup kaydedin.',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: _DialogInfoCard(
                                  title: 'Seçilen Personel',
                                  value: _selectedEmployeeId == null
                                      ? 'Yok'
                                      : 'Hazır',
                                  accent: const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DialogInfoCard(
                                  title: 'Tarih Aralığı',
                                  value: _startDate != null && _endDate != null
                                      ? 'Tanımlı'
                                      : 'Bekleniyor',
                                  accent: const Color(0xFF0F766E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedEmployeeId,
                                decoration: _inputDecoration('Personel Seçimi'),
                                items: employees
                                    .map(
                                      (employee) => DropdownMenuItem<String>(
                                        value: employee.id,
                                        child: Text(
                                          '${employee.employeeNo} • ${employee.fullName}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _selectedEmployeeId = value);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: _inputDecoration('İzin Türü'),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Vacation',
                                      child: Text('Yıllık İzin')),
                                  DropdownMenuItem(
                                      value: 'SickLeave',
                                      child: Text('Hastalık')),
                                  DropdownMenuItem(
                                      value: 'PersonalLeave',
                                      child: Text('Mazeret')),
                                  DropdownMenuItem(
                                      value: 'MaternityLeave',
                                      child: Text('Doğum İzni')),
                                  DropdownMenuItem(
                                      value: 'PaternityLeave',
                                      child: Text('Babalık İzni')),
                                  DropdownMenuItem(
                                      value: 'UnpaidLeave',
                                      child: Text('Ücretsiz İzin')),
                                ],
                                onChanged: (value) {
                                  setState(() => _leaveType = value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration:
                                    _inputDecoration('Başlangıç Tarihi'),
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    setState(() => _startDate = pickedDate);
                                  }
                                },
                                controller: TextEditingController(
                                  text: _startDate != null
                                      ? '${_startDate!.day.toString().padLeft(2, '0')}.${_startDate!.month.toString().padLeft(2, '0')}.${_startDate!.year}'
                                      : '',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: _inputDecoration('Bitiş Tarihi'),
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    setState(() => _endDate = pickedDate);
                                  }
                                },
                                controller: TextEditingController(
                                  text: _endDate != null
                                      ? '${_endDate!.day.toString().padLeft(2, '0')}.${_endDate!.month.toString().padLeft(2, '0')}.${_endDate!.year}'
                                      : '',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          maxLines: 4,
                          decoration: _inputDecoration('Açıklama / Notlar'),
                          onChanged: (value) {
                            setState(() => _reason = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('İptal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitCreateLeave,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Kaydet'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
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
    );
  }
}

class _DialogInfoCard extends StatelessWidget {
  const _DialogInfoCard({
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
      padding: const EdgeInsets.all(14),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}
