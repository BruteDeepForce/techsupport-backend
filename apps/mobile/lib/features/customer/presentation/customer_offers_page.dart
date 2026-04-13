import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../offers/data/offer_service.dart';
import '../../offers/models/offer_models.dart';
import 'customer_offer_detail_page.dart';
import 'customer_home_page.dart';

class CustomerOffersPage extends StatefulWidget {
  const CustomerOffersPage({super.key});

  @override
  State<CustomerOffersPage> createState() => _CustomerOffersPageState();
}

class _CustomerOffersPageState extends State<CustomerOffersPage> {
  final OfferService _offerService = OfferService();
  late Future<List<OfferSummary>> _offersFuture;

  @override
  void initState() {
    super.initState();
    _offersFuture = _offerService.getOffersToCustomerAsync();
  }

  void _refresh() {
    setState(() {
      _offersFuture = _offerService.getOffersToCustomerAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Müşteri',
      subtitle: 'Teklifler',
      trailing: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text('AM',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
      ),
      tabBar: LinearTabBar(
        items: [
          LinearTabItem(
            icon: Icons.grid_view_rounded,
            label: 'Ana Sayfa',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const CustomerHomePage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          const LinearTabItem(
              icon: Icons.local_offer_outlined,
              label: 'Teklifler',
              active: true),
          const LinearTabItem(
              icon: Icons.devices_other_outlined, label: 'Cihazlar'),
          const LinearTabItem(icon: Icons.logout_rounded, label: 'Çıkış'),
        ],
      ),
      children: [
        FutureBuilder<List<OfferSummary>>(
          future: _offersFuture,
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
                    const Text('Teklifler yüklenemedi'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              );
            }
            final offers = snapshot.data ?? [];
            if (offers.isEmpty) {
              return const LinearCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Gösterilecek teklif yok'),
                ),
              );
            }

            return Column(
              children: [
                LinearSection(title: 'Teklifler', count: offers.length),
                LinearCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (int i = 0; i < offers.length; i++)
                        _OfferRow(
                          offer: offers[i],
                          showDivider: i != offers.length - 1,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CustomerOfferDetailPage(offerId: offers[i].id),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow(
      {required this.offer, required this.showDivider, required this.onTap});

  final OfferSummary offer;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = (offer.status ?? 'Pending');
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined,
                color: AppColors.textTertiary, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Teklif ${_shortId(offer.id)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                      'Toplam: ${offer.amount.toStringAsFixed(2)} ${offer.currency}',
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 11)),
                ],
              ),
            ),
            LinearBadge(
                label: _statusLabel(status), color: _statusColor(status)),
          ],
        ),
      ),
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id;

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
