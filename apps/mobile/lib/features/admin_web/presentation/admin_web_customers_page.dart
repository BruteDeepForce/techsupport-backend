import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../customer/data/customer_service.dart';
import '../../customer/models/customer_models.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_sidebar.dart';
import 'shared/admin_web_topbar.dart';

class AdminWebCustomersPage extends StatefulWidget {
  const AdminWebCustomersPage({super.key});

  @override
  State<AdminWebCustomersPage> createState() => _AdminWebCustomersPageState();
}

class _AdminWebCustomersPageState extends State<AdminWebCustomersPage> {
  final CustomerService _customerService = CustomerService();
  late Future<List<Customer>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _customersFuture = _customerService.listCustomers();
  }

  void _refreshCustomers() {
    setState(() {
      _customersFuture = _customerService.listCustomers();
    });
  }

  void _showAddCustomerDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Müşteri Bilgileri',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 14),
                  _DialogField(
                    label: 'Ad Soyad',
                    controller: nameController,
                    requiredField: true,
                  ),
                  const SizedBox(height: 10),
                  _DialogField(
                    label: 'E-posta',
                    controller: emailController,
                    requiredField: true,
                  ),
                  const SizedBox(height: 10),
                  _DialogField(
                    label: 'Telefon',
                    controller: phoneController,
                  ),
                  const SizedBox(height: 10),
                  _DialogField(
                    label: 'Geçici Şifre',
                    controller: passwordController,
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
                          Navigator.of(ctx).pop();
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) =>
                                  const Center(child: CircularProgressIndicator()));
                          try {
                            final correlationId = await _customerService.createCustomer(
                              CustomerCreateRequest(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                phoneNumber: phoneController.text.trim().isEmpty
                                    ? null
                                    : phoneController.text.trim(),
                                temporaryPassword: passwordController.text.trim(),
                              ),
                            );
                            if (mounted) Navigator.of(context).pop();
                            if (correlationId == null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Müşteri oluşturulamadı')),
                              );
                              return;
                            }
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Müşteri oluşturma başlatıldı. Listeyi yenileyin.')),
                            );
                          } catch (e) {
                            if (mounted) Navigator.of(context).pop();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Müşteri oluşturulamadı: $e')),
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
    final showSidebar = width >= 1100;
    final textTheme = GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FB),
        drawer: showSidebar
            ? null
            : const Drawer(
                child: AdminWebSidebar(
                    compact: true, radius: 0, active: AdminNavKey.customers)),
        body: Row(
          children: [
            if (showSidebar) const AdminWebSidebarPanel(active: AdminNavKey.customers),
            Expanded(
              child: Column(
                children: [
                  const AdminWebTopBar(showMenu: false),
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
                                      'Müşteri Yönetimi',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Müşterileri yönetin ve yeni müşteri ekleyin',
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
                                    label: 'Yenile',
                                    icon: Icons.refresh,
                                    onPressed: _refreshCustomers,
                                  ),
                                  const SizedBox(width: 10),
                                  _PrimaryActionButton(
                                    label: 'Müşteri Ekle',
                                    icon: Icons.add,
                                    onPressed: () => _showAddCustomerDialog(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _CustomersTableCard(customersFuture: _customersFuture),
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

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text('Yönetim', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Müşteri Yönetimi',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _CustomersTableCard extends StatelessWidget {
  const _CustomersTableCard({required this.customersFuture});

  final Future<List<Customer>> customersFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Customer>>(
      future: customersFuture,
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
          return _TableCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Müşteriler yüklenemedi: ${snapshot.error}'),
            ),
          );
        }
        final customers = snapshot.data ?? [];
        if (customers.isEmpty) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Henüz müşteri yok.'),
            ),
          );
        }

        return _TableCard(
          child: Column(
            children: [
              const _TableHeader(),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              for (final customer in customers)
                _TableRow(
                  name: customer.name,
                  email: customer.email,
                  phone: customer.phoneNumber ?? '-',
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: Text('Ad Soyad',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 2,
            child: Text('E-posta',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 1,
            child: Text('Telefon',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.name, required this.email, required this.phone});

  final String name;
  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(name,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          ),
          Expanded(
            flex: 2,
            child: Text(email,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 1,
            child: Text(phone,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          ),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField(
      {required this.label, required this.controller, this.requiredField = false});

  final String label;
  final TextEditingController controller;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator:
          requiredField ? (v) => (v == null || v.isEmpty) ? 'Gerekli' : null : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
