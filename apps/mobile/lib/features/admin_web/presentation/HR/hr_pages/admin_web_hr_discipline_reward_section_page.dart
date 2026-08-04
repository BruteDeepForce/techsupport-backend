import 'package:flutter/material.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/data/hr_services.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/model/hr_models.dart';

class AdminWebHrDisciplineRewardSectionPage extends StatefulWidget {
  const AdminWebHrDisciplineRewardSectionPage({super.key});

  @override
  State<AdminWebHrDisciplineRewardSectionPage> createState() =>
      _AdminWebHrDisciplineRewardSectionPageState();
}

class _AdminWebHrDisciplineRewardSectionPageState
    extends State<AdminWebHrDisciplineRewardSectionPage> {
  final HRService _hrService = HRService();

  late Future<List<HRDisciplineResponse>> _disciplinesFuture;
  late Future<List<HRRewardResponse>> _rewardsFuture;
  late Future<List<HRDisciplineEmployeeRecordResponse>>
      _disciplineRecordsFuture;
  late Future<List<HRRewardEmployeeRecordResponse>> _rewardRecordsFuture;
  late Future<HREmployeeLargeDetailResponse> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _reloadAll();
  }

  void _reloadAll() {
    _disciplinesFuture = _hrService.getDisciplines();
    _rewardsFuture = _hrService.getRewards();
    _disciplineRecordsFuture = _hrService.getDisciplineRecords();
    _rewardRecordsFuture = _hrService.getRewardRecords();
    _employeesFuture = _hrService.getLargeDetailEmployees();
  }

  Future<void> _refresh() async {
    setState(_reloadAll);
  }

  Future<void> _showCreateDisciplineDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateDisciplineDialog(hrService: _hrService),
    );

    if (created == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _showEditDisciplineDialog(HRDisciplineResponse item) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateDisciplineDialog(
        hrService: _hrService,
        initialValue: item,
      ),
    );

    if (changed == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _showCreateRewardDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateRewardDialog(hrService: _hrService),
    );

    if (created == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _showEditRewardDialog(HRRewardResponse item) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateRewardDialog(
        hrService: _hrService,
        initialValue: item,
      ),
    );

    if (changed == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _showCreateDisciplineRecordDialog(
    List<EmployeeResponse> employees,
    List<HRDisciplineResponse> disciplines,
  ) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateDisciplineRecordDialog(
        hrService: _hrService,
        employees: employees,
        disciplines: disciplines,
      ),
    );

    if (created == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _showEditDisciplineRecordDialog(
    HRDisciplineEmployeeRecordResponse item,
    List<EmployeeResponse> employees,
    List<HRDisciplineResponse> disciplines,
  ) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateDisciplineRecordDialog(
        hrService: _hrService,
        employees: employees,
        disciplines: disciplines,
        initialValue: item,
      ),
    );

    if (changed == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _showCreateRewardRecordDialog(
    List<EmployeeResponse> employees,
    List<HRRewardResponse> rewards,
  ) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateRewardRecordDialog(
        hrService: _hrService,
        employees: employees,
        rewards: rewards,
      ),
    );

    if (created == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _showEditRewardRecordDialog(
    HRRewardEmployeeRecordResponse item,
    List<EmployeeResponse> employees,
    List<HRRewardResponse> rewards,
  ) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateRewardRecordDialog(
        hrService: _hrService,
        employees: employees,
        rewards: rewards,
        initialValue: item,
      ),
    );

    if (changed == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HREmployeeLargeDetailResponse>(
      future: _employeesFuture,
      builder: (context, employeeSnapshot) {
        final employees =
            employeeSnapshot.data?.employees ?? const <EmployeeResponse>[];

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
                  'Disiplin ve ödül süreçlerini tanımlayın, ardından bu tanımları personele kayıt olarak uygulayın.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<List<HRDisciplineResponse>>(
                      future: _disciplinesFuture,
                      builder: (context, snapshot) => _OverviewCard(
                        title: 'Disiplin Tanımları',
                        value: '${snapshot.data?.length ?? 0}',
                        accent: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<List<HRRewardResponse>>(
                      future: _rewardsFuture,
                      builder: (context, snapshot) => _OverviewCard(
                        title: 'Ödül Tanımları',
                        value: '${snapshot.data?.length ?? 0}',
                        accent: const Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        FutureBuilder<List<HRDisciplineEmployeeRecordResponse>>(
                      future: _disciplineRecordsFuture,
                      builder: (context, snapshot) => _OverviewCard(
                        title: 'Disiplin Kayıtları',
                        value: '${snapshot.data?.length ?? 0}',
                        accent: const Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<List<HRRewardEmployeeRecordResponse>>(
                      future: _rewardRecordsFuture,
                      builder: (context, snapshot) => _OverviewCard(
                        title: 'Ödül Kayıtları',
                        value: '${snapshot.data?.length ?? 0}',
                        accent: const Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SectionCard(
                      title: 'Disiplin Tanımları',
                      subtitle: 'Ceza tipi ve ceza tutarını yönetin.',
                      action: OutlinedButton.icon(
                        onPressed: _showCreateDisciplineDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Yeni Disiplin'),
                      ),
                      child: FutureBuilder<List<HRDisciplineResponse>>(
                        future: _disciplinesFuture,
                        builder: (context, snapshot) {
                          final items =
                              snapshot.data ?? const <HRDisciplineResponse>[];
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (items.isEmpty) {
                            return const _EmptyState(
                              message: 'Henüz disiplin tanımı bulunmuyor.',
                            );
                          }
                          return Column(
                            children: items
                                .map((item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _CatalogRow(
                                        title: item.description,
                                        amount: item.penaltyAmount,
                                        accent: const Color(0xFFDC2626),
                                        caption:
                                            'Ceza tutarı ${_currency(item.penaltyAmount)}',
                                        updatedAt: item.updatedAtUtc,
                                        onEdit: () =>
                                            _showEditDisciplineDialog(item),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _SectionCard(
                      title: 'Ödül Tanımları',
                      subtitle: 'Ödül tipi ve prim tutarını yönetin.',
                      action: OutlinedButton.icon(
                        onPressed: _showCreateRewardDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Yeni Ödül'),
                      ),
                      child: FutureBuilder<List<HRRewardResponse>>(
                        future: _rewardsFuture,
                        builder: (context, snapshot) {
                          final items =
                              snapshot.data ?? const <HRRewardResponse>[];
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (items.isEmpty) {
                            return const _EmptyState(
                              message: 'Henüz ödül tanımı bulunmuyor.',
                            );
                          }
                          return Column(
                            children: items
                                .map((item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _CatalogRow(
                                        title: item.description,
                                        amount: item.rewardAmount,
                                        accent: const Color(0xFF7C3AED),
                                        caption:
                                            'Ödül tutarı ${_currency(item.rewardAmount)}',
                                        updatedAt: item.updatedAtUtc,
                                        onEdit: () => _showEditRewardDialog(item),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Personele Tesis Edilen Disiplin İşlemleri',
                subtitle:
                    'Personel bazlı disiplin kayıtlarını oluşturun ve izleyin.',
                action: OutlinedButton.icon(
                  onPressed: employees.isEmpty
                      ? null
                      : () async {
                          final disciplines = await _disciplinesFuture;
                          if (!mounted) return;
                          if (disciplines.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Önce en az bir disiplin tanımı oluşturun.',
                                ),
                              ),
                            );
                            return;
                          }
                          _showCreateDisciplineRecordDialog(
                            employees,
                            disciplines,
                          );
                        },
                  icon: const Icon(Icons.gavel_outlined, size: 16),
                  label: const Text('Disiplin Kaydı Ekle'),
                ),
                child: FutureBuilder<List<HRDisciplineResponse>>(
                  future: _disciplinesFuture,
                  builder: (context, disciplineSnapshot) {
                    final disciplines = disciplineSnapshot.data ??
                        const <HRDisciplineResponse>[];
                    return FutureBuilder<
                        List<HRDisciplineEmployeeRecordResponse>>(
                      future: _disciplineRecordsFuture,
                      builder: (context, snapshot) {
                        final items = snapshot.data ??
                            const <HRDisciplineEmployeeRecordResponse>[];
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            disciplineSnapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (items.isEmpty) {
                          return const _EmptyState(
                            message:
                                'Henüz personele uygulanmış disiplin kaydı yok.',
                          );
                        }
                        return Column(
                          children: items
                              .map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _RecordRow(
                                      title: _employeeName(
                                          employees, item.employeeId),
                                      tag: _disciplineName(
                                        disciplines,
                                        item.disciplineId,
                                      ),
                                      description: item.description,
                                      date: item.incidentDate,
                                      accent: const Color(0xFFDC2626),
                                      onEdit: () =>
                                          _showEditDisciplineRecordDialog(
                                        item,
                                        employees,
                                        disciplines,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Personele Uygulanan Ödüller',
                subtitle:
                    'Personel bazlı ödül kayıtlarını oluşturun ve izleyin.',
                action: OutlinedButton.icon(
                  onPressed: employees.isEmpty
                      ? null
                      : () async {
                          final rewards = await _rewardsFuture;
                          if (!mounted) return;
                          if (rewards.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Önce en az bir ödül tanımı oluşturun.',
                                ),
                              ),
                            );
                            return;
                          }
                          _showCreateRewardRecordDialog(employees, rewards);
                        },
                  icon: const Icon(Icons.workspace_premium_outlined, size: 16),
                  label: const Text('Ödül Kaydı Ekle'),
                ),
                child: FutureBuilder<List<HRRewardResponse>>(
                  future: _rewardsFuture,
                  builder: (context, rewardSnapshot) {
                    final rewards =
                        rewardSnapshot.data ?? const <HRRewardResponse>[];
                    return FutureBuilder<List<HRRewardEmployeeRecordResponse>>(
                      future: _rewardRecordsFuture,
                      builder: (context, snapshot) {
                        final items = snapshot.data ??
                            const <HRRewardEmployeeRecordResponse>[];
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            rewardSnapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (items.isEmpty) {
                          return const _EmptyState(
                            message:
                                'Henüz personele uygulanmış ödül kaydı yok.',
                          );
                        }
                        return Column(
                          children: items
                              .map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _RecordRow(
                                      title: _employeeName(
                                          employees, item.employeeId),
                                      tag: _rewardName(rewards, item.rewardId),
                                      description: item.description,
                                      date: item.rewardDate,
                                      accent: const Color(0xFF7C3AED),
                                      onEdit: () => _showEditRewardRecordDialog(
                                        item,
                                        employees,
                                        rewards,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({
    required this.title,
    required this.amount,
    required this.caption,
    required this.updatedAt,
    required this.accent,
    this.onEdit,
  });

  final String title;
  final double amount;
  final String caption;
  final DateTime updatedAt;
  final Color accent;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.label_outline, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  caption,
                  style: const TextStyle(color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(updatedAt),
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Düzenle',
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF334155),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.title,
    required this.tag,
    required this.description,
    required this.date,
    required this.accent,
    this.onEdit,
  });

  final String title;
  final String tag;
  final String description;
  final DateTime date;
  final Color accent;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _TagChip(label: tag, color: accent),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatDate(date),
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Düzenle',
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF334155),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});

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
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }
}

class _CreateDisciplineDialog extends StatefulWidget {
  const _CreateDisciplineDialog({
    required this.hrService,
    this.initialValue,
  });

  final HRService hrService;
  final HRDisciplineResponse? initialValue;

  @override
  State<_CreateDisciplineDialog> createState() =>
      _CreateDisciplineDialogState();
}

class _CreateDisciplineDialogState extends State<_CreateDisciplineDialog> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  bool _isSubmitting = false;

  bool get _isEdit => widget.initialValue != null;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.initialValue?.description ?? '');
    _amountController = TextEditingController(
      text: widget.initialValue?.penaltyAmount.toStringAsFixed(2) ?? '',
    );
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

    if (description.isEmpty || amount == null || amount < 0) {
      _showSnackBar('Geçerli açıklama ve tutar girin.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isEdit) {
        await widget.hrService.updateDiscipline(
          widget.initialValue!.id,
          HRUpdateDisciplineRequest(
            description: description,
            penaltyAmount: amount,
          ),
        );
      } else {
        await widget.hrService.createDiscipline(
          HRCreateDisciplineRequest(
            description: description,
            penaltyAmount: amount,
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Disiplin oluşturulamadı: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => _SimpleAmountDialog(
        title: _isEdit ? 'Disiplini Düzenle' : 'Yeni Disiplin',
        subtitle: _isEdit
            ? 'Disiplin tanımını güncelleyin.'
            : 'Personelde kullanılacak disiplin tanımını oluşturun.',
        descriptionController: _descriptionController,
        amountController: _amountController,
        amountLabel: 'Ceza Tutarı',
        buttonLabel: _isEdit ? 'Güncelle' : 'Disiplini Kaydet',
        isSubmitting: _isSubmitting,
        onSubmit: _submit,
      );
}

class _CreateRewardDialog extends StatefulWidget {
  const _CreateRewardDialog({
    required this.hrService,
    this.initialValue,
  });

  final HRService hrService;
  final HRRewardResponse? initialValue;

  @override
  State<_CreateRewardDialog> createState() => _CreateRewardDialogState();
}

class _CreateRewardDialogState extends State<_CreateRewardDialog> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  bool _isSubmitting = false;

  bool get _isEdit => widget.initialValue != null;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.initialValue?.description ?? '');
    _amountController = TextEditingController(
      text: widget.initialValue?.rewardAmount.toStringAsFixed(2) ?? '',
    );
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

    if (description.isEmpty || amount == null || amount < 0) {
      _showSnackBar('Geçerli açıklama ve tutar girin.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isEdit) {
        await widget.hrService.updateReward(
          widget.initialValue!.id,
          HRUpdateRewardRequest(
            description: description,
            rewardAmount: amount,
          ),
        );
      } else {
        await widget.hrService.createReward(
          HRCreateRewardRequest(
            description: description,
            rewardAmount: amount,
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Ödül oluşturulamadı: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => _SimpleAmountDialog(
        title: _isEdit ? 'Ödülü Düzenle' : 'Yeni Ödül',
        subtitle: _isEdit
            ? 'Ödül tanımını güncelleyin.'
            : 'Personelde kullanılacak ödül tanımını oluşturun.',
        descriptionController: _descriptionController,
        amountController: _amountController,
        amountLabel: 'Ödül Tutarı',
        buttonLabel: _isEdit ? 'Güncelle' : 'Ödülü Kaydet',
        isSubmitting: _isSubmitting,
        onSubmit: _submit,
      );
}

class _SimpleAmountDialog extends StatelessWidget {
  const _SimpleAmountDialog({
    required this.title,
    required this.subtitle,
    required this.descriptionController,
    required this.amountController,
    required this.amountLabel,
    required this.buttonLabel,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final String title;
  final String subtitle;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final String amountLabel;
  final String buttonLabel;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 680,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 18),
            TextField(
              controller: descriptionController,
              decoration: _inputDecoration('Açıklama', 'Örn. Geç Kalma'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration(amountLabel, 'Örn. 500.00'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(buttonLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateDisciplineRecordDialog extends StatefulWidget {
  const _CreateDisciplineRecordDialog({
    required this.hrService,
    required this.employees,
    required this.disciplines,
    this.initialValue,
  });

  final HRService hrService;
  final List<EmployeeResponse> employees;
  final List<HRDisciplineResponse> disciplines;
  final HRDisciplineEmployeeRecordResponse? initialValue;

  @override
  State<_CreateDisciplineRecordDialog> createState() =>
      _CreateDisciplineRecordDialogState();
}

class _CreateDisciplineRecordDialogState
    extends State<_CreateDisciplineRecordDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  late String _selectedEmployeeId;
  late String _selectedDisciplineId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  bool get _isEdit => widget.initialValue != null;

  @override
  void initState() {
    super.initState();
    _selectedEmployeeId =
        widget.initialValue?.employeeId ?? widget.employees.first.id;
    _selectedDisciplineId =
        widget.initialValue?.disciplineId ?? widget.disciplines.first.id;
    _selectedDate = widget.initialValue?.incidentDate ?? DateTime.now();
    _descriptionController.text = widget.initialValue?.description ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showSnackBar('Açıklama zorunludur.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isEdit) {
        await widget.hrService.updateDisciplineRecord(
          widget.initialValue!.id,
          HRUpdateDisciplineEmployeeRecordRequest(
            disciplineId: _selectedDisciplineId,
            description: description,
            incidentDate: _selectedDate,
          ),
        );
      } else {
        await widget.hrService.createDisciplineRecord(
          HRCreateDisciplineEmployeeRecordRequest(
            employeeId: _selectedEmployeeId,
            disciplineId: _selectedDisciplineId,
            description: description,
            incidentDate: _selectedDate,
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Disiplin kaydı oluşturulamadı: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => _RecordDialogShell(
        title: _isEdit ? 'Disiplin Kaydını Düzenle' : 'Disiplin Kaydı Ekle',
        subtitle: _isEdit
            ? 'Mevcut disiplin kaydını güncelleyin.'
            : 'Seçilen personele disiplin kaydı tesis edin.',
        employees: widget.employees,
        selectedEmployeeId: _selectedEmployeeId,
        onEmployeeChanged:
            _isEdit ? null : (value) => setState(() => _selectedEmployeeId = value!),
        catalogItems: widget.disciplines
            .map((item) => DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(item.description),
                ))
            .toList(),
        selectedCatalogId: _selectedDisciplineId,
        onCatalogChanged: (value) =>
            setState(() => _selectedDisciplineId = value!),
        catalogLabel: 'Disiplin',
        descriptionController: _descriptionController,
        selectedDate: _selectedDate,
        onPickDate: _pickDate,
        isSubmitting: _isSubmitting,
        onSubmit: _submit,
        submitLabel: _isEdit ? 'Güncelle' : 'Disiplin Kaydı Oluştur',
      );
}

class _CreateRewardRecordDialog extends StatefulWidget {
  const _CreateRewardRecordDialog({
    required this.hrService,
    required this.employees,
    required this.rewards,
    this.initialValue,
  });

  final HRService hrService;
  final List<EmployeeResponse> employees;
  final List<HRRewardResponse> rewards;
  final HRRewardEmployeeRecordResponse? initialValue;

  @override
  State<_CreateRewardRecordDialog> createState() =>
      _CreateRewardRecordDialogState();
}

class _CreateRewardRecordDialogState extends State<_CreateRewardRecordDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  late String _selectedEmployeeId;
  late String _selectedRewardId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  bool get _isEdit => widget.initialValue != null;

  @override
  void initState() {
    super.initState();
    _selectedEmployeeId =
        widget.initialValue?.employeeId ?? widget.employees.first.id;
    _selectedRewardId =
        widget.initialValue?.rewardId ?? widget.rewards.first.id;
    _selectedDate = widget.initialValue?.rewardDate ?? DateTime.now();
    _descriptionController.text = widget.initialValue?.description ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showSnackBar('Açıklama zorunludur.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isEdit) {
        await widget.hrService.updateRewardRecord(
          widget.initialValue!.id,
          HRUpdateRewardEmployeeRecordRequest(
            rewardId: _selectedRewardId,
            description: description,
            rewardDate: _selectedDate,
          ),
        );
      } else {
        await widget.hrService.createRewardRecord(
          HRCreateRewardEmployeeRecordRequest(
            employeeId: _selectedEmployeeId,
            rewardId: _selectedRewardId,
            description: description,
            rewardDate: _selectedDate,
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Ödül kaydı oluşturulamadı: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => _RecordDialogShell(
        title: _isEdit ? 'Ödül Kaydını Düzenle' : 'Ödül Kaydı Ekle',
        subtitle: _isEdit
            ? 'Mevcut ödül kaydını güncelleyin.'
            : 'Seçilen personele ödül kaydı tesis edin.',
        employees: widget.employees,
        selectedEmployeeId: _selectedEmployeeId,
        onEmployeeChanged:
            _isEdit ? null : (value) => setState(() => _selectedEmployeeId = value!),
        catalogItems: widget.rewards
            .map((item) => DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(item.description),
                ))
            .toList(),
        selectedCatalogId: _selectedRewardId,
        onCatalogChanged: (value) => setState(() => _selectedRewardId = value!),
        catalogLabel: 'Ödül',
        descriptionController: _descriptionController,
        selectedDate: _selectedDate,
        onPickDate: _pickDate,
        isSubmitting: _isSubmitting,
        onSubmit: _submit,
        submitLabel: _isEdit ? 'Güncelle' : 'Ödül Kaydı Oluştur',
      );
}

class _RecordDialogShell extends StatelessWidget {
  const _RecordDialogShell({
    required this.title,
    required this.subtitle,
    required this.employees,
    required this.selectedEmployeeId,
    required this.onEmployeeChanged,
    required this.catalogItems,
    required this.selectedCatalogId,
    required this.onCatalogChanged,
    required this.catalogLabel,
    required this.descriptionController,
    required this.selectedDate,
    required this.onPickDate,
    required this.isSubmitting,
    required this.onSubmit,
    required this.submitLabel,
  });

  final String title;
  final String subtitle;
  final List<EmployeeResponse> employees;
  final String selectedEmployeeId;
  final ValueChanged<String?>? onEmployeeChanged;
  final List<DropdownMenuItem<String>> catalogItems;
  final String selectedCatalogId;
  final ValueChanged<String?> onCatalogChanged;
  final String catalogLabel;
  final TextEditingController descriptionController;
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 760,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _dropdownField(
                    label: 'Personel',
                    value: selectedEmployeeId,
                    items: employees
                        .map((employee) => DropdownMenuItem<String>(
                              value: employee.id,
                              child: Text(employee.fullName),
                            ))
                        .toList(),
                    onChanged: onEmployeeChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _dropdownField(
                    label: catalogLabel,
                    value: selectedCatalogId,
                    items: catalogItems,
                    onChanged: onCatalogChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration:
                  _inputDecoration('Açıklama', 'Olay veya işlem açıklaması'),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: onPickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: _inputDecoration('Tarih', 'Tarih seçin').copyWith(
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(_formatDate(selectedDate)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(submitLabel),
                ),
              ],
            ),
          ],
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

Widget _dropdownField({
  required String label,
  required String value,
  required List<DropdownMenuItem<String>> items,
  required ValueChanged<String?>? onChanged,
}) {
  return InputDecorator(
    decoration: _inputDecoration(label, ''),
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

String _currency(double value) =>
    '₺${value.toStringAsFixed(2).replaceAll('.', ',')}';

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day.$month.${value.year}';
}

String _employeeName(List<EmployeeResponse> employees, String employeeId) {
  for (final employee in employees) {
    if (employee.id == employeeId) return employee.fullName;
  }
  return 'Personel';
}

String _disciplineName(List<HRDisciplineResponse> items, String disciplineId) {
  for (final item in items) {
    if (item.id == disciplineId) return item.description;
  }
  return 'Disiplin';
}

String _rewardName(List<HRRewardResponse> items, String rewardId) {
  for (final item in items) {
    if (item.id == rewardId) return item.description;
  }
  return 'Ödül';
}
