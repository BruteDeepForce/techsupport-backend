import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import '../../customer/data/customer_service.dart';
import '../../customer/models/customer_models.dart';
import '../../device/data/device_service.dart';
import '../../device/model/device_model.dart';
import '../../operations/data/operation_service.dart';
import '../../operations/models/operation_models.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';
import 'admin_web_customers_page.dart';
import 'admin_web_home_page.dart';
import 'admin_web_operation_detail_page.dart';
import 'admin_web_route.dart';
import 'admin_web_offers_page.dart';
import 'admin_web_stock_page.dart';
import 'admin_web_team_page.dart';
import 'admin_web_tickets_page.dart';
import 'admin_web_device_page.dart';

class AdminWebOperationsPage extends StatefulWidget {
  const AdminWebOperationsPage({super.key});

  @override
  State<AdminWebOperationsPage> createState() => _AdminWebOperationsPageState();
}

class _AdminWebOperationsPageState extends State<AdminWebOperationsPage> {
  final OperationService _operationService = OperationService();
  final CustomerService _customerService = CustomerService();
  final DeviceService _deviceService = DeviceService();
  final TechnicianService _technicianService = TechnicianService();
  late Future<List<OperationRecord>> _opsFuture;
  late Future<List<Customer>> _customersFuture;
  late Future<List<Technician>> _techniciansFuture;

  @override
  void initState() {
    super.initState();
    _opsFuture = _operationService.listOperations();
    _customersFuture = _customerService.listCustomers();
    _techniciansFuture = _technicianService.listTechnicians();
  }

  void _refresh() {
    setState(() {
      _opsFuture = _operationService.listOperations();
      _customersFuture = _customerService.listCustomers();
      _techniciansFuture = _technicianService.listTechnicians();
    });
  }

  Future<void> _showCreateOperationDialog() async {
    List<Customer> customers = [];
    List<Technician> technicians = [];
    try {
      customers = await _customersFuture;
      technicians = await _techniciansFuture;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veriler yüklenemedi')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final internalNoteController = TextEditingController();
    String? selectedCustomerId;
    String? selectedCustomerUserId;
    String? selectedCustomerName; //!
    String? selectedDeviceId;
    String? selectedTechnicianId;
    String? selectedTechnicianName;
    Future<List<DeviceRecord>>? devicesFuture;
    String priority = 'Normal';
    String type = 'Repair';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocalState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İş Emri Oluştur',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedCustomerId,
                        items: [
                          for (final c in customers)
                            DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                        ],
                        onChanged: (v) {
                          selectedCustomerId = v;
                          selectedCustomerUserId = null;
                          selectedDeviceId = null;
                          selectedCustomerName = null; //!
                          if (v != null) {
                            final match =
                                customers.where((e) => e.id == v).toList();
                            if (match.isNotEmpty) {
                              selectedCustomerUserId = match.first.appUserId;
                              selectedCustomerName = match.first.name;
                              if (selectedCustomerUserId != null &&
                                  selectedCustomerUserId!.isNotEmpty) {
                                devicesFuture = _deviceService
                                    .getCustomerDevices(selectedCustomerUserId);
                              } else {
                                devicesFuture = Future.value([]);
                              }
                            }
                          } else {
                            devicesFuture = null;
                          }
                          setLocalState(() {});
                        },
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Müşteri seçin' : null,
                        decoration: InputDecoration(
                          labelText: 'Müşteri',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (devicesFuture == null)
                        const _HintBox('Önce müşteri seçin')
                      else
                        FutureBuilder<List<DeviceRecord>>(
                          future: devicesFuture,
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const _HintBox('Cihazlar yükleniyor...');
                            }
                            if (snap.hasError) {
                              return const _HintBox('Cihazlar yüklenemedi');
                            }
                            final devices = snap.data ?? [];
                            if (devices.isEmpty) {
                              return const _HintBox(
                                  'Müşteriye bağlı cihaz bulunamadı');
                            }
                            return DropdownButtonFormField<String>(
                              value: selectedDeviceId,
                              items: [
                                for (final d in devices)
                                  DropdownMenuItem(
                                    value: d.id,
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 420),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${d.brand} ${d.model} (${d.serialNumber})',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _isWarrantyCovered(d)
                                                  ? const Color(0xFFDCFCE7)
                                                  : const Color(0xFFFEE2E2),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              _isWarrantyCovered(d)
                                                  ? 'Garanti kapsamındadır'
                                                  : 'Garanti kapsamında değil',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _isWarrantyCovered(d)
                                                    ? const Color(0xFF166534)
                                                    : const Color(0xFF991B1B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                              onChanged: (v) {
                                selectedDeviceId = v;
                                setLocalState(() {});
                              },
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Cihaz seçin' : null,
                              decoration: InputDecoration(
                                labelText: 'Cihaz',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 10),
                      _DialogField(
                        label: 'Başlık',
                        controller: titleController,
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _DialogField(
                        label: 'Açıklama',
                        controller: descriptionController,
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _DialogField(
                        label: 'İç Not',
                        controller: internalNoteController,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String?>(
                        value: selectedTechnicianId,
                        hint: const Text('Teknisyen seçme'),
                        items: [
                          for (final t in technicians)
                            DropdownMenuItem<String?>(
                              value: t.userId,
                              child: Text(t.name),
                            ),
                        ],
                        onChanged: (v) {
                          selectedTechnicianId = v;
                          if (v == null) {
                            selectedTechnicianName = null;
                          } else {
                            final match = technicians
                                .where((e) => e.userId == v)
                                .toList();
                            selectedTechnicianName =
                                match.isEmpty ? null : match.first.name;
                          }
                          setLocalState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Teknisyen (Opsiyonel)',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: priority,
                              items: const [
                                DropdownMenuItem(
                                    value: 'Low', child: Text('Düşük')),
                                DropdownMenuItem(
                                    value: 'Normal', child: Text('Normal')),
                                DropdownMenuItem(
                                    value: 'High', child: Text('Yüksek')),
                                DropdownMenuItem(
                                    value: 'Urgent', child: Text('Acil')),
                              ],
                              onChanged: (v) =>
                                  setLocalState(() => priority = v ?? 'Normal'),
                              decoration: InputDecoration(
                                labelText: 'Öncelik',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: type,
                              items: const [
                                DropdownMenuItem(
                                    value: 'Repair', child: Text('Onarım')),
                                DropdownMenuItem(
                                    value: 'Maintenance', child: Text('Bakım')),
                                DropdownMenuItem(
                                    value: 'Installation',
                                    child: Text('Kurulum')),
                              ],
                              onChanged: (v) =>
                                  setLocalState(() => type = v ?? 'Repair'),
                              decoration: InputDecoration(
                                labelText: 'Tür',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                              if (!(formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              if (selectedCustomerId == null ||
                                  selectedDeviceId == null) {
                                return;
                              }
                              if (selectedCustomerUserId == null ||
                                  selectedCustomerUserId!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Seçilen müşteride appUserId bulunamadı'),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(ctx).pop();
                              BuildContext? loadingCtx;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                useRootNavigator: true,
                                builder: (ctx) {
                                  loadingCtx = ctx;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              );
                              //! operation create try-catch
                              try {
                                await _operationService
                                    .createOperation(
                                      customerId: selectedCustomerUserId!,
                                      deviceId: selectedDeviceId!,
                                      title: titleController.text.trim(),
                                      description:
                                          descriptionController.text.trim(),
                                      internalNote: internalNoteController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : internalNoteController.text.trim(),
                                      technicianId: selectedTechnicianId,
                                      technicianName: selectedTechnicianName,
                                      customerName: selectedCustomerName, //!
                                      priority: priority,
                                      type: type,
                                    )
                                    .timeout(const Duration(seconds: 20));
                                if (mounted) {
                                  _refresh();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('İş emri oluşturuldu')),
                                  );
                                }
                              } on TimeoutException {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'İş emri oluşturma zaman aşımına uğradı')),
                                  );
                                }
                              } catch (_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('İş emri oluşturulamadı')),
                                  );
                                }
                              } finally {
                                if (loadingCtx != null) {
                                  Navigator.of(loadingCtx!).pop();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showSidebar = width >= 1100;
    final textTheme = GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FB),
        drawer: showSidebar
            ? null
            : const Drawer(
                child: _WebSidebar(compact: true, active: _NavKey.operations),
              ),
        body: Row(
          children: [
            if (showSidebar)
              const SizedBox(
                width: 260,
                child: _WebSidebar(active: _NavKey.operations),
              ),
            Expanded(
              child: Column(
                children: [
                  const _TopBar(showMenu: false),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                      child: Column(
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
                                      'Operasyon Yönetimi',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Tüm iş emirlerini görüntüleyin ve takip edin',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _SecondaryActionButton(
                                label: 'Yenile',
                                icon: Icons.refresh,
                                onPressed: _refresh,
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: _showCreateOperationDialog,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('İş Emri Oluştur'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _OperationsTableCard(
                            opsFuture: _opsFuture,
                            onOpenOperation: (id) => Navigator.of(context).push(
                              adminWebRoute(
                                AdminWebOperationDetailPage(operationId: id),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NavKey {
  home,
  tickets,
  operations,
  offers,
  team,
  customers,
  devices,
  stock,
  other
}

class _WebSidebar extends StatelessWidget {
  const _WebSidebar({this.compact = false, required this.active});

  final bool compact;
  final _NavKey active;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1E33), Color(0xFF0A1728)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/branding/logo.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                if (!compact)
                  const Text(
                    'Lineer Destek',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Ana Menü',
                  active: active == _NavKey.home,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebHomePage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Talepler',
                  active: active == _NavKey.tickets,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebTicketsPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Operasyonlar',
                  active: active == _NavKey.operations,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebOperationsPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Teklifler',
                  active: active == _NavKey.offers,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebOffersPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.group_outlined,
                  label: 'Ekip Yönetimi',
                  active: active == _NavKey.team,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebTeamPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Müşteri Yönetimi',
                  active: active == _NavKey.customers,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebCustomersPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.devices_other_outlined,
                  label: 'Cihaz Takibi',
                  active: active == _NavKey.devices,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebDevicePage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Stok Yönetimi',
                  active: active == _NavKey.stock,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebStockPage()),
                  ),
                ),
                const _NavItem(icon: Icons.payments_outlined, label: 'Finans'),
                const _NavItem(
                    icon: Icons.query_stats_rounded,
                    label: 'Analiz & Raporlar'),
                const _NavItem(icon: Icons.settings_outlined, label: 'Ayarlar'),
              ],
            ),
          ),
          _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF14263F),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Depolama',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.55,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1D3554),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF60A5FA)),
                ),
              ),
              const SizedBox(height: 6),
              const Text('4.88 GB / 8 GB',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9FB3C8))),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Depolama Ekle',
                      style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2C4469)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: const [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF1C2F4A),
                child: Text('ST',
                    style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Süleyman TÜY... \nTR',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9FB3C8)),
                ),
              ),
              Icon(Icons.logout, size: 18, color: Color(0xFF9FB3C8)),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1B3A5C) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF9FB3C8)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : const Color(0xFF9FB3C8),
                )),
            const Spacer(),
            if (!active)
              const Icon(Icons.expand_more, size: 14, color: Color(0xFF7B8FA8)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showMenu});

  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          const Spacer(),
          _SecondaryActionButton(
            label: 'İş Emri',
            icon: Icons.add,
            onPressed: () {},
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              children: const [
                Text('TR', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(width: 6),
                Icon(Icons.expand_more, size: 16),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.wb_sunny_outlined, color: Color(0xFF64748B)),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE2E8F0),
            child: Text('ST', style: TextStyle(fontSize: 11)),
          ),
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
        Text('Operasyonlar',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _OperationsTableCard extends StatelessWidget {
  const _OperationsTableCard(
      {required this.opsFuture, required this.onOpenOperation});

  final Future<List<OperationRecord>> opsFuture;
  final ValueChanged<String> onOpenOperation;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OperationRecord>>(
      future: opsFuture,
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
              child: Text('Operasyonlar yüklenemedi'),
            ),
          );
        }
        final ops = snapshot.data ?? [];
        if (ops.isEmpty) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Kayıt bulunamadı',
                  style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          );
        }
        return _TableCard(
          child: Column(
            children: [
              const _TableHeader(),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              for (final op in ops)
                _TableRow(
                  id: _shortId(op.id),
                  title: op.title,
                  status: _statusLabel(op.status),
                  statusColor: _statusColor(op.status),
                  priority: _priorityLabel(op.priority),
                  customer: _shortId(op.customerName),
                  device: _shortId(op.deviceId),
                  technician: op.technicianName.isEmpty
                      ? '-'
                      : _shortId(op.technicianName),
                  time: _formatTime(op.occurredAtUtc),
                  onTap: () => onOpenOperation(op.id),
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
      'İş Emri',
      'Başlık',
      'Durum',
      'Öncelik',
      'Müşteri',
      'Cihaz',
      'Teknisyen',
      'Zaman',
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
    required this.id,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.customer,
    required this.device,
    required this.technician,
    required this.time,
    required this.onTap,
  });

  final String id;
  final String title;
  final String status;
  final Color statusColor;
  final String priority;
  final String customer;
  final String device;
  final String technician;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(id,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(status),
                ],
              ),
            ),
            Expanded(child: Text(priority)),
            Expanded(child: Text(customer)),
            Expanded(child: Text(device)),
            Expanded(child: Text(technician)),
            Expanded(child: Text(time)),
          ],
        ),
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

class _HintBox extends StatelessWidget {
  const _HintBox(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
    );
  }
}

bool _isWarrantyCovered(DeviceRecord device) {
  final start = device.warrantyStartAtUtc;
  final end = device.warrantyEndAtUtc;
  if (start == null || end == null) return false;
  return start.isBefore(end);
}

String _shortId(String id) {
  if (id.isEmpty) return '-';
  return id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'diagnosing':
      return 'Teşhis';
    case 'waitingforapproval':
      return 'Onay Bekliyor';
    case 'repairing':
      return 'Onarım';
    case 'testing':
      return 'Test';
    case 'completed':
      return 'Tamamlandı';
    case 'delivered':
      return 'Teslim';
    default:
      return 'Yeni';
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'delivered':
      return const Color(0xFF22C55E);
    case 'waitingforapproval':
      return const Color(0xFFF59E0B);
    case 'repairing':
    case 'testing':
      return const Color(0xFFF59E0B);
    case 'diagnosing':
      return const Color(0xFF3B82F6);
    default:
      return const Color(0xFF64748B);
  }
}

String _priorityLabel(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return 'Kritik';
    case 'high':
      return 'Yüksek';
    case 'medium':
      return 'Orta';
    default:
      return 'Normal';
  }
}

String _formatTime(DateTime dt) {
  final local = dt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}
