import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/data/hr_services.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/model/hr_models.dart';

import '../../../core/design/app_design.dart';
import '../../auth/data/token_storage.dart';
import '../data/technician_service.dart';
import '../models/technician_models.dart';
import 'technician_hr_profile_page.dart';

class TechnicianHrPage extends StatefulWidget {
  const TechnicianHrPage({super.key});

  @override
  State<TechnicianHrPage> createState() => _TechnicianHrPageState();
}

class _TechnicianHrPageState extends State<TechnicianHrPage> {
  final TechnicianService _technicianService = TechnicianService();
  final HRService _hrService = HRService();
  final TokenStorage _tokenStorage = TokenStorage();
  late Future<Technician?> _meFuture;
  late Future<TechnicianEmployeeProfile> _employeeProfileFuture;

  @override
  void initState() {
    super.initState();
    _meFuture = _loadMe();
    _employeeProfileFuture = _technicianService.getEmployeeProfileByClaimUser();
  }

  Future<void> _showCreateLeaveDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateLeaveDialog(
        hrService: _hrService,
      ),
    );
    if (created == true && mounted) {
      setState(() {
        _employeeProfileFuture =
            _technicianService.getEmployeeProfileByClaimUser();
      });
    }
  }

  Future<Technician?> _loadMe() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) return null;
    final payload = _decodeJwtPayload(token);
    final userId = payload['user_id']?.toString();
    if (userId == null || userId.isEmpty) return null;
    return _technicianService.getTechnician(userId);
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = String.fromCharCodes(base64Url.decode(normalized));
    return decoded.isNotEmpty
        ? jsonDecode(decoded) as Map<String, dynamic>
        : {};
  }

  void _showMockMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title ekranı sonraki adımda bağlanacak.')),
    );
  }

  Future<void> _openProfileDetailsPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const TechnicianHrProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Technician?>(
      future: _meFuture,
      builder: (context, snapshot) {
        final technician = snapshot.data;

        return LinearPageShell(
          title: 'Özlük Bilgileri',
          subtitle: 'Personel bilgileri ve talepler',
          showBack: true,
          tabBar: LinearTabBar(
            items: [
              LinearTabItem(
                icon: Icons.assignment_outlined,
                label: 'İş Emirleri',
                onTap: () => Navigator.of(context).pop(),
              ),
              const LinearTabItem(
                icon: Icons.confirmation_number_outlined,
                label: 'Talepler',
              ),
              const LinearTabItem(
                icon: Icons.badge_outlined,
                label: 'Özlük',
                active: true,
              ),
              const LinearTabItem(
                icon: Icons.logout_rounded,
                label: 'Çıkış',
              ),
            ],
          ),
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearCard(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 12),
                      Text('Personel bilgileri yükleniyor...'),
                    ],
                  ),
                ),
              )
            else ...[
              _HrHeroCard(
                technician: technician,
                onCreateLeave: _showCreateLeaveDialog,
                onCreateAdvance: () => _showMockMessage('Avans talebi'),
              ),
              const SizedBox(height: 12),
              _CompactActionCard(
                title: 'Diğer İşlemler',
                items: [
                  _ActionItemData(
                    icon: Icons.folder_open_outlined,
                    title: 'Belgelerim',
                    subtitle: 'Sözleşme ve özlük dosyalarını görüntüle',
                    onTap: () => _showMockMessage('Belgelerim'),
                  ),
                  _ActionItemData(
                    icon: Icons.person_outline_rounded,
                    title: 'Bilgilerim',
                    subtitle: 'Kişisel ve çalışma bilgilerini görüntüle',
                    onTap: _openProfileDetailsPage,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<TechnicianEmployeeProfile>(
                future: _employeeProfileFuture,
                builder: (context, profileSnapshot) {
                  final leaveItems = profileSnapshot.hasData
                      ? _buildLeaveRequestItems(profileSnapshot.data!)
                      : const <_RequestItemData>[];
                  final advanceItems = profileSnapshot.hasData
                      ? _buildAdvanceRequestItems(profileSnapshot.data!)
                      : const <_RequestItemData>[];

                  return Column(
                    children: [
                      _RequestCard(
                        title: 'İzin Talepleri',
                        actionLabel: 'Tüm izinler',
                        onTapAction: () => _showMockMessage('İzin talepleri'),
                        items: leaveItems,
                        isLoading: profileSnapshot.connectionState ==
                            ConnectionState.waiting,
                        errorText: profileSnapshot.hasError
                            ? 'İzin talepleri yüklenemedi.'
                            : null,
                        emptyText: 'Henüz izin talebi bulunmuyor.',
                      ),
                      const SizedBox(height: 10),
                      _RequestCard(
                        title: 'Avans Talepleri',
                        actionLabel: 'Tüm avanslar',
                        onTapAction: () => _showMockMessage('Avans talepleri'),
                        items: advanceItems,
                        isLoading: profileSnapshot.connectionState ==
                            ConnectionState.waiting,
                        errorText: profileSnapshot.hasError
                            ? 'Avans talepleri yüklenemedi.'
                            : null,
                        emptyText: 'Henüz avans talebi bulunmuyor.',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Çalışma Bilgileri',
                items: [
                  _InfoItemData(
                    label: 'Pozisyon',
                    value: (technician?.specializations?.isNotEmpty ?? false)
                        ? technician!.specializations!.join(', ')
                        : 'Teknisyen',
                  ),
                  _InfoItemData(
                    label: 'Durum',
                    value: technician?.isActive == false ? 'Pasif' : 'Aktif',
                  ),
                  _InfoItemData(
                    label: 'E-posta',
                    value: technician?.email.isNotEmpty == true
                        ? technician!.email
                        : 'Tanımlanmadı',
                  ),
                  _InfoItemData(
                    label: 'Telefon',
                    value: technician?.phoneNumber?.isNotEmpty == true
                        ? technician!.phoneNumber!
                        : 'Tanımlanmadı',
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CreateLeaveDialog extends StatefulWidget {
  const _CreateLeaveDialog({
    required this.hrService,
  });

  final HRService hrService;

  @override
  _CreateLeaveDialogState createState() => _CreateLeaveDialogState();
}

class _CreateLeaveDialogState extends State<_CreateLeaveDialog> {
  static const List<_LeaveTypeOption> _leaveTypes = [
    _LeaveTypeOption(value: 'Vacation', label: 'Yıllık İzin'),
    _LeaveTypeOption(value: 'SickLeave', label: 'Hastalık İzni'),
    _LeaveTypeOption(value: 'PersonalLeave', label: 'Mazeret İzni'),
    _LeaveTypeOption(value: 'MaternityLeave', label: 'Doğum İzni'),
    _LeaveTypeOption(value: 'PaternityLeave', label: 'Babalık İzni'),
    _LeaveTypeOption(value: 'UnpaidLeave', label: 'Ücretsiz İzin'),
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedLeaveType = _leaveTypes.first.value;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;
    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day);
      _startDateController.text = _formatDate(_startDate!);
      if (_endDate != null && _endDate!.isBefore(_startDate!)) {
        _endDate = _startDate;
        _endDateController.text = _formatDate(_endDate!);
      }
    });
  }

  Future<void> _pickEndDate() async {
    final initialDate = _endDate ?? _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;
    setState(() {
      _endDate = DateTime(picked.year, picked.month, picked.day);
      _endDateController.text = _formatDate(_endDate!);
    });
  }

  Future<void> _submit() async {
    if (_selectedLeaveType == null || _selectedLeaveType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir izin tipi seçin.')),
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlangıç ve bitiş tarihini seçin.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.hrService.requestLeaveByEmployee(
        HRLeaveRequestByEmployee(
          startDate: _startDate!,
          endDate: _endDate!,
          type: _selectedLeaveType!,
          reason: _reasonController.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İzin talebi oluşturuldu.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İzin talebi oluşturulamadı: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day.$month.$year';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('İzin Talebi Oluştur'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İzin tipi, tarih aralığı ve açıklama bilgilerini girin.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLeaveType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'İzin Tipi',
                    border: OutlineInputBorder(),
                  ),
                  items: _leaveTypes
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.value,
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedLeaveType = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  onTap: _pickStartDate,
                  decoration: const InputDecoration(
                    labelText: 'Başlangıç Tarihi',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  validator: (_) =>
                      _startDate == null ? 'Başlangıç tarihi seçin.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  onTap: _pickEndDate,
                  decoration: const InputDecoration(
                    labelText: 'Bitiş Tarihi',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  validator: (_) =>
                      _endDate == null ? 'Bitiş tarihi seçin.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Açıklama girin.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Gönder'),
        ),
      ],
    );
  }
}

class _LeaveTypeOption {
  const _LeaveTypeOption({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

class _HrHeroCard extends StatelessWidget {
  const _HrHeroCard({
    required this.technician,
    required this.onCreateLeave,
    required this.onCreateAdvance,
  });

  final Technician? technician;
  final VoidCallback onCreateLeave;
  final VoidCallback onCreateAdvance;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  size: 22,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technician?.name.isNotEmpty == true
                          ? technician!.name
                          : 'Teknisyen Personel',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technician?.email.isNotEmpty == true
                          ? technician!.email
                          : 'Personel hesabı',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              LinearBadge(
                label: technician?.isActive == false ? 'Pasif' : 'Aktif',
                color: technician?.isActive == false
                    ? AppColors.statusGray
                    : AppColors.statusGreen,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'İzin ve avans taleplerinizi oluşturun, personel kayıtlarınızı tek ekrandan takip edin.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCreateLeave,
                  icon: const Icon(Icons.event_note_outlined, size: 18),
                  label: const Text('İzin Talebi'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCreateAdvance,
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                  ),
                  label: const Text('Avans Talebi'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<_RequestItemData> _buildLeaveRequestItems(
    TechnicianEmployeeProfile profile) {
  final items = [...profile.employeeLeaves];
  items.sort((a, b) {
    final aDate = a.createdAtUtc ?? a.startDate;
    final bDate = b.createdAtUtc ?? b.startDate;
    return bDate.compareTo(aDate);
  });

  return items.take(3).map((leave) {
    return _RequestItemData(
      title: _formatLeaveType(leave.type),
      subtitle:
          '${_formatShortDate(leave.startDate)} - ${_formatShortDate(leave.endDate)}',
      badgeLabel: _formatRequestStatus(leave.status),
      badgeColor: _statusColor(leave.status),
    );
  }).toList();
}

List<_RequestItemData> _buildAdvanceRequestItems(
  TechnicianEmployeeProfile profile,
) {
  final items = [...profile.employeeAdvances];
  items.sort((a, b) {
    final aDate = a.createdAtUtc ?? DateTime(1900);
    final bDate = b.createdAtUtc ?? DateTime(1900);
    return bDate.compareTo(aDate);
  });

  return items.take(3).map((advance) {
    final amountText = advance.amount != null
        ? _formatCompactMoney(advance.amount!)
        : 'Tutar yok';
    return _RequestItemData(
      title: 'Avans Talebi',
      subtitle: '$amountText • ${_formatShortDate(advance.createdAtUtc)}',
      badgeLabel: _formatRequestStatus(advance.status),
      badgeColor: _statusColor(advance.status),
    );
  }).toList();
}

String _formatLeaveType(String? rawType) {
  switch ((rawType ?? '').toLowerCase()) {
    case 'vacation':
      return 'Yıllık İzin';
    case 'sickleave':
      return 'Hastalık İzni';
    case 'personalleave':
      return 'Mazeret İzni';
    case 'maternityleave':
      return 'Doğum İzni';
    case 'paternityleave':
      return 'Babalık İzni';
    case 'unpaidleave':
      return 'Ücretsiz İzin';
    default:
      return 'İzin Talebi';
  }
}

String _formatRequestStatus(String rawStatus) {
  switch (rawStatus.toLowerCase()) {
    case 'pending':
      return 'Beklemede';
    case 'approved':
      return 'Onaylandı';
    case 'rejected':
      return 'Reddedildi';
    default:
      return rawStatus;
  }
}

Color _statusColor(String rawStatus) {
  switch (rawStatus.toLowerCase()) {
    case 'pending':
      return AppColors.statusOrange;
    case 'approved':
      return AppColors.statusGreen;
    case 'rejected':
      return AppColors.statusRed;
    default:
      return AppColors.statusGray;
  }
}

String _formatShortDate(DateTime? value) {
  if (value == null) return 'Tarih yok';
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  return '$day.$month.$year';
}

String _formatCompactMoney(double value) {
  final fixed = value.toStringAsFixed(0);
  return '₺$fixed';
}

class _CompactActionCard extends StatelessWidget {
  const _CompactActionCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_ActionItemData> items;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          for (int index = 0; index < items.length; index++)
            _ActionRow(
              data: items[index],
              showDivider: index != items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.data,
    required this.showDivider,
  });

  final _ActionItemData data;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: AppColors.borderSubtle),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.title,
    required this.actionLabel,
    required this.onTapAction,
    required this.items,
    this.isLoading = false,
    this.errorText,
    this.emptyText,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTapAction;
  final List<_RequestItemData> items;
  final bool isLoading;
  final String? errorText;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onTapAction,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Veriler yükleniyor...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else if (errorText != null)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                emptyText ?? 'Kayıt bulunmuyor.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            for (int index = 0; index < items.length; index++)
              _RequestRow(
                item: items[index],
                showDivider: index != items.length - 1,
              ),
        ],
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.item,
    required this.showDivider,
  });

  final _RequestItemData item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          LinearBadge(label: item.badgeLabel, color: item.badgeColor),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_InfoItemData> items;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          for (int index = 0; index < items.length; index++)
            _InfoRow(
              item: items[index],
              showDivider: index != items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.item,
    required this.showDivider,
  });

  final _InfoItemData item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              item.value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItemData {
  const _ActionItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _RequestItemData {
  const _RequestItemData({
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.badgeColor,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final Color badgeColor;
}

class _InfoItemData {
  const _InfoItemData({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}
