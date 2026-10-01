import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/pdf_blob_opener.dart';
import '../../offers/data/offer_service.dart';
import '../../offers/models/offer_models.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_sidebar.dart';
import 'shared/admin_web_topbar.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/shared/admin_web_design.dart';
import 'shared/admin_web_shell.dart';

class AdminWebOfferDetailPage extends StatefulWidget {
  const AdminWebOfferDetailPage({super.key, required this.offerId});

  final String offerId;

  @override
  State<AdminWebOfferDetailPage> createState() =>
      _AdminWebOfferDetailPageState();
}

class _AdminWebOfferDetailPageState extends State<AdminWebOfferDetailPage> {
  final OfferService _offerService = OfferService();
  late Future<OfferSummary> _offerFuture;
  bool _acting = false;
  bool _openingPdf = false;

  @override
  void initState() {
    super.initState();
    _offerFuture = _offerService.getOfferById(widget.offerId);
  }

  void _refresh() {
    setState(() {
      _offerFuture = _offerService.getOfferById(widget.offerId);
    });
  }

  Future<void> _approve() async {
    setState(() => _acting = true);
    try {
      final ok = await _offerService.approveAdmin(widget.offerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ok ? 'Teklif onaylandı' : 'Onay başarısız')));
      _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Onay başarısız')));
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _acting = true);
    try {
      final ok = await _offerService.rejectAdmin(widget.offerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Teklif reddedildi' : 'Reddetme başarısız')));
      _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reddetme başarısız')));
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _openInvoicePdfWebModal() async {
    setState(() => _openingPdf = true);
    try {
      final bytes = await _offerService.getOfferInvoicePdf(widget.offerId);
      if (!mounted) return;
      final opened = openPdfInNewTab(
        bytes,
        fileName: 'teklif-faturasi-${_shortId(widget.offerId)}.pdf',
      );
      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('PDF bu platformda yeni sekmede acilamadi')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _openingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showSidebar = width >= 1100;
    final textTheme = GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme);

    return AdminWebShell(
      active: AdminNavKey.offers,
      dark: true,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
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
                      'Teklif Detayı',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AdminTechColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Teklife ait kalemleri ve toplam tutarı inceleyin',
                      style: TextStyle(
                        color: AdminTechColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<OfferSummary>(
            future: _offerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const _Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Teklif yüklenemedi'),
                  ),
                );
              }
              final offer = snapshot.data;
              if (offer == null) {
                return const _Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Kayıt bulunamadı'),
                  ),
                );
              }

              final itemCount =
                  offer.items.fold<int>(0, (sum, i) => sum + i.quantity);
              final status = (offer.status ?? 'Pending');
              final isPending = status.toLowerCase() == 'pending';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Teklif ${_shortId(offer.id)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AdminTechColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Operasyon: ${_shortId(offer.operationId)}',
                                  style: const TextStyle(
                                      color: AdminTechColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _Pill(
                                      label: 'Kalem: $itemCount',
                                      color: AdminTechColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    _Pill(
                                      label: _statusLabel(status),
                                      color: _statusColor(status),
                                    ),
                                    const SizedBox(width: 8),
                                    _Pill(
                                      label:
                                          '${offer.amount.toStringAsFixed(2)} ${offer.currency}',
                                      color: AdminTechColors.statusAmber,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Teknisyen',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AdminTechColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(_shortId(offer.technicianUserId)),
                              const SizedBox(height: 12),
                              const Text('Müşteri',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AdminTechColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(offer.customerId ?? '-'),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _openingPdf
                                        ? null
                                        : _openInvoicePdfWebModal,
                                    icon: _openingPdf
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.picture_as_pdf_outlined),
                                    label: const Text('Fatura PDF'),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton(
                                    onPressed:
                                        _acting || !isPending ? null : _reject,
                                    child: const Text('Reddet'),
                                  ),
                                  const SizedBox(width: 10),
                                  FilledButton(
                                    onPressed:
                                        _acting || !isPending ? null : _approve,
                                    child: const Text('Onayla'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    child: Column(
                      children: [
                        const _ItemsHeader(),
                        const Divider(height: 1, color: AdminTechColors.border),
                        for (final item in offer.items) _ItemRow(item: item),
                      ],
                    ),
                  ),
                ],
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
    return Row(
      children: const [
        Text('Yönetim',
            style:
                TextStyle(fontSize: 12, color: AdminTechColors.textTertiary)),
        SizedBox(width: 6),
        Icon(Icons.chevron_right,
            size: 14, color: AdminTechColors.textTertiary),
        SizedBox(width: 6),
        Text('Teklifler',
            style:
                TextStyle(fontSize: 12, color: AdminTechColors.textSecondary)),
        SizedBox(width: 6),
        Icon(Icons.chevron_right,
            size: 14, color: AdminTechColors.textTertiary),
        SizedBox(width: 6),
        Text('Detay',
            style:
                TextStyle(fontSize: 12, color: AdminTechColors.textSecondary)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminTechColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTechColors.border),
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'adminapproved':
      return 'Admin Onayladı';
    case 'customerapproved':
      return 'Müşteri Onayladı';
    case 'adminrejected':
      return 'Admin Reddetti';
    case 'customerrejected':
      return 'Müşteri Reddetti';
    default:
      return 'Beklemede';
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'adminapproved':
    case 'customerapproved':
      return AdminTechColors.green;
    case 'adminrejected':
    case 'customerrejected':
      return AdminTechColors.statusRed;
    default:
      return AdminTechColors.statusAmber;
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
        foregroundColor: AdminTechColors.textPrimary,
        side: const BorderSide(color: AdminTechColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AdminTechColors.surface,
      ),
    );
  }
}

class _ItemsHeader extends StatelessWidget {
  const _ItemsHeader();

  @override
  Widget build(BuildContext context) {
    final headers = ['Parça Adı', 'Stok Id', 'Miktar', 'Birim Fiyat'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminTechColors.border)),
      ),
      child: Row(
        children: headers
            .map((h) => Expanded(
                  child: Text(
                    h,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AdminTechColors.textSecondary,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OfferItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminTechColors.surfaceAlt)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name.isNotEmpty ? item.name : '-',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: Text(_shortId(item.stockItemId))),
          Expanded(child: Text('${item.quantity}')),
          Expanded(child: Text(item.unitPrice.toStringAsFixed(2))),
        ],
      ),
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
