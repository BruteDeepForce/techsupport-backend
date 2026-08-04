import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../core/design/app_design.dart';
import '../../../core/utils/pdf_blob_opener.dart';
import '../../offers/data/offer_service.dart';
import '../../offers/models/offer_models.dart';
import '../../offers/presentation/offer_invoice_pdf_page.dart';

class CustomerOfferDetailPage extends StatefulWidget {
  const CustomerOfferDetailPage({super.key, required this.offerId});

  final String offerId;

  @override
  State<CustomerOfferDetailPage> createState() =>
      _CustomerOfferDetailPageState();
}

class _CustomerOfferDetailPageState extends State<CustomerOfferDetailPage> {
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
      final ok = await _offerService.approveCustomer(widget.offerId);
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
      final ok = await _offerService.rejectCustomer(widget.offerId);
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

  Future<void> _openInvoicePdf() async {
    setState(() => _openingPdf = true);
    try {
      final bytes = await _offerService.getOfferInvoicePdf(widget.offerId);
      if (!mounted) return;
      if (kIsWeb) {
        final opened = openPdfInNewTab(
          bytes,
          fileName: 'teklif-faturasi-${_shortId(widget.offerId)}.pdf',
        );
        if (!opened) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF bu platformda yeni sekmede acilamadi')),
          );
        }
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              OfferInvoicePdfPage(offerId: widget.offerId, pdfBytes: bytes),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _openingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Teklif',
      subtitle: 'Teklif Detayı',
      showBack: true,
      tabBar: const LinearTabBar(
        items: [
          LinearTabItem(icon: Icons.grid_view_rounded, label: 'Ana Sayfa'),
          LinearTabItem(
              icon: Icons.local_offer_outlined,
              label: 'Teklifler',
              active: true),
          LinearTabItem(icon: Icons.devices_other_outlined, label: 'Cihazlar'),
          LinearTabItem(icon: Icons.logout_rounded, label: 'Çıkış'),
        ],
      ),
      children: [
        FutureBuilder<OfferSummary>(
          future: _offerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return LinearCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Teklif yüklenemedi'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              );
            }
            final offer = snapshot.data;
            if (offer == null) {
              return const LinearCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Teklif bulunamadı'),
                ),
              );
            }

            final status = (offer.status ?? 'Pending');
            final isActionable =
                ['pending', 'adminapproved'].contains(status.toLowerCase());
            final itemCount =
                offer.items.fold<int>(0, (sum, i) => sum + i.quantity);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Teklif ${_shortId(offer.id)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                          'Toplam: ${offer.amount.toStringAsFixed(2)} ${offer.currency}',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      LinearBadge(
                          label: _statusLabel(status),
                          color: _statusColor(status)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LinearCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ItemHeader(count: itemCount),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      for (final item in offer.items) _ItemRow(item: item),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openingPdf ? null : _openInvoicePdf,
                    icon: _openingPdf
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Teklif Faturasını Görüntüle'),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _acting || !isActionable ? null : _reject,
                        child: const Text('Reddet'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _acting || !isActionable ? null : _approve,
                        child: const Text('Onayla'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ItemHeader extends StatelessWidget {
  const _ItemHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Expanded(
              child: Text('Kalemler',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary))),
          Text('$count',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(_shortId(item.stockItemId))),
          Text('x${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Text(item.unitPrice.toStringAsFixed(2),
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'customerapproved':
      return 'Onaylandı';
    case 'adminrejected':
    case 'customerrejected':
      return 'Reddedildi';
    default:
      return 'Açık teklif';
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'adminapproved':
    case 'customerapproved':
      return AppColors.statusGreen;
    case 'adminrejected':
    case 'customerrejected':
      return AppColors.statusRed;
    default:
      return AppColors.statusYellow;
  }
}
