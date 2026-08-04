import 'package:flutter/material.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/data/hr_services.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/model/hr_models.dart';

class AdminWebHROptionsSection extends StatefulWidget {
  const AdminWebHROptionsSection({super.key});

  @override
  State<AdminWebHROptionsSection> createState() =>
      _AdminWebHROptionsSectionState();
}

class _AdminWebHROptionsSectionState extends State<AdminWebHROptionsSection> {
  final HRService _hrService = HRService();
  late Future<List<HRPositionResponse>> _positionsFuture;
  late Future<List<HRLeaveDeductionResponse>> _leaveDeductionsFuture;
  HRAdvanceSettingsResponse? _advanceSettings;
  bool _isAdvanceSettingsLoading = false;

  @override
  void initState() {
    super.initState();
    _positionsFuture = _fetchPositions();
    _leaveDeductionsFuture = _fetchLeaveDeductions();
    _loadCurrentAdvanceSettings();
  }

  Future<void> _loadCurrentAdvanceSettings() async {
    setState(() => _isAdvanceSettingsLoading = true);
    try {
      final response = await _hrService.getCurrentAdvanceSettings();
      if (!mounted) return;
      setState(() {
        _advanceSettings = response;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _advanceSettings = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isAdvanceSettingsLoading = false);
      }
    }
  }

  Future<void> _showAdvanceSettingsDialog() async {
    final response = await showDialog<HRAdvanceSettingsResponse>(
      context: context,
      builder: (context) => _AdvanceSettingsDialog(
        hrService: _hrService,
        initialValue: _advanceSettings,
      ),
    );

    if (response != null && mounted) {
      setState(() {
        _advanceSettings = response;
      });
    }
  }

  Future<List<HRPositionResponse>> _fetchPositions() async {
    try {
      return await _hrService.getPositions();
    } catch (_) {
      return [];
    }
  }

  Future<List<HRLeaveDeductionResponse>> _fetchLeaveDeductions() async {
    try {
      return await _hrService.getLeaveDeductions();
    } catch (_) {
      return [];
    }
  }

  Future<void> _showCreatePositionDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _CreatePositionDialog(hrService: _hrService),
    );

    if (created == true && mounted) {
      setState(() {
        _positionsFuture = _fetchPositions();
      });
    }
  }

  Future<void> _showLeaveDeductionDialog(
      {HRLeaveDeductionResponse? initialValue}) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => _LeaveDeductionDialog(
        hrService: _hrService,
        initialValue: initialValue,
      ),
    );

    if (changed == true && mounted) {
      setState(() {
        _leaveDeductionsFuture = _fetchLeaveDeductions();
      });
    }
  }

  Future<void> _deleteLeaveDeduction(HRLeaveDeductionResponse item) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Kesinti Ayarını Sil'),
            content: Text(
              '${_leaveTypeLabel(item.deductionType)} kesinti ayarı silinsin mi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    try {
      await _hrService.deleteLeaveDeduction(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kesinti ayarı silindi.')),
      );
      setState(() {
        _leaveDeductionsFuture = _fetchLeaveDeductions();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme işlemi başarısız: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: const Text(
              'İnsan kaynakları modülüne ait genel ayarlar ve konfigürasyonlar bu bölümde yer alır. '
              'Pozisyon yönetimi, izin ayarları ve disiplin ayarları gibi temel yapılandırmalar buradan yapılabilir.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 18),
          _SettingsSectionShell(
            title: 'Pozisyon Ayarları',
            subtitle:
                'Pozisyonları görüntüleyin, yönetin ve yeni pozisyon ekleyin.',
            action: OutlinedButton.icon(
              onPressed: _showCreatePositionDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Yeni Pozisyon'),
            ),
            child: FutureBuilder<List<HRPositionResponse>>(
              future: _positionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Pozisyonlar yüklenemedi: ${snapshot.error}'),
                  );
                }

                final positions = snapshot.data ?? const <HRPositionResponse>[];
                if (positions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Henüz pozisyon kaydı bulunmuyor.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }

                return Column(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Pozisyon',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Açıklama',
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
                          Expanded(
                            child: Text(
                              'Oluşturulma Tarihi',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    for (var i = 0; i < positions.length; i++) ...[
                      _PositionRow(position: positions[i]),
                      if (i != positions.length - 1)
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          _SettingsSectionShell(
            title: 'İzin Ayarları',
            subtitle:
                'Ücretsiz izin kesintisi ve ileride genişleyecek izin kesinti kuralları bu bölümde yönetilir.',
            action: OutlinedButton.icon(
              onPressed: () => _showLeaveDeductionDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Yeni Kesinti Ayarı'),
            ),
            child: FutureBuilder<List<HRLeaveDeductionResponse>>(
              future: _leaveDeductionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                        'İzin kesinti ayarları yüklenemedi: ${snapshot.error}'),
                  );
                }

                final items =
                    snapshot.data ?? const <HRLeaveDeductionResponse>[];
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Henüz izin kesinti ayarı bulunmuyor.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        _LeaveDeductionRow(
                          item: items[i],
                          onEdit: () =>
                              _showLeaveDeductionDialog(initialValue: items[i]),
                          onDelete: () => _deleteLeaveDeduction(items[i]),
                        ),
                        if (i != items.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          _SettingsSectionShell(
            title: 'Avans Ayarları',
            subtitle:
                'Tek avans ayar kaydını oluşturun ve güncel ayarı bu bölümden yönetin.',
            action: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _isAdvanceSettingsLoading
                      ? null
                      : _loadCurrentAdvanceSettings,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Yenile'),
                ),
                OutlinedButton.icon(
                  onPressed: _showAdvanceSettingsDialog,
                  icon: Icon(
                    _advanceSettings == null ? Icons.add : Icons.edit_outlined,
                    size: 16,
                  ),
                  label: Text(
                    _advanceSettings == null
                        ? 'Ayar Oluştur'
                        : 'Ayarı Güncelle',
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: _isAdvanceSettingsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _AdvanceSettingsCard(setting: _advanceSettings),
            ),
          ),
          const SizedBox(height: 18),
          const _SettingsSectionShell(
            title: 'Disiplin Ayarları',
            subtitle:
                'Disiplin kategorileri, aksiyon tipleri ve kurallar bu bölümde yer alacak.',
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Disiplin ayarları bölümü bir sonraki adımda genişletilecek.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePositionDialog extends StatefulWidget {
  const _CreatePositionDialog({required this.hrService});

  final HRService hrService;

  @override
  State<_CreatePositionDialog> createState() => _CreatePositionDialogState();
}

class _CreatePositionDialogState extends State<_CreatePositionDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isActive = true;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pozisyon adı zorunludur.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.hrService.createPosition(
        HRCreatePositionRequest(
          name: name,
          description: description.isEmpty ? null : description,
          isActive: _isActive,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pozisyon başarıyla oluşturuldu.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pozisyon oluşturulurken hata: $error')),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 760,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8FBFF), Color(0xFFF1F5F9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yeni Pozisyon',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'İnsan kaynakları modülünde kullanılacak yeni pozisyon kaydını oluşturun.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    _MiniPill(
                      label: _isActive ? 'Aktif' : 'Pasif',
                      color: _isActive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
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
                          child: TextField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                                'Pozisyon Adı', 'Örn. Kıdemli Teknisyen'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Durum',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Pozisyon kaydı aktif olarak açılsın',
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isActive,
                                  onChanged: _isSubmitting
                                      ? null
                                      : (value) =>
                                          setState(() => _isActive = value),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        'Açıklama',
                        'Pozisyonun sorumlulukları veya kısa açıklaması',
                      ),
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
                        : () => Navigator.of(context).pop(false),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Pozisyonu Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}

class _LeaveDeductionDialog extends StatefulWidget {
  const _LeaveDeductionDialog({
    required this.hrService,
    this.initialValue,
  });

  final HRService hrService;
  final HRLeaveDeductionResponse? initialValue;

  @override
  State<_LeaveDeductionDialog> createState() => _LeaveDeductionDialogState();
}

class _LeaveDeductionDialogState extends State<_LeaveDeductionDialog> {
  static const List<String> _leaveTypes = [
    'UnpaidLeave',
    'Vacation',
    'SickLeave',
    'PersonalLeave',
    'MaternityLeave',
    'PaternityLeave',
  ];
  static const List<String> _periods = ['Daily'];

  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late String _selectedLeaveType;
  late String _selectedPeriod;
  bool _isSubmitting = false;

  bool get _isEdit => widget.initialValue != null;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialValue?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.initialValue?.deductionAmount.toStringAsFixed(2) ?? '',
    );
    _selectedLeaveType = widget.initialValue?.deductionType ?? 'UnpaidLeave';
    _selectedPeriod = widget.initialValue?.deductionPeriod ?? 'Daily';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));

    if (description.isEmpty) {
      _showSnackBar('Açıklama zorunludur.');
      return;
    }

    if (amount == null || amount < 0) {
      _showSnackBar('Geçerli bir kesinti tutarı girin.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isEdit) {
        await widget.hrService.updateLeaveDeduction(
          widget.initialValue!.id,
          HRUpdateLeaveDeductionRequest(
            description: description,
            deductionType: _selectedLeaveType,
            deductionPeriod: _selectedPeriod,
            deductionAmount: amount,
          ),
        );
      } else {
        await widget.hrService.createLeaveDeduction(
          HRCreateLeaveDeductionRequest(
            description: description,
            deductionType: _selectedLeaveType,
            deductionPeriod: _selectedPeriod,
            deductionAmount: amount,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Kesinti ayarı güncellendi.'
              : 'Kesinti ayarı oluşturuldu.'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('İşlem sırasında hata oluştu: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 760,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8FBFF), Color(0xFFF1F5F9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit
                                ? 'Kesinti Ayarını Düzenle'
                                : 'Yeni İzin Kesinti Ayarı',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'İzin tipine bağlı kesinti tutarını ve hesaplama periyodunu yönetin.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    _MiniPill(
                      label: _leaveTypeLabel(_selectedLeaveType),
                      color: const Color(0xFF2563EB),
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
                          child: _DropdownField(
                            label: 'İzin Tipi',
                            value: _selectedLeaveType,
                            items: _leaveTypes
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(_leaveTypeLabel(item)),
                                    ))
                                .toList(),
                            onChanged: _isSubmitting
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    setState(() => _selectedLeaveType = value);
                                  },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DropdownField(
                            label: 'Periyot',
                            value: _selectedPeriod,
                            items: _periods
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(_periodLabel(item)),
                                    ))
                                .toList(),
                            onChanged: _isSubmitting
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    setState(() => _selectedPeriod = value);
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration(
                              'Kesinti Tutarı',
                              'Örn. 1500.00',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _descriptionController,
                            decoration: _inputDecoration(
                              'Açıklama',
                              'Örn. Ücretsiz izin günlük kesinti tutarı',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Text(
                        'Saatlik kesinti hesaplama akışı henüz aktif değildir. Bu form şimdilik günlük kesinti ayarı için kullanılmalıdır.',
                        style: TextStyle(
                          color: Color(0xFF1D4ED8),
                          fontSize: 13,
                        ),
                      ),
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
                        : () => Navigator.of(context).pop(false),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEdit ? 'Güncelle' : 'Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionShell extends StatelessWidget {
  const _SettingsSectionShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          child,
        ],
      ),
    );
  }
}

class _AdvanceSettingsCard extends StatelessWidget {
  const _AdvanceSettingsCard({required this.setting});

  final HRAdvanceSettingsResponse? setting;

  @override
  Widget build(BuildContext context) {
    if (setting == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'Advance settings henüz yüklenmedi. İlk kurulum için ayar oluşturun veya mevcut ayarı id ile yükleyin.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MiniPill(
                label: setting!.allowFutureAdvances
                    ? 'Taksitli Açık'
                    : 'Taksitli Kapalı',
                color: setting!.allowFutureAdvances
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SettingsMetricPill(
                label: 'Kişi Başı Limit',
                value:
                    '${setting!.maxAdvanceAmountPerPerson.toStringAsFixed(2)} ₺',
              ),
              _SettingsMetricPill(
                label: 'Yıllık Avans Hakkı',
                value: setting!.maxAdvanceCountPerYear.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdvanceSettingsDialog extends StatefulWidget {
  const _AdvanceSettingsDialog({
    required this.hrService,
    this.initialValue,
  });

  final HRService hrService;
  final HRAdvanceSettingsResponse? initialValue;

  @override
  State<_AdvanceSettingsDialog> createState() => _AdvanceSettingsDialogState();
}

class _AdvanceSettingsDialogState extends State<_AdvanceSettingsDialog> {
  late final TextEditingController _maxAmountController;
  late final TextEditingController _maxCountController;
  bool _allowFutureAdvances = false;
  bool _isSubmitting = false;

  bool get _isEdit => widget.initialValue != null;

  @override
  void initState() {
    super.initState();
    _maxAmountController = TextEditingController(
      text: widget.initialValue?.maxAdvanceAmountPerPerson.toStringAsFixed(2) ??
          '',
    );
    _maxCountController = TextEditingController(
      text: widget.initialValue?.maxAdvanceCountPerYear.toString() ?? '',
    );
    _allowFutureAdvances = widget.initialValue?.allowFutureAdvances ?? false;
  }

  @override
  void dispose() {
    _maxAmountController.dispose();
    _maxCountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final maxAmount =
        double.tryParse(_maxAmountController.text.trim().replaceAll(',', '.'));
    final maxCount = int.tryParse(_maxCountController.text.trim());

    if (maxAmount == null || maxAmount < 0) {
      _showSnackBar('Geçerli bir kişi başı avans limiti girin.');
      return;
    }

    if (maxCount == null || maxCount < 0) {
      _showSnackBar('Geçerli bir yıllık avans hakkı girin.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      late final HRAdvanceSettingsResponse response;
      if (_isEdit) {
        response = await widget.hrService.updateAdvanceSettings(
          widget.initialValue!.id,
          HRUpdateAdvanceSettingsRequest(
            maxAdvanceAmountPerPerson: maxAmount,
            maxAdvanceCountPerYear: maxCount,
            allowFutureAdvances: _allowFutureAdvances,
          ),
        );
      } else {
        response = await widget.hrService.createAdvanceSettings(
          HRCreateAdvanceSettingsRequest(
            maxAdvanceAmountPerPerson: maxAmount,
            maxAdvanceCountPerYear: maxCount,
            allowFutureAdvances: _allowFutureAdvances,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Advance settings güncellendi.'
                : 'Advance settings oluşturuldu.',
          ),
        ),
      );
      Navigator.of(context).pop(response);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('İşlem başarısız: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 760,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8FBFF), Color(0xFFF1F5F9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit
                                ? 'Advance Ayarını Güncelle'
                                : 'Advance Ayarı Oluştur',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kişi başı maksimum avans limiti, yıllık avans hakkı ve taksitli avans iznini yönetin.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    _MiniPill(
                      label: _allowFutureAdvances
                          ? 'Taksitli Avans Açık'
                          : 'Taksitli Avans Kapalı',
                      color: _allowFutureAdvances
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
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
                          child: TextField(
                            controller: _maxAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration(
                              'Kişi Başı Maksimum Alınabilecek Avans Miktarı',
                              'Örn. 15000.00',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _maxCountController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              'Yıllık Maksimum Alınabilecek Avans Miktarı',
                              'Örn. 3',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Taksitli Avans',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Personel taksitli avans alabilsin mi?',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _allowFutureAdvances,
                            onChanged: _isSubmitting
                                ? null
                                : (value) => setState(
                                    () => _allowFutureAdvances = value),
                          ),
                        ],
                      ),
                    ),
                    if (widget.initialValue != null) ...[
                      const SizedBox(height: 14)
                    ],
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
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEdit ? 'Güncelle' : 'Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsMetricPill extends StatelessWidget {
  const _SettingsMetricPill({
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

class _LeaveDeductionRow extends StatelessWidget {
  const _LeaveDeductionRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final HRLeaveDeductionResponse item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0EAFF), Color(0xFFF1F5F9)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _leaveTypeLabel(item.deductionType),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _MiniPill(
                      label: _periodLabel(item.deductionPeriod),
                      color: const Color(0xFF2563EB),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kesinti Tutarı',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatCurrency(item.deductionAmount),
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Güncelleme',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(item.updatedAtUtc),
                  style: const TextStyle(color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Düzenle',
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF334155),
                ),
              ),
              IconButton(
                tooltip: 'Sil',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PositionRow extends StatelessWidget {
  const _PositionRow({required this.position});

  final HRPositionResponse position;

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        position.isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
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
                    position.name.isNotEmpty
                        ? position.name.substring(0, 1).toUpperCase()
                        : '?',
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
                        position.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              position.description.isNotEmpty
                  ? position.description
                  : 'Açıklama girilmemiş.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _MiniPill(
                label: position.isActive ? 'Aktif' : 'Pasif',
                color: badgeColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(position.createdAtUtc),
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label, String hint) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
  );
}

String _leaveTypeLabel(String? value) {
  switch (value) {
    case 'Vacation':
      return 'Yıllık İzin';
    case 'SickLeave':
      return 'Hastalık İzni';
    case 'PersonalLeave':
      return 'Mazeret İzni';
    case 'MaternityLeave':
      return 'Doğum İzni';
    case 'PaternityLeave':
      return 'Babalık İzni';
    case 'UnpaidLeave':
      return 'Ücretsiz İzin';
    default:
      return value ?? '-';
  }
}

String _periodLabel(String? value) {
  switch (value) {
    case 'Daily':
      return 'Günlük';
    case 'Hourly':
      return 'Saatlik';
    default:
      return value ?? '-';
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day.$month.${value.year}';
}

String _formatCurrency(double value) {
  final normalized = value.toStringAsFixed(2).replaceAll('.', ',');
  return '₺$normalized';
}
