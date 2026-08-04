import 'package:flutter/material.dart';
import 'package:techsupport_mobile/core/utils/pdf_blob_opener.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/data/hr_services.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/model/hr_models.dart';

class AdminWebHrBordroSectionPage extends StatefulWidget {
  const AdminWebHrBordroSectionPage({super.key});

  @override
  State<AdminWebHrBordroSectionPage> createState() =>
      _AdminWebHrBordroSectionPageState();
}

class _AdminWebHrBordroSectionPageState
    extends State<AdminWebHrBordroSectionPage> {
  final HRService _hrService = HRService();
  late Future<List<HRBordroDonemResponse>> _donemlerFuture;

  HRBordroDonemResponse? _selectedDonem;
  List<HRBordroEmployeeResponse> _bordroEmployees = const [];
  bool _isLoadingEmployees = false;
  bool _isCalculating = false;
  bool _isOpeningPdf = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _donemlerFuture = _loadDonemler();
  }

  Future<List<HRBordroDonemResponse>> _loadDonemler() async {
    final items = await _hrService.getBordroDonemler(includeClosed: true);
    if (mounted && items.isNotEmpty) {
      final selectedId = _selectedDonem?.id;
      final preferred = selectedId == null
          ? items.first
          : items.firstWhere(
              (item) => item.id == selectedId,
              orElse: () => items.first,
            );
      _selectedDonem = preferred;
      await _loadBordroEmployees(preferred.id);
    }
    return items;
  }

  Future<void> _refresh() async {
    setState(() {
      _errorMessage = null;
      _donemlerFuture = _loadDonemler();
    });
    await _donemlerFuture;
  }

  Future<void> _loadBordroEmployees(String donemId) async {
    setState(() {
      _isLoadingEmployees = true;
      _errorMessage = null;
    });

    try {
      final items = await _hrService.getBordroEmployees(donemId);
      if (!mounted) return;
      setState(() {
        _bordroEmployees = items;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Bordro çalışanları yüklenemedi: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEmployees = false;
        });
      }
    }
  }

  Future<void> _handleCreateDonem() async {
    final created = await showDialog<HRBordroDonemResponse>(
      context: context,
      builder: (context) => _CreateBordroDonemDialog(hrService: _hrService),
    );

    if (created == null || !mounted) return;

    setState(() {
      _selectedDonem = created;
      _bordroEmployees = const [];
      _donemlerFuture = _loadDonemler();
    });
  }

  Future<void> _handleCalculate() async {
    final selectedDonem = _selectedDonem;
    if (selectedDonem == null) return;

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      final items = await _hrService.calculateBordroDonem(selectedDonem.id);
      if (!mounted) return;
      setState(() {
        _bordroEmployees = items;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hakediş hesaplama tamamlandı.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Hakediş hesaplama başarısız: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

  Future<void> _handleOpenPdf(HRBordroEmployeeResponse employee) async {
    setState(() {
      _isOpeningPdf = true;
    });

    try {
      final bytes = await _hrService.generateBordroEmployeePdf(employee.id);
      if (!mounted) return;
      openPdfInNewTab(bytes, fileName: 'bordro_${employee.employeeName}.pdf');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF açılamadı: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HRBordroDonemResponse>>(
      future: _donemlerFuture,
      builder: (context, snapshot) {
        final donemler = snapshot.data ?? const <HRBordroDonemResponse>[];

        if (_selectedDonem == null && donemler.isNotEmpty) {
          _selectedDonem = donemler.first;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroPanel(
              selectedDonem: _selectedDonem,
              employeeCount: _bordroEmployees.length,
              isCalculating: _isCalculating,
              onCreateDonem: _handleCreateDonem,
              onCalculate: _selectedDonem == null ? null : _handleCalculate,
            ),
            const SizedBox(height: 16),
            _CardShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionTitle(
                          title: 'Bordro Dönemleri',
                          subtitle:
                              'Dönem oluşturun, aktif dönemi seçin ve hakedişleri listeleyin.',
                        ),
                      ),
                      IconButton(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Yenile',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError)
                    _InlineMessage(
                      message: 'Bordro dönemleri yüklenemedi: ${snapshot.error}',
                    )
                  else if (donemler.isEmpty)
                    const _InlineMessage(
                      message:
                          'Henüz bordro dönemi yok. Önce dönem oluşturmalısınız.',
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: donemler
                          .map(
                            (donem) => _DonemChip(
                              donem: donem,
                              selected: _selectedDonem?.id == donem.id,
                              onTap: () async {
                                setState(() {
                                  _selectedDonem = donem;
                                });
                                await _loadBordroEmployees(donem.id);
                              },
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CardShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionTitle(
                          title: 'Bordro Çalışanları',
                          subtitle:
                              'Hesaplanan bordro kayıtları ve satır bazlı PDF görüntüleme.',
                        ),
                      ),
                      if (_isOpeningPdf)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    _InlineMessage(message: _errorMessage!),
                    const SizedBox(height: 12),
                  ],
                  if (_isLoadingEmployees)
                    const Center(child: CircularProgressIndicator())
                  else if (_selectedDonem == null)
                    const _InlineMessage(
                      message: 'Bordro çalışanlarını görmek için bir dönem seçin.',
                    )
                  else if (_bordroEmployees.isEmpty)
                    const _InlineMessage(
                      message:
                          'Bu dönemde henüz bordro kaydı yok. Hakediş hesapla aksiyonunu çalıştırın.',
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
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
                                    'Kazanç',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Kesinti',
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
                                SizedBox(width: 124),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          for (var i = 0; i < _bordroEmployees.length; i++) ...[
                            _BordroEmployeeRow(
                              employee: _bordroEmployees[i],
                              onViewPdf: () =>
                                  _handleOpenPdf(_bordroEmployees[i]),
                            ),
                            if (i != _bordroEmployees.length - 1)
                              const Divider(
                                  height: 1, color: Color(0xFFE2E8F0)),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CreateBordroDonemDialog extends StatefulWidget {
  const _CreateBordroDonemDialog({required this.hrService});

  final HRService hrService;

  @override
  State<_CreateBordroDonemDialog> createState() =>
      _CreateBordroDonemDialogState();
}

class _CreateBordroDonemDialogState extends State<_CreateBordroDonemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _yearController;
  late final TextEditingController _monthController;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime _endDate;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: '${DateTime.now().year}');
    _monthController =
        TextEditingController(text: '${DateTime.now().month}'.padLeft(2, '0'));
    _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked;
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
      final response = await widget.hrService.createBordroDonem(
        HRCreateBordroDonemRequest(
          branchId: _emptyGuid,
          year: int.parse(_yearController.text.trim()),
          month: int.parse(_monthController.text.trim()),
          baslangicTarihi: _startDate,
          bitisTarihi: _endDate,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(response);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = 'Dönem oluşturulamadı: $error';
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
      title: const Text(
        'Bordro Dönemi Oluştur',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DialogTextField(
                      controller: _yearController,
                      label: 'Yıl',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse((value ?? '').trim());
                        if (parsed == null || parsed < 2000) {
                          return 'Geçerli yıl girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogTextField(
                      controller: _monthController,
                      label: 'Ay',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse((value ?? '').trim());
                        if (parsed == null || parsed < 1 || parsed > 12) {
                          return '1-12 arası ay';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Başlangıç Tarihi',
                      value: _formatDate(_startDate),
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Bitiş Tarihi',
                      value: _formatDate(_endDate),
                      onTap: () => _pickDate(false),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
              : const Text('Oluştur'),
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.selectedDonem,
    required this.employeeCount,
    required this.isCalculating,
    required this.onCreateDonem,
    required this.onCalculate,
  });

  final HRBordroDonemResponse? selectedDonem;
  final int employeeCount;
  final bool isCalculating;
  final VoidCallback onCreateDonem;
  final VoidCallback? onCalculate;

  @override
  Widget build(BuildContext context) {
    final status = selectedDonem?.statusLabel ?? 'Dönem Seçilmedi';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FBFF),
            Color(0xFFF1F5F9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bordro Yönetimi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedDonem == null
                      ? 'Önce dönem oluşturun, sonra hakedişleri hesaplayın.'
                      : '${selectedDonem!.periodLabel} • $status',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricPill(
                      label: 'Seçili Dönem',
                      value: selectedDonem?.periodLabel ?? '—',
                    ),
                    _MetricPill(
                      label: 'Bordro Kaydı',
                      value: '$employeeCount kişi',
                    ),
                    _MetricPill(
                      label: 'Durum',
                      value: status,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: onCreateDonem,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Dönem Oluştur'),
              ),
              ElevatedButton.icon(
                onPressed: isCalculating ? null : onCalculate,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: isCalculating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.calculate_outlined, size: 18),
                label: Text(
                  isCalculating ? 'Hesaplanıyor' : 'Hakediş Hesapla',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

class _DonemChip extends StatelessWidget {
  const _DonemChip({
    required this.donem,
    required this.selected,
    required this.onTap,
  });

  final HRBordroDonemResponse donem;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              donem.periodLabel,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatDate(donem.baslangicTarihi)} - ${_formatDate(donem.bitisTarihi)}',
              style: TextStyle(
                color: selected
                    ? Colors.white.withOpacity(0.82)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BordroEmployeeRow extends StatelessWidget {
  const _BordroEmployeeRow({
    required this.employee,
    required this.onViewPdf,
  });

  final HRBordroEmployeeResponse employee;
  final VoidCallback onViewPdf;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE0EAFF), Color(0xFFF1F5F9)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    employee.employeeName.isEmpty
                        ? '?'
                        : employee.employeeName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.employeeId,
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
            child: Text(
              _formatCurrency(employee.totalEarnings),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatCurrency(employee.totalDeductions),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatCurrency(employee.netPay),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          SizedBox(
            width: 124,
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onViewPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('PDF'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

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
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
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

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF475569)),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day.$month.${value.year}';
}

String _formatCurrency(num value) {
  final normalized = value.toStringAsFixed(2).replaceAll('.', ',');
  return '$normalized ₺';
}

const String _emptyGuid = '00000000-0000-0000-0000-000000000000';
