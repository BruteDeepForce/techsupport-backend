import 'package:flutter/material.dart';
import '../../offers/data/offer_service.dart';
import '../../offers/models/offer_models.dart';
import 'admin_web_offer_detail_page.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';

class AdminWebOffersPage extends StatefulWidget {
  const AdminWebOffersPage({super.key});

  @override
  State<AdminWebOffersPage> createState() => _AdminWebOffersPageState();
}

class _AdminWebOffersPageState extends State<AdminWebOffersPage> {
  final OfferService _offerService = OfferService();
  late Future<List<OfferSummary>> _offersFuture;

  @override
  void initState() {
    super.initState();
    _offersFuture = _offerService.getOffersToAdminAsync();
  }

  void _refresh() {
    setState(() {
      _offersFuture = _offerService.getOffersToAdminAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      active: AdminNavKey.offers,
      actions: [
        AdminWebActionButton(
          label: 'Yenile',
          icon: Icons.refresh,
          onPressed: _refresh,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Breadcrumb(),
          const SizedBox(height: 12),
          const _Header(),
          const SizedBox(height: 16),
          FutureBuilder<List<OfferSummary>>(
            future: _offersFuture,
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              return _MetricRow(offers: list);
            },
          ),
          const SizedBox(height: 16),
          _OffersTableCard(
            offersFuture: _offersFuture,
            onOpenOffer: (id) => Navigator.of(context).push(
              adminNavRoute(
                AdminWebOfferDetailPage(offerId: id),
              ),
            ),
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
        Text('Teklifler',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teklifler',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Teknisyenlerden gelen teklifleri yönetin',
                style: TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.offers});

  final List<OfferSummary> offers;

  @override
  Widget build(BuildContext context) {
    final total = offers.length;
    final totalAmount =
        offers.fold<double>(0, (sum, o) => sum + o.amount);
    final totalItems = offers.fold<int>(
        0, (sum, o) => sum + o.items.fold<int>(0, (s, i) => s + i.quantity));

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.6,
      padding: EdgeInsets.zero,
      children: [
        _MetricCard(
            title: 'Toplam Teklif',
            value: total.toString(),
            icon: Icons.local_offer_outlined,
            color: const Color(0xFF3B82F6)),
        _MetricCard(
            title: 'Toplam Kalem',
            value: totalItems.toString(),
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF22C55E)),
        _MetricCard(
            title: 'Toplam Tutar',
            value: totalAmount.toStringAsFixed(2),
            icon: Icons.payments_outlined,
            color: const Color(0xFFF59E0B)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
              Text(title,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

class _OffersTableCard extends StatelessWidget {
  const _OffersTableCard(
      {required this.offersFuture, required this.onOpenOffer});

  final Future<List<OfferSummary>> offersFuture;
  final ValueChanged<String> onOpenOffer;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OfferSummary>>(
      future: offersFuture,
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
              child: Text('Teklifler yüklenemedi'),
            ),
          );
        }
        final offers = snapshot.data ?? [];
        if (offers.isEmpty) {
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
              for (final offer in offers)
                _TableRow(
                  offer: offer,
                  onTap: () => onOpenOffer(offer.id),
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
      'Teklif',
      'Operasyon',
      'Teknisyen',
      'Müşteri',
      'Kalem',
      'Tutar',
      'Tarih',
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
  const _TableRow({required this.offer, required this.onTap});

  final OfferSummary offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemCount =
        offer.items.fold<int>(0, (sum, i) => sum + i.quantity);
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
                child: Text(_shortId(offer.id),
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(_shortId(offer.operationId))),
            Expanded(child: Text(_shortId(offer.technicianUserId))),
            Expanded(child: Text(offer.customerId ?? '-')),
            Expanded(child: Text('$itemCount')),
            Expanded(
                child:
                    Text('${offer.amount.toStringAsFixed(2)} ${offer.currency}')),
            Expanded(child: Text(_formatTime(offer.createdAt))),
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

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

String _formatTime(DateTime dt) {
  final local = dt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}
