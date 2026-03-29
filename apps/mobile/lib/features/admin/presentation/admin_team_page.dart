import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';
import '../../technician/presentation/technician_detail_page.dart';
import 'admin_home_page.dart';
import 'admin_tickets_page.dart';
import 'admin_devices_page.dart';
import 'admin_work_orders_page.dart';
import 'inventory_management_page.dart';

class AdminTeamPage extends StatefulWidget {
  const AdminTeamPage({super.key});

  @override
  State<AdminTeamPage> createState() => _AdminTeamPageState();
}

class _AdminTeamPageState extends State<AdminTeamPage> {
  final TechnicianService _techService = TechnicianService();
  List<Technician> _technicians = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    try {
      setState(() => _loading = true);
      final list = await _techService.listTechnicians();
      setState(() {
        _technicians = list;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      // optionally show error
    }
  }

  void _showCreateTechnicianDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? firstName, lastName, email, phone, tempPassword;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yeni Teknisyen Ekle',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                LinearCard(
                  padding: const EdgeInsets.all(12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStyledField(
                                label: 'İsim',
                                onSaved: (v) => firstName = v,
                                validator: (v) =>
                                    (v == null || v.isEmpty) ? 'Gerekli' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStyledField(
                                label: 'Soyisim',
                                onSaved: (v) => lastName = v,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildStyledField(
                            label: 'E-posta',
                            onSaved: (v) => email = v,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Gerekli' : null),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: _buildStyledField(
                                    label: 'Telefon',
                                    onSaved: (v) => phone = v)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildStyledField(
                                    label: 'Geçici Şifre',
                                    onSaved: (v) => tempPassword = v,
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'Gerekli'
                                        : null)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('İptal')),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () async {
                        if (!(_formKey.currentState?.validate() ?? false))
                          return;
                        _formKey.currentState?.save();
                        Navigator.of(ctx).pop();
                        // show simple progress
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                                child: CircularProgressIndicator()));
                        try {
                          final correlationId =
                              await _techService.createTechnician(
                                  firstName: firstName ?? '',
                                  lastName: lastName,
                                  email: email ?? '',
                                  phoneNumber: phone,
                                  temporaryPassword:
                                      tempPassword ?? 'Temp123!');
                          Navigator.of(context).pop(); // pop progress
                          if (correlationId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Teknisyen oluşturulamadı')));
                            return;
                          }

                          // Do NOT poll provisioning status. User will refresh the page manually.
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Teknisyen oluşturma başlatıldı. Sayfayı yenileyin.')));
                          return;
                        } catch (e) {
                          Navigator.of(context).pop(); // pop progress
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Teknisyen oluşturulamadı')));
                        }
                      },
                      child: const Text('Oluştur'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyledField(
      {required String label,
      FormFieldSetter<String?>? onSaved,
      FormFieldValidator<String?>? validator}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.bgElevated,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: AppColors.border)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Ekip',
      subtitle: 'Admin Portal',
      trailing: GestureDetector(
        onTap: () => _showCreateTechnicianDialog(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.person_add_rounded,
              color: Colors.white, size: 22),
        ),
      ),
      tabBar: LinearTabBar(
        items: [
          LinearTabItem(
            icon: Icons.grid_view_rounded,
            label: 'Bakış',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminHomePage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Talep',
            count: 6,
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.assignment_rounded,
            label: 'İş Emri',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminWorkOrdersPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.devices_other_outlined,
            label: 'Cihaz',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AdminDevicesPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.inventory_2_outlined,
            label: 'Stok',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const InventoryManagementPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          const LinearTabItem(
            icon: Icons.group_outlined,
            label: 'Ekip',
            active: true,
          ),
        ],
      ),
      children: [
        // ── Active Technicians ────────────────────────────────────
        Row(
          children: [
            Expanded(
                child: LinearSection(
                    title: 'Aktif Teknisyenler', count: _technicians.length)),
          ],
        ),
        const SizedBox(height: 8),
        LinearCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: _loading
                ? [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('Yükleniyor...')),
                    )
                  ]
                : _technicians.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('Teknisyen bulunamadı.')),
                        )
                      ]
                    : List.generate(_technicians.length, (i) {
                        final t = _technicians[i];
                        final name =
                            '${t.firstName}${t.lastName != null ? ' ${t.lastName}' : ''}';
                        return _TeamMemberRow(
                          id: t.id,
                          name: name,
                          role: 'Teknisyen',
                          tasks: 0,
                          isActive: t.isActive,
                          status: t.isActive ? 'Aktif' : 'Pasif',
                          statusColor: t.isActive
                              ? AppColors.statusGreen
                              : AppColors.statusGray,
                          showDivider: i != _technicians.length - 1,
                          onToggleActive: (newVal) async {
                            try {
                              await _techService.setActive(t.id, newVal);
                              await _loadTechnicians();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Aktif/pasif güncelleme başarısız')));
                            }
                          },
                          onViewDetails: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TechnicianDetailPage(id: t.id))),
                        );
                      }),
          ),
        ),

        const SizedBox(height: 16),

        // ── Performance Metrics ───────────────────────────────────
        const LinearSection(title: 'Haftalık Performans'),
        Row(
          children: [
            _StatCard(
                label: 'Çözülen',
                value: '24',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.statusGreen),
            const SizedBox(width: 12),
            _StatCard(
                label: 'Geciken',
                value: '2',
                icon: Icons.access_time_rounded,
                color: AppColors.statusRed),
          ],
        ),

        const SizedBox(height: 16),

        // ── Working Hours Summary ─────────────────────────────────
        LinearCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ekip Doluluk Oranı',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.7,
                        minHeight: 8,
                        backgroundColor: AppColors.bg,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('70%',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamMemberRow extends StatelessWidget {
  const _TeamMemberRow({
    required this.name,
    required this.role,
    required this.tasks,
    required this.status,
    required this.statusColor,
    this.showDivider = true,
    this.id,
    this.isActive,
    this.onToggleActive,
    this.onViewDetails,
  });

  final String? id;
  final String name;
  final String role;
  final int tasks;
  final String status;
  final Color statusColor;
  final bool showDivider;
  final bool? isActive;
  final Future<void> Function(bool)? onToggleActive;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 1))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: AppColors.bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(name.substring(0, 1),
                style: const TextStyle(
                    color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onViewDetails,
                  child: Text(name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 2),
                Text(role,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$tasks Görev',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (val) async {
                      if (val == 'toggle' &&
                          onToggleActive != null &&
                          isActive != null) {
                        await onToggleActive!(!isActive!);
                      }
                      if (val == 'details' && onViewDetails != null)
                        onViewDetails!();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'details', child: Text('Detay')),
                      PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                              isActive == true ? 'Pasif Yap' : 'Aktif Yap')),
                    ],
                    child: const Icon(Icons.more_vert,
                        size: 18, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LinearCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
