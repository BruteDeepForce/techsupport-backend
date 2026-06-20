import 'package:flutter/material.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/data/hr_services.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/hr_pages/admin_web_hr_options_section.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/model/hr_models.dart';

import 'admin_web_hr_employee_detail_page.dart';
import 'admin_web_hr_bordro_section_page.dart';
import 'admin_web_hr_discipline_reward_section_page.dart';
import 'admin_web_hr_leave_section_page.dart';
import 'admin_web_hr_leaves_page.dart';
import '../../shared/admin_web_nav.dart';
import '../../shared/admin_web_shell.dart';
import '../../shared/admin_web_topbar.dart';

class AdminWebHrPage extends StatefulWidget {
  const AdminWebHrPage({super.key});

  @override
  State<AdminWebHrPage> createState() => _AdminWebHrPageState();
}

class _AdminWebHrPageState extends State<AdminWebHrPage> {
  HrSection _activeSection = HrSection.dashboard;
  final HRService _hrService = HRService();
  late Future<HREmployeeLargeDetailResponse> _employeesDetailLargeFuture;

  @override
  void initState() {
    super.initState();
    _employeesDetailLargeFuture = _hrService.getLargeDetailEmployees();
  }

  void _openEmployeeDetail([String? employeeId, String employeeName = 'Batuhan Kaya']) {
    Navigator.of(context).push(
      adminNavRoute(AdminWebHrEmployeeDetailPage(
        employeeId: employeeId,
        employeeName: employeeName,
      )),
    );
  }

  void _openLeavesPage() {
    Navigator.of(context).push(adminNavRoute(const AdminWebHrLeavesPage()));
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_activeSection) {
      case HrSection.dashboard:
        content = _HrDashboardSection(
          employeesDetailLargeFuture: _employeesDetailLargeFuture,
          onOpenEmployee: _openEmployeeDetail,
          onOpenLeaves: _openLeavesPage,
        );
        break;
      case HrSection.personnel:
        content = _PersonnelSection(
          onOpenEmployee: _openEmployeeDetail,
          employeesDetailLargeFuture: _employeesDetailLargeFuture,
        );
        break;
      case HrSection.leaves:
        //! izin yönetimi ekranı buraya taşındı
        content = AdminWebHrLeaveSectionPage(onOpenLeaves: _openLeavesPage);
        break;
      case HrSection.bordro:
        content = const AdminWebHrBordroSectionPage();
        break;
      case HrSection.advances:
        content = const _PlaceholderSection(
          title: 'Avanslar',
          description:
              'Bu alan avans taleplerinin listelenmesi ve yönetimi için ayrıldı.',
        );
        break;
      case HrSection.discipline:
        content = const AdminWebHrDisciplineRewardSectionPage();
        break;
      case HrSection.performance:
        content = const _PlaceholderSection(
          title: 'Performans Değerlendirmeleri',
          description:
              'Bu alan performans değerlendirmeleri ve raporları için ayrıldı.',
        );
        break;
      case HrSection.ayarlar:
        content = const AdminWebHROptionsSection();
        break;
    }

    return AdminWebShell(
      active: AdminNavKey.hr,
      actions: [
        AdminWebActionButton(
          label: 'Personel Ekle / İşe Alım',
          icon: Icons.person_add_alt_1_outlined,
          onPressed: () {},
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 16),
          _TabStrip(
              active: _activeSection,
              onChanged: (value) => setState(() => _activeSection = value)),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}

enum HrSection {
  dashboard('Dashboard'),
  personnel('Personeller'),
  leaves('İzin Yönetimi'),
  bordro('Bordro'),
  advances('Avanslar'),
  discipline('Disiplin & Ödül'),
  performance('Performans'),
  ayarlar('Ayarlar');

  const HrSection(this.label);
  final String label;
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İnsan Kaynakları',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 6),
        Text(
          'Personel, izin ve özlük süreçlerini bu modülden yönetin.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip({
    required this.active,
    required this.onChanged,
  });

  final HrSection active;
  final ValueChanged<HrSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF8FBFF),
            Color(0xFFF1F5F9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRow = constraints.maxWidth >= 980;

          if (useRow) {
            return Row(
              children: [
                for (final section in HrSection.values) ...[
                  Expanded(
                    child: _TabItem(
                      section: section,
                      active: active == section,
                      onTap: () => onChanged(section),
                    ),
                  ),
                  if (section != HrSection.values.last)
                    const SizedBox(width: 8),
                ],
              ],
            );
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final section in HrSection.values)
                _TabItem(
                  section: section,
                  active: active == section,
                  onTap: () => onChanged(section),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.section,
    required this.active,
    required this.onTap,
  });

  final HrSection section;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: active
              ? Border.all(color: const Color(0xFFE2E8F0))
              : Border.all(color: Colors.transparent),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x0F2563EB),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Text(
          section.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            fontSize: 15,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

class _HrDashboardSection extends StatelessWidget {
  const _HrDashboardSection({
    required this.onOpenEmployee,
    required this.onOpenLeaves,
    required this.employeesDetailLargeFuture,
  });

  final void Function(String?, String) onOpenEmployee;
  final Future<HREmployeeLargeDetailResponse> employeesDetailLargeFuture;
  final VoidCallback onOpenLeaves;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<HREmployeeLargeDetailResponse>(
          future: employeesDetailLargeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Veri yüklenirken hata oluştu: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final cardWidth = width >= 1240
                      ? (width - 32) / 3
                      : width >= 820
                          ? (width - 16) / 2
                          : width;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _StatCard(
                          title: 'Toplam Personel',
                          value: data.totalEmployees.toString(),
                          note:
                              'Aktif ${data.activeCount} • Pasif ${data.passiveCount}',
                          icon: Icons.groups_2_outlined,
                          accent: const Color(0xFF2563EB),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _StatCard(
                          title: 'İzin Durumu',
                          value: '${data.employeeOnLeaveCount} kişi',
                          note:
                              'İzinde bulunan personel sayısı ${data.employeeOnLeaveCount}',
                          icon: Icons.event_available_outlined,
                          accent: const Color(0xFF0F766E),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _StatCard(
                          title: 'Avans Talepleri',
                          value:
                              data.employeePendingAdvancesRequests.toString(),
                          note: 'Bekleyen avans talebi',
                          icon: Icons.account_balance_wallet_outlined,
                          accent: const Color(0xFF7C3AED),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _StatCard(
                          title: 'Bekleyen İzin Talepleri',
                          value: data.pendingLeavesCount.toString(),
                          note: 'İzin onayı bekleyen personel sayısı',
                          icon: Icons.pending_actions_outlined,
                          accent: const Color(0xFF334155),
                        ),
                      )
                    ],
                  );
                },
              );
            } else {
              return const Text('Veri bulunamadı');
            }
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 720,
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'Aksiyon Gerektirenler',
                      subtitle: 'Bugün kontrol edilmesi gereken kayıtlar',
                    ),
                    const SizedBox(height: 12),
                    _ListItem(
                      title: 'Batuhan Kaya - Yıllık izin talebi',
                      subtitle: '15 Haziran - 18 Haziran • 4 gün',
                      actionLabel: 'İncele',
                      onTap: onOpenLeaves,
                    ),
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
                    _ListItem(
                      title: 'Zehra Demir - Avans talebi',
                      subtitle: '12.500 TL • Haziran kesintisi',
                      actionLabel: 'Görüntüle',
                      onTap: () {},
                    ),
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
                    _ListItem(
                      title: 'Can Arslan - Eksik profil',
                      subtitle: 'Departman ve pozisyon bilgisi bekleniyor',
                      actionLabel: 'Detay',
                      onTap: () => onOpenEmployee(null, 'Can Arslan'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'Hızlı İşlemler',
                      subtitle: 'Sık kullanılan HR aksiyonları',
                    ),
                    const SizedBox(height: 12),
                    _QuickButton(
                        label: 'Personeller',
                        onTap: () => onOpenEmployee(null, 'Batuhan Kaya')),
                    const SizedBox(height: 10),
                    _QuickButton(label: 'İzin Yönetimi', onTap: onOpenLeaves),
                    const SizedBox(height: 10),
                    _QuickButton(label: 'Avanslar', onTap: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersonnelSection extends StatelessWidget {
  const _PersonnelSection({
    required this.onOpenEmployee,
    required this.employeesDetailLargeFuture,
  });

  final void Function(String?, String) onOpenEmployee;
  final Future<HREmployeeLargeDetailResponse> employeesDetailLargeFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HREmployeeLargeDetailResponse>(
      future: employeesDetailLargeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _CardShell(
            child: Text('Personeller yüklenemedi: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const _CardShell(
            child: Text('Personel verisi bulunamadı.'),
          );
        }

        final data = snapshot.data!;
        final employees = data.employees
            .map(
              (employee) => _PersonnelRowData(
                employeeId: employee.id,
                name: employee.fullName,
                role: _positionLabel(employee),
                branch: _branchLabel(employee),
                status: _statusLabel(employee.status),
                startDate: _formatDate(employee.jobsStartDateUtc),
                email: employee.email?.trim().isNotEmpty == true
                    ? employee.email!.trim()
                    : 'E-posta tanımlı değil',
                employeeNo: employee.employeeNo,
              ),
            )
            .toList();

        final incompleteProfiles = data.employees
            .where(
              (employee) =>
                  (employee.email == null || employee.email!.trim().isEmpty) ||
                  employee.positionId == null ||
                  employee.positionId!.isEmpty,
            )
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8FBFF),
                    Color(0xFFF1F5F9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionTitle(
                          title: 'Personel Listesi',
                          subtitle:
                              'Personel görünümü, durum takibi ve hızlı erişim alanı',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          '${data.totalEmployees} kayıt',
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MiniInfoCard(
                        title: 'Aktif Personel',
                        value: data.activeCount.toString(),
                        accent: const Color(0xFF16A34A),
                      ),
                      _MiniInfoCard(
                        title: 'Pasif Kayıt',
                        value: data.passiveCount.toString(),
                        accent: const Color(0xFF64748B),
                      ),
                      _MiniInfoCard(
                        title: 'Eksik Profil',
                        value: incompleteProfiles.toString(),
                        accent: const Color(0xFFD97706),
                      ),
                    ],
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
                      Expanded(
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search,
                                  size: 18, color: Color(0xFF94A3B8)),
                              SizedBox(width: 10),
                              Text(
                                'Personel ara',
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const _FilterChip(label: 'Tüm Durumlar'),
                      const SizedBox(width: 8),
                      const _FilterChip(label: 'Tüm Şubeler'),
                      const SizedBox(width: 8),
                      const _FilterChip(label: 'Yeni Eklenenler'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
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
                                child: Text(
                                  'Şube',
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
                                  'İşe Başlama',
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
                        if (employees.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Gösterilecek personel kaydı bulunamadı.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        else
                          for (var i = 0; i < employees.length; i++) ...[
                            _PersonnelPremiumRow(
                              data: employees[i],
                              onTap: () => onOpenEmployee(
                                employees[i].employeeId,
                                employees[i].name,
                              ),
                            ),
                            if (i != employees.length - 1)
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

  static String _formatDate(DateTime? value) {
    if (value == null) return '—';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }

  static String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case '1':
        return 'Aktif';
      case 'passive':
      case '0':
        return 'Pasif';
      case 'terminated':
        return 'Ayrıldı';
      default:
        return status;
    }
  }

  static String _positionLabel(EmployeeResponse employee) {
    if (employee.positionId != null &&
        employee.positionName != null &&
        employee.positionName!.isNotEmpty) {
      return employee.positionName!;
    }

    return 'Pozisyon Atanmadı';
  }

  static String _branchLabel(EmployeeResponse employee) {
    if (employee.branchId.isEmpty ||
        employee.branchId == '00000000-0000-0000-0000-000000000000') {
      return 'Merkez';
    }

    return 'Şube Tanımlı';
  }
}

class _PersonnelRowData {
  const _PersonnelRowData({
    required this.employeeId,
    required this.name,
    required this.role,
    required this.branch,
    required this.status,
    required this.startDate,
    required this.email,
    required this.employeeNo,
  });

  final String employeeId;
  final String name;
  final String role;
  final String branch;
  final String status;
  final String startDate;
  final String email;
  final String employeeNo;
}

class _MiniInfoCard extends StatelessWidget {
  const _MiniInfoCard({
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
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.expand_more, size: 16, color: Color(0xFF64748B)),
        ],
      ),
    );
  }
}

class _PersonnelPremiumRow extends StatelessWidget {
  const _PersonnelPremiumRow({
    required this.data,
    required this.onTap,
  });

  final _PersonnelRowData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = data.status == 'Aktif';

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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE0EAFF), Color(0xFFF1F5F9)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      data.name.substring(0, 1),
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
                          data.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.employeeNo} • ${data.email}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                          ),
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
                data.role,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                data.branch,
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
                    color: isActive
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF166534)
                          : const Color(0xFF475569),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                data.startDate,
                style: const TextStyle(color: Color(0xFF475569)),
              ),
            ),
            SizedBox(
              width: 44,
              child: IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.chevron_right_rounded),
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: _SectionTitle(title: title, subtitle: description),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.note,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String note;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: SizedBox(
        height: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0F172A),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label),
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
