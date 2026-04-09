import 'package:flutter/material.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';

class AdminWebTeamPage extends StatefulWidget {
  const AdminWebTeamPage({super.key});

  @override
  State<AdminWebTeamPage> createState() => _AdminWebTeamPageState();
}

class _AdminWebTeamPageState extends State<AdminWebTeamPage> {
  final TechnicianService _technicianService = TechnicianService();
  late Future<List<Technician>> _techniciansFuture;

  @override
  void initState() {
    super.initState();
    _techniciansFuture = _technicianService.listTechnicians();
  }

  void _refresh() {
    setState(() {
      _techniciansFuture = _technicianService.listTechnicians();
    });
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
                                expertiseIds: selectedExpertiseIds.isEmpty
                                    ? null
                                    : selectedExpertiseIds.toList(),
                              );
                              if (mounted) Navigator.of(context).pop();
                              if (mounted) {
                                _refresh();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Teknisyen oluşturma başlatıldı')),
                                );
                              }
                            } catch (_) {
                              if (mounted) Navigator.of(context).pop();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Teknisyen oluşturulamadı')),
                                );
                              }
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
                        onPressed: () {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final name = expertiseController.text.trim();
                          Navigator.of(ctx).pop();
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                                child: CircularProgressIndicator()),
                          );
                          _technicianService.createExpertise(name).then((_) {
                            if (mounted) Navigator.of(context).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Uzmanlık eklendi')),
                              );
                            }
                          }).catchError((_) {
                            if (mounted) Navigator.of(context).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Uzmanlık eklenemedi')),
                              );
                            }
                          });
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Personel Yönetimi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Personelleri yönetin',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
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
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SegmentTabs(),
          const SizedBox(height: 16),
          FutureBuilder<List<Technician>>(
            future: _techniciansFuture,
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
          _TeamTableCard(techniciansFuture: _techniciansFuture),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text('Yönetim',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Personel Yönetimi',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _SegmentTab(label: 'Tümü', active: true),
        _SegmentTab(label: 'Teknisyenler'),
        _SegmentTab(label: 'Yönetim'),
        _SegmentTab(label: 'Stajyer'),
      ],
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
            child: Row(
              children: const [
                Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                SizedBox(width: 8),
                Text('Ara', style: TextStyle(color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _DropdownPill(label: 'Tümü'),
        const SizedBox(width: 12),
        _DropdownPill(label: 'Tümü'),
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

class _TeamTableCard extends StatelessWidget {
  const _TeamTableCard({required this.techniciansFuture});

  final Future<List<Technician>> techniciansFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Technician>>(
      future: techniciansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Ekip yüklenemedi'),
            ),
          );
        }
        final technicians = snapshot.data ?? [];
        if (technicians.isEmpty) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Veri bulunamadı',
                  style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          );
        }
        return _TableCard(
          child: Column(
            children: [
              const _TableHeader(),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              for (final t in technicians)
                _TableRow(
                  name: t.name,
                  department: 'Teknik',
                  role: 'Teknisyen',
                  specializations: (t.specializations ?? []).join(', '),
                  contact: t.email,
                  status: t.isActive == null
                      ? 'Bilinmiyor'
                      : (t.isActive! ? 'Aktif' : 'Pasif'),
                  tasks: '0',
                ),
            ],
          ),
        );
      },
    );
  }
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

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final headers = [
      'Personel',
      'Departman',
      'Pozisyon',
      'Uzmanlıklar',
      'İletişim',
      'Durum',
      'Atanmış İşler',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: headers
            .map(
              (h) => Expanded(
                child: Text(
                  h,
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

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.name,
    required this.department,
    required this.role,
    required this.specializations,
    required this.contact,
    required this.status,
    required this.tasks,
  });

  final String name;
  final String department;
  final String role;
  final String specializations;
  final String contact;
  final String status;
  final String tasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(department)),
          Expanded(child: Text(role)),
          Expanded(
              child: Text(specializations.isEmpty ? '-' : specializations)),
          Expanded(child: Text(contact)),
          Expanded(child: Text(status)),
          Expanded(child: Text(tasks)),
        ],
      ),
    );
  }
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
