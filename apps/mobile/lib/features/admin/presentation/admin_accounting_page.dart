import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../accounting/data/accounting_service.dart';
import '../../accounting/models/accounting_models.dart';
import '../../accounting/presentation/accounting_dashboard_content.dart';
import 'admin_home_page.dart';
import 'admin_tickets_page.dart';
import 'admin_work_orders_page.dart';
import 'admin_devices_page.dart';
import 'inventory_management_page.dart';
import 'admin_team_page.dart';
import 'package:techsupport_mobile/core/design/admin_design.dart';
import 'package:techsupport_mobile/core/design/app_design.dart';

class AdminAccountingPage extends StatefulWidget {
  const AdminAccountingPage({super.key});

  @override
  State<AdminAccountingPage> createState() => _AdminAccountingPageState();
}

class _AdminAccountingPageState extends State<AdminAccountingPage> {
  final AccountingService _service = AccountingService();
  late Future<AccountingDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _service.getDashboard();
  }

  void _refresh() {
    setState(() => _dashboardFuture = _service.getDashboard());
  }

  Future<void> _openInvoice(AccountingInvoice invoice) async {
    try {
      final bytes = await _service.downloadInvoicePdf(invoice.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _AccountingInvoicePdfPage(
            number: invoice.number,
            bytes: bytes,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fatura PDF’i açılamadı: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell.dark(
      title: 'Muhasebe',
      subtitle: 'Admin Portal',
      trailing: IconButton(
        tooltip: 'Yenile',
        onPressed: _refresh,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      tabBar: LinearTabBar(
        items: [
          LinearTabItem(
            icon: Icons.grid_view_rounded,
            label: 'Bakış',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const AdminHomePage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Talep',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.assignment_rounded,
            label: 'İş Emri',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const AdminWorkOrdersPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.devices_other_outlined,
            label: 'Cihaz',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const AdminDevicesPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.inventory_2_outlined,
            label: 'Stok',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const InventoryManagementPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          LinearTabItem(
            icon: Icons.group_outlined,
            label: 'Ekip',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const AdminTeamPage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          const LinearTabItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Muhasebe',
            active: true,
          ),
        ],
      ),
      children: [
        FutureBuilder<AccountingDashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.hasError) {
              return LinearCard(
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off_outlined,
                        size: 36, color: AdminTechColors.textTertiary),
                    const SizedBox(height: 10),
                    const Text('Muhasebe verileri yüklenemedi',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('${snapshot.error}',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AdminTechColors.textSecondary)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }
            return AccountingDashboardContent(
              data: snapshot.data!,
              webLayout: false,
              onOpenInvoice: _openInvoice,
            );
          },
        ),
      ],
    );
  }
}

class _AccountingInvoicePdfPage extends StatelessWidget {
  const _AccountingInvoicePdfPage({
    required this.number,
    required this.bytes,
  });

  final String number;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fatura $number')),
      body: SfPdfViewer.memory(bytes),
    );
  }
}
