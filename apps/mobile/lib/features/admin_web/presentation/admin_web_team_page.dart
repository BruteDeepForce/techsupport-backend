import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../presentation/HR/data/hr_services.dart';
import '../presentation/HR/model/hr_models.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';
import 'admin_web_technician_detail_page.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';

class AdminWebTeamPage extends StatefulWidget {
  const AdminWebTeamPage({super.key});

  @override
  State<AdminWebTeamPage> createState() => _AdminWebTeamPageState();
}

enum _TeamPageTab { people, shifts }

class _ShiftEmployeeOption {
  const _ShiftEmployeeOption({
    required this.employeeId,
    required this.label,
    required this.role,
  });

  final String employeeId;
  final String label;
  final String role;
}

class _AdminWebTeamPageState extends State<AdminWebTeamPage> {
  final TechnicianService _technicianService = TechnicianService();
  final HRService _hrService = HRService();
  late Future<List<Technician>> _techniciansFuture;
  late Future<HREmployeeLargeDetailResponse> _employeesFuture;
  late Future<List<ShiftTemplateModel>> _shiftTemplatesFuture;
  late Future<List<ShiftAssignmentModel>> _plannedAssignmentsFuture;
  _TeamPageTab _activeTab = _TeamPageTab.people;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  void _refresh() {
    _refreshAll();
  }

  void _refreshAll() {
    setState(() {
      _techniciansFuture = _technicianService.listTechnicians();
      _employeesFuture = _hrService.getLargeDetailEmployees();
      _shiftTemplatesFuture = _technicianService.listShiftTemplates();
      _plannedAssignmentsFuture = _technicianService.listShiftAssignments();
    });
  }

  Future<void> _showCreateShiftTemplateDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _CreateShiftTemplateDialog(technicianService: _technicianService),
    );

    if (created == true && mounted) {
      setState(() {
        _shiftTemplatesFuture = _technicianService.listShiftTemplates();
      });
    }
  }

  Future<void> _showBulkShiftPlanDialog() async {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final technicians = await _techniciansFuture;
      final employeesResponse = await _employeesFuture;
      if (!mounted) return;
      navigator.pop();

      final technicianByUserId = {
        for (final technician in technicians) technician.userId: technician,
      };

      final options = employeesResponse.employees
          .where((employee) => employee.userId.isNotEmpty)
          .map((employee) {
        final technician = technicianByUserId[employee.userId];
        return _ShiftEmployeeOption(
          employeeId: employee.id,
          label: technician?.name.isNotEmpty == true
              ? technician!.name
              : employee.fullName,
          role: employee.positionName ?? 'Teknisyen',
        );
      }).toList()
        ..sort((a, b) => a.label.compareTo(b.label));

      await showDialog<bool>(
        context: context,
        builder: (context) => _BulkShiftPlanningDialog(
          employeeOptions: options,
          technicianService: _technicianService,
        ),
      ).then((created) {
        if (created == true) {
          _refresh();
        }
      });
    } catch (error) {
      if (!mounted) return;
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toplu planlama verileri yüklenemedi: $error')),
      );
    }
  }

  Future<void> _showSingleShiftPlanDialog() async {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final technicians = await _techniciansFuture;
      final employeesResponse = await _employeesFuture;
      final templates = await _shiftTemplatesFuture;
      if (!mounted) return;
      navigator.pop();

      final technicianByUserId = {
        for (final technician in technicians) technician.userId: technician,
      };

      final options = employeesResponse.employees
          .where((employee) => employee.userId.isNotEmpty)
          .map((employee) {
        final technician = technicianByUserId[employee.userId];
        return _ShiftEmployeeOption(
          employeeId: employee.id,
          label: technician?.name.isNotEmpty == true
              ? technician!.name
              : employee.fullName,
          role: employee.positionName ?? 'Teknisyen',
        );
      }).toList()
        ..sort((a, b) => a.label.compareTo(b.label));

      await showDialog<bool>(
        context: context,
        builder: (context) => _SingleShiftPlanningDialog(
          employeeOptions: options,
          templates: templates.where((x) => x.isActive).toList(),
          technicianService: _technicianService,
        ),
      ).then((created) {
        if (created == true) {
          _refresh();
        }
      });
    } catch (error) {
      if (!mounted) return;
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tekil planlama verileri yüklenemedi: $error')),
      );
    }
  }

  void _showAddPersonnelDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final tempPasswordController = TextEditingController();
    final selectedExpertiseIds = <String>{};

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personel Bilgileri',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 14),
                    _DialogField(
                      label: 'Ad',
                      controller: nameController,
                      requiredField: true,
                    ),
                    const SizedBox(height: 10),
                    _DialogField(
                      label: 'Soyad',
                      controller: lastNameController,
                    ),
                    const SizedBox(height: 10),
                    _DialogField(
                      label: 'E-posta',
                      controller: emailController,
                      requiredField: true,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DialogField(
                            label: 'Telefon',
                            controller: phoneController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DialogField(
                            label: 'Geçici Şifre',
                            controller: tempPasswordController,
                            requiredField: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Experts>>(
                      future: _technicianService.listExpertise(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(minHeight: 2),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text('Uzmanlıklar yüklenemedi',
                              style: TextStyle(color: Color(0xFF94A3B8)));
                        }
                        final experts = snapshot.data ?? [];
                        if (experts.isEmpty) {
                          return const Text('Uzmanlık bulunamadı',
                              style: TextStyle(color: Color(0xFF94A3B8)));
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Uzmanlık Alanları',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final e in experts)
                                  FilterChip(
                                    label: Text(e.name),
                                    selected:
                                        selectedExpertiseIds.contains(e.id),
                                    onSelected: (val) {
                                      setDialogState(() {
                                        if (val) {
                                          selectedExpertiseIds.add(e.id);
                                        } else {
                                          selectedExpertiseIds.remove(e.id);
                                        }
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('İptal'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            Navigator.of(ctx).pop();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                  child: CircularProgressIndicator()),
                            );
                            try {
                              await _technicianService.createTechnician(
                                firstName: nameController.text.trim(),
                                lastName: lastNameController.text.trim().isEmpty
                                    ? null
                                    : lastNameController.text.trim(),
                                email: emailController.text.trim(),
                                phoneNumber: phoneController.text.trim().isEmpty
                                    ? null
                                    : phoneController.text.trim(),
                                temporaryPassword:
                                    tempPasswordController.text.trim(),
                                expertiseIds: selectedExpertiseIds.toList(),
                              );

                              if (!context.mounted) return;

                              Navigator.of(context)
                                  .pop(); // loading dialog kapatır

                              _refresh();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Teknisyen oluşturma başlatıldı'),
                                ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;

                              Navigator.of(context)
                                  .pop(); // loading dialog kapatır

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Teknisyen oluşturulamadı'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Kaydet'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddExpertiseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final expertiseController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uzmanlık Alanı Ekle',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 14),
                  _DialogField(
                    label: 'Uzmanlık Adı',
                    controller: expertiseController,
                    requiredField: true,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('İptal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final name = expertiseController.text.trim();
                          Navigator.of(ctx).pop();
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                                child: CircularProgressIndicator()),
                          );
                          try {
                            await _technicianService.createExpertise(name);
                            if (!mounted) return;
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Uzmanlık eklendi')),
                            );
                          } catch (_) {
                            if (!mounted) return;
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('Uzmanlık eklenemedi')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Kaydet'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AdminWebShell(
      active: AdminNavKey.team,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Breadcrumb(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ekip Yönetimi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Ekibinizi yönetin',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (_activeTab == _TeamPageTab.people) ...[
                    _SecondaryActionButton(
                      label: 'Uzmanlık Alanı',
                      icon: Icons.add_circle_outline,
                      onPressed: () => _showAddExpertiseDialog(context),
                    ),
                    const SizedBox(width: 10),
                    _PrimaryActionButton(
                      label: 'Personel Ekle',
                      icon: Icons.add,
                      onPressed: () => _showAddPersonnelDialog(context),
                    ),
                  ]
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SegmentTabs(
            activeTab: _activeTab,
            onChanged: (tab) => setState(() => _activeTab = tab),
          ),
          const SizedBox(height: 16),
          if (_activeTab == _TeamPageTab.people)
            _TeamPeopleSection(
              width: width,
              techniciansFuture: _techniciansFuture,
            )
          else
            _TeamShiftsSection(
              techniciansFuture: _techniciansFuture,
              employeesFuture: _employeesFuture,
              shiftTemplatesFuture: _shiftTemplatesFuture,
              assignmentsFuture: _plannedAssignmentsFuture,
              technicianService: _technicianService,
              onRefresh: _refresh,
              onCreateTemplate: _showCreateShiftTemplateDialog,
              onBulkPlan: _showBulkShiftPlanDialog,
              onSinglePlan: _showSingleShiftPlanDialog,
            ),
        ],
      ),
    );
  }
}

class _TeamPeopleSection extends StatelessWidget {
  const _TeamPeopleSection({
    required this.width,
    required this.techniciansFuture,
  });

  final double width;
  final Future<List<Technician>> techniciansFuture;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<Technician>>(
          future: techniciansFuture,
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            final activeCount = list.where((t) => t.isActive == true).length;
            return _MetricRow(
              width: width,
              total: list.length,
              activeCount: activeCount,
            );
          },
        ),
        const SizedBox(height: 16),
        const _FilterRow(),
        const SizedBox(height: 12),
        _PeopleTableCard(techniciansFuture: techniciansFuture),
      ],
    );
  }
}

class _TeamShiftsSection extends StatelessWidget {
  const _TeamShiftsSection({
    required this.techniciansFuture,
    required this.employeesFuture,
    required this.shiftTemplatesFuture,
    required this.assignmentsFuture,
    required this.technicianService,
    required this.onRefresh,
    required this.onCreateTemplate,
    required this.onBulkPlan,
    required this.onSinglePlan,
  });

  final Future<List<Technician>> techniciansFuture;
  final Future<HREmployeeLargeDetailResponse> employeesFuture;
  final Future<List<ShiftTemplateModel>> shiftTemplatesFuture;
  final Future<List<ShiftAssignmentModel>> assignmentsFuture;
  final TechnicianService technicianService;
  final VoidCallback onRefresh;
  final VoidCallback onCreateTemplate;
  final VoidCallback onBulkPlan;
  final VoidCallback onSinglePlan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ShiftManagementOverview(
          shiftTemplatesFuture: shiftTemplatesFuture,
          assignmentsFuture: assignmentsFuture,
          onCreateTemplate: onCreateTemplate,
          onBulkPlan: onBulkPlan,
          onSinglePlan: onSinglePlan,
        ),
        const SizedBox(height: 16),
        _PlannedShiftsTableCard(
          techniciansFuture: techniciansFuture,
          employeesFuture: employeesFuture,
          shiftTemplatesFuture: shiftTemplatesFuture,
          assignmentsFuture: assignmentsFuture,
          technicianService: technicianService,
          onRefresh: onRefresh,
        ),
      ],
    );
  }
}

class _ShiftManagementOverview extends StatelessWidget {
  const _ShiftManagementOverview({
    required this.shiftTemplatesFuture,
    required this.assignmentsFuture,
    required this.onCreateTemplate,
    required this.onBulkPlan,
    required this.onSinglePlan,
  });

  final Future<List<ShiftTemplateModel>> shiftTemplatesFuture;
  final Future<List<ShiftAssignmentModel>> assignmentsFuture;
  final VoidCallback onCreateTemplate;
  final VoidCallback onBulkPlan;
  final VoidCallback onSinglePlan;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ShiftTemplateModel>>(
      future: shiftTemplatesFuture,
      builder: (context, templateSnapshot) {
        return FutureBuilder<List<ShiftAssignmentModel>>(
          future: assignmentsFuture,
          builder: (context, assignmentSnapshot) {
            final templates =
                templateSnapshot.data ?? const <ShiftTemplateModel>[];
            final assignments =
                assignmentSnapshot.data ?? const <ShiftAssignmentModel>[];
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vardiya / Mesai Yönetimi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Şablon oluşturun, personel için tekil vardiya/mesai atayın ve bugünkü durumu takip edin.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _SecondaryActionButton(
                            label: 'Tekil Planla',
                            icon: Icons.event_repeat_outlined,
                            onPressed: onSinglePlan,
                          ),
                          const SizedBox(width: 10),
                          _SecondaryActionButton(
                            label: 'Toplu Planla',
                            icon: Icons.calendar_view_week_outlined,
                            onPressed: onBulkPlan,
                          ),
                          const SizedBox(width: 10),
                          _PrimaryActionButton(
                            label: 'Şablon Oluştur',
                            icon: Icons.schedule_outlined,
                            onPressed: onCreateTemplate,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ShiftMetricCard(
                        title: 'Aktif Şablonlar',
                        value: templates
                            .where((x) => x.isActive)
                            .length
                            .toString(),
                        icon: Icons.copy_all_outlined,
                        color: const Color(0xFF3B82F6),
                      ),
                      _ShiftMetricCard(
                        title: 'Bugün Planlanan',
                        value: assignments.length.toString(),
                        icon: Icons.event_available_outlined,
                        color: const Color(0xFF16A34A),
                      ),
                    ],
                  ),
                  if (templates.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: templates.take(5).map((template) {
                        return _ShiftTemplatePill(template: template);
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('Yönetim',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Ekip Yönetimi',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({
    required this.activeTab,
    required this.onChanged,
  });

  final _TeamPageTab activeTab;
  final ValueChanged<_TeamPageTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SegmentTab(
          label: 'Personeller',
          active: activeTab == _TeamPageTab.people,
          onTap: () => onChanged(_TeamPageTab.people),
        ),
        _SegmentTab(
          label: 'Vardiyalar',
          active: activeTab == _TeamPageTab.shifts,
          onTap: () => onChanged(_TeamPageTab.shifts),
        ),
      ],
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF3B82F6) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    active ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow(
      {required this.width, required this.total, required this.activeCount});

  final double width;
  final int total;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = width >= 1300
        ? 5
        : width >= 1000
            ? 3
            : 2;
    final childAspectRatio = width >= 1300
        ? 2.6
        : width >= 1000
            ? 2.1
            : 1.8;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      padding: EdgeInsets.zero,
      children: [
        _MetricCard(
            title: 'Toplam Personel',
            value: total.toString(),
            icon: Icons.group_outlined,
            color: const Color(0xFF3B82F6)),
        _MetricCard(
            title: 'Aktif Personel',
            value: activeCount.toString(),
            icon: Icons.person_outline,
            color: const Color(0xFF22C55E)),
        _MetricCard(
            title: 'Teknisyenler',
            value: total.toString(),
            icon: Icons.build_outlined,
            color: const Color(0xFF2563EB)),
        _MetricCard(
            title: 'Müsait',
            value: (total - activeCount).toString(),
            icon: Icons.check_circle_outline,
            color: const Color(0xFF22C55E)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                SizedBox(width: 8),
                Text('Ara', style: TextStyle(color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _DropdownPill(label: 'Tümü'),
        const SizedBox(width: 12),
        const _DropdownPill(label: 'Tümü'),
      ],
    );
  }
}

class _DropdownPill extends StatelessWidget {
  const _DropdownPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF475569), fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          const Icon(Icons.expand_more, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _PeopleTableCard extends StatelessWidget {
  const _PeopleTableCard({required this.techniciansFuture});

  final Future<List<Technician>> techniciansFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Technician>>(
      future: techniciansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Personeller yüklenemedi'),
            ),
          );
        }

        final technicians = snapshot.data ?? [];
        if (technicians.isEmpty) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Personel bulunamadı',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
          );
        }

        return _TableCard(
          child: Column(
            children: [
              const _PeopleTableHeader(),
              for (final technician in technicians)
                _PeopleTableRow(technician: technician),
            ],
          ),
        );
      },
    );
  }
}

class _PeopleTableHeader extends StatelessWidget {
  const _PeopleTableHeader();

  @override
  Widget build(BuildContext context) {
    const headers = [
      'Personel',
      'Pozisyon',
      'Uzmanlıklar',
      'İletişim',
      'Durum',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: headers
            .map(
              (header) => Expanded(
                child: Text(
                  header,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PeopleTableRow extends StatelessWidget {
  const _PeopleTableRow({required this.technician});

  final Technician technician;

  String? _fullPictureUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final base = ApiClient().dio.options.baseUrl;
    if (raw.startsWith('/')) return '$base$raw';
    return '$base/$raw';
  }

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = _fullPictureUrl(technician.pictureUrl);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        adminNavRoute(
          AdminWebTechnicianDetailPage(technicianId: technician.userId),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE2E8F0),
                    child: fullImageUrl == null
                        ? const Icon(
                            Icons.person_outline_rounded,
                            size: 22,
                            color: Color(0xFF64748B),
                          )
                        : ClipOval(
                            child: Image.network(
                              fullImageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_outline_rounded,
                                size: 22,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      technician.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: Text('Teknisyen')),
            Expanded(
              child: Text(
                (technician.specializations ?? []).isEmpty
                    ? '-'
                    : (technician.specializations ?? []).join(', '),
              ),
            ),
            Expanded(child: Text(technician.email)),
            Expanded(
              child: _StatusBadge(
                label: technician.isActive == true ? 'Aktif' : 'Pasif',
                color: technician.isActive == true
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannedShiftsTableCard extends StatelessWidget {
  const _PlannedShiftsTableCard({
    required this.techniciansFuture,
    required this.employeesFuture,
    required this.shiftTemplatesFuture,
    required this.assignmentsFuture,
    required this.technicianService,
    required this.onRefresh,
  });

  final Future<List<Technician>> techniciansFuture;
  final Future<HREmployeeLargeDetailResponse> employeesFuture;
  final Future<List<ShiftTemplateModel>> shiftTemplatesFuture;
  final Future<List<ShiftAssignmentModel>> assignmentsFuture;
  final TechnicianService technicianService;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Technician>>(
      future: techniciansFuture,
      builder: (context, technicianSnapshot) {
        return FutureBuilder<HREmployeeLargeDetailResponse>(
          future: employeesFuture,
          builder: (context, employeeSnapshot) {
            return FutureBuilder<List<ShiftTemplateModel>>(
              future: shiftTemplatesFuture,
              builder: (context, templateSnapshot) {
                return FutureBuilder<List<ShiftAssignmentModel>>(
                  future: assignmentsFuture,
                  builder: (context, assignmentSnapshot) {
                    if (technicianSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        employeeSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        templateSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        assignmentSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const _TableCard(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    final technicians = technicianSnapshot.data ?? [];
                    final employees = employeeSnapshot.data?.employees ?? [];
                    final templates = templateSnapshot.data ?? [];
                    final assignments = assignmentSnapshot.data ?? [];

                    final employeeById = {
                      for (final employee in employees) employee.id: employee,
                    };
                    final technicianByUserId = {
                      for (final technician in technicians)
                        technician.userId: technician,
                    };
                    final templateById = {
                      for (final template in templates) template.id: template,
                    };

                    if (assignments.isEmpty) {
                      return const _TableCard(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Planlanmış vardiya bulunamadı',
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      );
                    }

                    return _TableCard(
                      child: Column(
                        children: [
                          const _PlannedShiftsHeader(),
                          for (final assignment in assignments)
                            _PlannedShiftRow(
                              assignment: assignment,
                              employee: employeeById[assignment.employeeId],
                              technician:
                                  employeeById[assignment.employeeId] == null
                                      ? null
                                      : technicianByUserId[
                                          employeeById[assignment.employeeId]!
                                              .userId],
                              template:
                                  templateById[assignment.shiftTemplateId],
                              templates: templates,
                              technicianService: technicianService,
                              onRefresh: onRefresh,
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PlannedShiftsHeader extends StatelessWidget {
  const _PlannedShiftsHeader();

  @override
  Widget build(BuildContext context) {
    const headers = [
      'Personel',
      'Rol / Pozisyon',
      'Vardiya',
      'Başlangıç',
      'Bitiş',
      'Durum',
      'Aksiyon',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: headers
            .map(
              (header) => Expanded(
                child: Text(
                  header,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PlannedShiftRow extends StatelessWidget {
  const _PlannedShiftRow({
    required this.assignment,
    required this.employee,
    required this.technician,
    required this.template,
    required this.templates,
    required this.technicianService,
    required this.onRefresh,
  });

  final ShiftAssignmentModel assignment;
  final EmployeeResponse? employee;
  final Technician? technician;
  final ShiftTemplateModel? template;
  final List<ShiftTemplateModel> templates;
  final TechnicianService technicianService;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final personName =
        employee?.fullName ?? technician?.name ?? 'Personel bulunamadı';
    final roleName = employee?.positionName ?? 'Teknisyen';
    final isCheckedIn = _isCheckedInStatus(assignment.status);
    final statusColor = _resolveShiftStatusColor(assignment.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              personName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(roleName)),
          Expanded(
            child: Text(
              template?.name ?? 'Şablon yok',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
              child: Text(
                  _formatDateTime(assignment.plannedStartTimeUtc.toLocal()))),
          Expanded(
              child: Text(
                  _formatDateTime(assignment.plannedEndTimeUtc.toLocal()))),
          Expanded(
            child: Row(
              children: [
                if (isCheckedIn) ...[
                  _PulseStatusLed(color: statusColor),
                  const SizedBox(width: 10),
                ],
                _StatusBadge(
                  label: _formatShiftStatus(assignment.status),
                  color: statusColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: employee == null
                    ? null
                    : () {
                        showDialog<bool>(
                          context: context,
                          builder: (context) => _AssignShiftDialog(
                            technicianName: personName,
                            employeeId: employee!.id,
                            templates: templates,
                            technicianService: technicianService,
                          ),
                        ).then((created) {
                          if (created == true) {
                            onRefresh();
                          }
                        });
                      },
                icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                label: const Text('Tekil Ata'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
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
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PulseStatusLed extends StatefulWidget {
  const _PulseStatusLed({required this.color});

  final Color color;

  @override
  State<_PulseStatusLed> createState() => _PulseStatusLedState();
}

class _PulseStatusLedState extends State<_PulseStatusLed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1, end: 1.55).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _pulseOpacityAnimation = Tween<double>(begin: 0.80, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 18,
          height: 18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(
                      alpha: _pulseOpacityAnimation.value,
                    ),
                  ),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.30),
                      blurRadius: 10,
                      spreadRadius: 1.2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatShiftStatus(String rawStatus) {
  final value = rawStatus.toLowerCase();
  if (value.contains('planned')) return 'Planlandı';
  if (value.contains('checkedin')) return 'Başladı';
  if (value.contains('completed')) return 'Tamamlandı';
  if (value.contains('cancel')) return 'İptal';
  if (value.contains('checkedout')) return 'Tamamlandı';
  return rawStatus;
}

bool _isCheckedInStatus(String rawStatus) {
  return rawStatus.toLowerCase().contains('checkedin');
}

Color _resolveShiftStatusColor(String rawStatus) {
  final value = rawStatus.toLowerCase();
  if (value.contains('planned')) return const Color(0xFF2563EB);
  if (value.contains('checkedin')) return const Color(0xFF16A34A);
  if (value.contains('completed')) return const Color(0xFF64748B);
  if (value.contains('cancel')) return const Color(0xFFDC2626);
  return const Color(0xFF64748B);
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ShiftMetricCard extends StatelessWidget {
  const _ShiftMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShiftTemplatePill extends StatelessWidget {
  const _ShiftTemplatePill({required this.template});

  final ShiftTemplateModel template;

  @override
  Widget build(BuildContext context) {
    final start = _formatDuration(template.startTime);
    final end = _formatDuration(template.endTime);
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
            template.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$start - $end',
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

class _CreateShiftTemplateDialog extends StatefulWidget {
  const _CreateShiftTemplateDialog({required this.technicianService});

  final TechnicianService technicianService;

  @override
  State<_CreateShiftTemplateDialog> createState() =>
      _CreateShiftTemplateDialogState();
}

class _CreateShiftTemplateDialogState
    extends State<_CreateShiftTemplateDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isActive = true;
  bool _isNightShift = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;

    final start = Duration(hours: _startTime.hour, minutes: _startTime.minute);
    final end = Duration(hours: _endTime.hour, minutes: _endTime.minute);
    final isInvalidStandardShift = !_isNightShift && start >= end;
    final isInvalidNightShift = _isNightShift && start == end;
    if (isInvalidStandardShift || isInvalidNightShift) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isNightShift
                ? 'Gece vardiyasında başlangıç ve bitiş aynı olamaz.'
                : 'Başlangıç saati bitişten önce olmalı.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.technicianService.createShiftTemplate(
        CreateShiftTemplatePayload(
          branchId: '00000000-0000-0000-0000-000000000000',
          name: _nameController.text.trim(),
          startTime: start,
          endTime: end,
          isNightShift: _isNightShift,
          isActive: _isActive,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template oluşturulamadı: $error')),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 620,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vardiya Template Oluştur',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _DialogField(
                label: 'Template Adı',
                controller: _nameController,
                requiredField: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Başlangıç',
                    value: _formatTimeOfDay24(_startTime),
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    label: 'Bitiş',
                    value: _formatTimeOfDay24(_endTime),
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    value: _isActive,
                    title: const Text('Aktif'),
                    onChanged: _isSubmitting
                        ? null
                        : (v) => setState(() => _isActive = v),
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    value: _isNightShift,
                    title: const Text('Gece Vardiyası'),
                    onChanged: _isSubmitting
                        ? null
                        : (v) => setState(() => _isNightShift = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Kaydet'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _AssignShiftDialog extends StatefulWidget {
  const _AssignShiftDialog({
    required this.technicianName,
    required this.employeeId,
    required this.templates,
    required this.technicianService,
  });

  final String technicianName;
  final String employeeId;
  final List<ShiftTemplateModel> templates;
  final TechnicianService technicianService;

  @override
  State<_AssignShiftDialog> createState() => _AssignShiftDialogState();
}

class _AssignShiftDialogState extends State<_AssignShiftDialog> {
  ShiftTemplateModel? _selectedTemplate;
  late DateTime _plannedStart;
  late DateTime _plannedEnd;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _plannedStart = DateTime(now.year, now.month, now.day, 9, 0);
    _plannedEnd = DateTime(now.year, now.month, now.day, 18, 0);
  }

  void _applyTemplateTimes(ShiftTemplateModel template) {
    final start = DateTime(
      _plannedStart.year,
      _plannedStart.month,
      _plannedStart.day,
      template.startTime.inHours,
      template.startTime.inMinutes % 60,
    );

    var end = DateTime(
      _plannedStart.year,
      _plannedStart.month,
      _plannedStart.day,
      template.endTime.inHours,
      template.endTime.inMinutes % 60,
    );

    if (template.isNightShift || !end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }

    _plannedStart = start;
    _plannedEnd = end;
  }

  Future<void> _pickDateTime(bool isStart) async {
    final current = isStart ? _plannedStart : _plannedEnd;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _plannedStart = selectedDateTime;
        if (!_plannedEnd.isAfter(_plannedStart)) {
          _plannedEnd = _plannedStart.add(const Duration(hours: 8));
        }
      } else {
        _plannedEnd = selectedDateTime;
      }
    });
  }

  Future<void> _submit() async {
    final template = _selectedTemplate;
    if (template == null) return;

    if (!_plannedEnd.isAfter(_plannedStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitiş tarihi/saatı başlangıçtan sonra olmalı.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.technicianService.createShiftAssignment(
        CreateShiftAssignmentPayload(
          branchId: '00000000-0000-0000-0000-000000000000',
          employeeId: widget.employeeId,
          shiftTemplateId: template.id,
          shiftDate: DateTime(
            _plannedStart.year,
            _plannedStart.month,
            _plannedStart.day,
          ),
          plannedStartTimeUtc: _plannedStart.toUtc(),
          plannedEndTimeUtc: _plannedEnd.toUtc(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (error is ShiftConflictException) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Bu personel için seçilen tarihte zaten bir vardiya atanmış.')),
        );
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vardiya atanamadı: $error')),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 620,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.technicianName} için Vardiya Ata',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedTemplate?.id,
              decoration: const InputDecoration(labelText: 'Şablon'),
              items: widget.templates
                  .where((t) => t.isActive)
                  .map((template) => DropdownMenuItem<String>(
                        value: template.id,
                        child: Text(
                            '${template.name} • ${_formatDuration(template.startTime)} - ${_formatDuration(template.endTime)}'),
                      ))
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _selectedTemplate = widget.templates.firstWhere(
                          (t) => t.id == value,
                        );
                        _applyTemplateTimes(_selectedTemplate!);
                      });
                    },
            ),
            const SizedBox(height: 12),
            _TimeField(
              label: 'Başlangıç Tarih / Saat',
              value: _formatDateTime(_plannedStart),
              onTap: () => _pickDateTime(true),
            ),
            const SizedBox(height: 12),
            _TimeField(
              label: 'Bitiş Tarih / Saat',
              value: _formatDateTime(_plannedEnd),
              onTap: () => _pickDateTime(false),
            ),
            if (_selectedTemplate != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Şablon saat aralığı: ${_formatDuration(_selectedTemplate!.startTime)} - ${_formatDuration(_selectedTemplate!.endTime)}',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
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
                  onPressed: _isSubmitting || _selectedTemplate == null
                      ? null
                      : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Vardiya Ata'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkShiftPlanningDialog extends StatefulWidget {
  const _BulkShiftPlanningDialog({
    required this.employeeOptions,
    required this.technicianService,
  });

  final List<_ShiftEmployeeOption> employeeOptions;
  final TechnicianService technicianService;

  @override
  State<_BulkShiftPlanningDialog> createState() =>
      _BulkShiftPlanningDialogState();
}

class _BulkShiftPlanningDialogState extends State<_BulkShiftPlanningDialog> {
  String? _selectedEmployeeId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 6));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isSubmitting = false;
  final Map<int, bool> _selectedWeekdays = {
    DateTime.monday: true,
    DateTime.tuesday: true,
    DateTime.wednesday: true,
    DateTime.thursday: true,
    DateTime.friday: true,
    DateTime.saturday: false,
    DateTime.sunday: false,
  };

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  List<BlockShiftTimePayload> _buildPlannedTimes() {
    final results = <BlockShiftTimePayload>[];
    var cursor = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final last = DateTime(_endDate.year, _endDate.month, _endDate.day);

    while (!cursor.isAfter(last)) {
      if (_selectedWeekdays[cursor.weekday] == true) {
        final start = DateTime(
          cursor.year,
          cursor.month,
          cursor.day,
          _startTime.hour,
          _startTime.minute,
        );

        var end = DateTime(
          cursor.year,
          cursor.month,
          cursor.day,
          _endTime.hour,
          _endTime.minute,
        );

        if (!end.isAfter(start)) {
          end = end.add(const Duration(days: 1));
        }

        results.add(
          BlockShiftTimePayload(
            startTimeUtc: start.toUtc(),
            endTimeUtc: end.toUtc(),
          ),
        );
      }

      cursor = cursor.add(const Duration(days: 1));
    }

    return results;
  }

  Future<void> _submit() async {
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personel seçimi zorunlu.')),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitiş tarihi başlangıçtan önce olamaz.')),
      );
      return;
    }

    final plannedTimes = _buildPlannedTimes();
    if (plannedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir planlama günü seçmelisiniz.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response =
          await widget.technicianService.createBlockShiftAssignments(
        CreateBlockShiftAssignmentPayload(
          branchId: '00000000-0000-0000-0000-000000000000',
          employeeId: _selectedEmployeeId!,
          plannedTimesUtc: plannedTimes,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.length} vardiya planlandı.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toplu planlama başarısız: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewCount = _buildPlannedTimes().length;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 720,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Toplu Vardiya/Mesai Planla',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tek personel için tarih aralığında çoklu vardiya/mesai oluşturur.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedEmployeeId,
              decoration: const InputDecoration(labelText: 'Personel'),
              items: widget.employeeOptions
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.employeeId,
                      child: Text('${option.label} • ${option.role}'),
                    ),
                  )
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedEmployeeId = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Başlangıç Tarihi',
                    value: _formatDateOnly(_startDate),
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    label: 'Bitiş Tarihi',
                    value: _formatDateOnly(_endDate),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Başlangıç Saati',
                    value: _formatTimeOfDay24(_startTime),
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    label: 'Bitiş Saati',
                    value: _formatTimeOfDay24(_endTime),
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Uygulanacak Günler',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _WeekdayChip(
                  label: 'Pzt',
                  selected: _selectedWeekdays[DateTime.monday] ?? false,
                  onTap: () => setState(() =>
                      _selectedWeekdays[DateTime.monday] =
                          !(_selectedWeekdays[DateTime.monday] ?? false)),
                ),
                _WeekdayChip(
                  label: 'Sal',
                  selected: _selectedWeekdays[DateTime.tuesday] ?? false,
                  onTap: () => setState(() =>
                      _selectedWeekdays[DateTime.tuesday] =
                          !(_selectedWeekdays[DateTime.tuesday] ?? false)),
                ),
                _WeekdayChip(
                  label: 'Çar',
                  selected: _selectedWeekdays[DateTime.wednesday] ?? false,
                  onTap: () => setState(() =>
                      _selectedWeekdays[DateTime.wednesday] =
                          !(_selectedWeekdays[DateTime.wednesday] ?? false)),
                ),
                _WeekdayChip(
                  label: 'Per',
                  selected: _selectedWeekdays[DateTime.thursday] ?? false,
                  onTap: () => setState(() =>
                      _selectedWeekdays[DateTime.thursday] =
                          !(_selectedWeekdays[DateTime.thursday] ?? false)),
                ),
                _WeekdayChip(
                  label: 'Cum',
                  selected: _selectedWeekdays[DateTime.friday] ?? false,
                  onTap: () => setState(() =>
                      _selectedWeekdays[DateTime.friday] =
                          !(_selectedWeekdays[DateTime.friday] ?? false)),
                ),
                _WeekdayChip(
                  label: 'Cmt',
                  selected: _selectedWeekdays[DateTime.saturday] ?? false,
                  onTap: () => setState(() =>
                      _selectedWeekdays[DateTime.saturday] =
                          !(_selectedWeekdays[DateTime.saturday] ?? false)),
                ),
                _WeekdayChip(
                  label: 'Paz',
                  selected: _selectedWeekdays[DateTime.sunday] ?? false,
                  onTap: () => setState(() =>
                      _selectedWeekdays[DateTime.sunday] =
                          !(_selectedWeekdays[DateTime.sunday] ?? false)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'Oluşacak vardiya sayısı: $previewCount',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isSubmitting ? null : () => Navigator.of(context).pop(),
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
                      : const Text('Toplu Planla'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleShiftPlanningDialog extends StatefulWidget {
  const _SingleShiftPlanningDialog({
    required this.employeeOptions,
    required this.templates,
    required this.technicianService,
  });

  final List<_ShiftEmployeeOption> employeeOptions;
  final List<ShiftTemplateModel> templates;
  final TechnicianService technicianService;

  @override
  State<_SingleShiftPlanningDialog> createState() =>
      _SingleShiftPlanningDialogState();
}

class _SingleShiftPlanningDialogState
    extends State<_SingleShiftPlanningDialog> {
  String? _selectedEmployeeId;
  ShiftTemplateModel? _selectedTemplate;
  late DateTime _plannedStart;
  late DateTime _plannedEnd;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _plannedStart = DateTime(now.year, now.month, now.day, 9, 0);
    _plannedEnd = DateTime(now.year, now.month, now.day, 18, 0);
  }

  void _applyTemplate(ShiftTemplateModel template) {
    final start = DateTime(
      _plannedStart.year,
      _plannedStart.month,
      _plannedStart.day,
      template.startTime.inHours,
      template.startTime.inMinutes % 60,
    );

    var end = DateTime(
      _plannedStart.year,
      _plannedStart.month,
      _plannedStart.day,
      template.endTime.inHours,
      template.endTime.inMinutes % 60,
    );

    if (template.isNightShift || !end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }

    _plannedStart = start;
    _plannedEnd = end;
  }

  Future<void> _pickDateTime(bool isStart) async {
    final current = isStart ? _plannedStart : _plannedEnd;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

    final selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _plannedStart = selected;
        if (!_plannedEnd.isAfter(_plannedStart)) {
          _plannedEnd = _plannedStart.add(const Duration(hours: 8));
        }
      } else {
        _plannedEnd = selected;
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personel seçimi zorunlu.')),
      );
      return;
    }

    if (_selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template seçimi zorunlu.')),
      );
      return;
    }

    if (!_plannedEnd.isAfter(_plannedStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bitiş tarihi/saatı başlangıçtan sonra olmalı.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.technicianService.createShiftAssignment(
        CreateShiftAssignmentPayload(
          branchId: '00000000-0000-0000-0000-000000000000',
          employeeId: _selectedEmployeeId!,
          shiftTemplateId: _selectedTemplate!.id,
          shiftDate: DateTime(
            _plannedStart.year,
            _plannedStart.month,
            _plannedStart.day,
          ),
          plannedStartTimeUtc: _plannedStart.toUtc(),
          plannedEndTimeUtc: _plannedEnd.toUtc(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tekil vardiya/mesai planlandı.')),
      );
    } catch (error) {
      if (error is ShiftConflictException) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bu personel için seçilen tarihte zaten bir vardiya/mesai atanmış.',
            ),
          ),
        );
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tekil planlama başarısız: $error')),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 720,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tekil Vardiya Planla',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tek personel için tek bir vardiya/mesai oluşturur.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedEmployeeId,
              decoration: const InputDecoration(labelText: 'Personel'),
              items: widget.employeeOptions
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.employeeId,
                      child: Text('${option.label} • ${option.role}'),
                    ),
                  )
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedEmployeeId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedTemplate?.id,
              decoration: const InputDecoration(labelText: 'Şablon'),
              items: widget.templates
                  .map(
                    (template) => DropdownMenuItem<String>(
                      value: template.id,
                      child: Text(
                        '${template.name} • ${_formatDuration(template.startTime)} - ${_formatDuration(template.endTime)}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _selectedTemplate = widget.templates.firstWhere(
                          (template) => template.id == value,
                        );
                        _applyTemplate(_selectedTemplate!);
                      });
                    },
            ),
            const SizedBox(height: 12),
            _TimeField(
              label: 'Başlangıç Tarih / Saat',
              value: _formatDateTime(_plannedStart),
              onTap: () => _pickDateTime(true),
            ),
            const SizedBox(height: 12),
            _TimeField(
              label: 'Bitiş Tarih / Saat',
              value: _formatDateTime(_plannedEnd),
              onTap: () => _pickDateTime(false),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isSubmitting ? null : () => Navigator.of(context).pop(),
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
                      : const Text('Tekil Planla'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
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
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
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
        child: Text(value),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final h = duration.inHours.toString().padLeft(2, '0');
  final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

String _formatTimeOfDay24(TimeOfDay value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day.$month.$year $hour:$minute';
}

String _formatDateOnly(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day.$month.$year';
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.controller,
    this.requiredField = false,
  });

  final String label;
  final TextEditingController controller;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: requiredField
          ? (val) => (val == null || val.trim().isEmpty) ? 'Zorunlu' : null
          : null,
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

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton(
      {required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton(
      {required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0F172A),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
      ),
    );
  }
}
