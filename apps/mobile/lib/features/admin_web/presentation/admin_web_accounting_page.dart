import 'package:flutter/material.dart';

import '../../../core/utils/pdf_blob_opener.dart';
import '../../accounting/data/accounting_service.dart';
import '../../accounting/models/accounting_models.dart';
import '../../accounting/presentation/accounting_dashboard_content.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';

class AdminWebAccountingPage extends StatefulWidget {
  const AdminWebAccountingPage({super.key});

  @override
  State<AdminWebAccountingPage> createState() => _AdminWebAccountingPageState();
}

class _AdminWebAccountingPageState extends State<AdminWebAccountingPage> {
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
      final opened = openPdfInNewTab(bytes, fileName: '${invoice.number}.pdf');
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF yeni sekmede açılamadı.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fatura PDF’i açılamadı: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      active: AdminNavKey.accounting,
      actions: [
        AdminWebActionButton(
          label: 'Yenile',
          icon: Icons.refresh_rounded,
          onPressed: _refresh,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Breadcrumb(),
          const SizedBox(height: 12),
          const _Header(),
          const SizedBox(height: 18),
          FutureBuilder<AccountingDashboardData>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingPanel();
              }
              if (snapshot.hasError) {
                return _ErrorPanel(error: snapshot.error, onRetry: _refresh);
              }
              return AccountingDashboardContent(
                data: snapshot.data!,
                webLayout: true,
                onOpenInvoice: _openInvoice,
              );
            },
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
    return const Row(
      children: [
        Text('Yönetim',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Muhasebe',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Muhasebe',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A)),
        ),
        SizedBox(height: 5),
        Text(
          'Faturaları, tahsilatları ve cari hareketleri tek yerden izleyin.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 280,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 38, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          const Text('Muhasebe verileri yüklenemedi',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('$error',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}
