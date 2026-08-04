import 'package:flutter/material.dart';

import '../../admin_web/presentation/shared/admin_web_nav.dart';
import '../../admin_web/presentation/shared/admin_web_shell.dart';
import '../data/quick_sale_service.dart';

class AdminWebQuickSalePage extends StatefulWidget {
  const AdminWebQuickSalePage({super.key});
  @override
  State<AdminWebQuickSalePage> createState() => _AdminWebQuickSalePageState();
}

class _AdminWebQuickSalePageState extends State<AdminWebQuickSalePage> {
  final _service = QuickSaleService();
  final _search = TextEditingController();
  final Map<String, int> _cart = {};
  late Future<List<QuickSaleProduct>> _products;
  bool _submitting = false;

  @override
  void initState() { super.initState(); _products = _service.products(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  void _load() => setState(() => _products = _service.products(search: _search.text));

  Future<void> _sell(List<QuickSaleProduct> products) async {
    if (_cart.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      final sale = await _service.create(_cart);
      if (!mounted) return;
      setState(() => _cart.clear());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${sale['saleNumber'] ?? 'Satış'} işleme alındı (${sale['status'] ?? 'Pending'}).'),
        backgroundColor: const Color(0xFF16A34A),
      ));
      _load();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Satış başlatılamadı: $error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => AdminWebShell(
        active: AdminNavKey.quickSales,
        body: FutureBuilder<List<QuickSaleProduct>>(
          future: _products,
          builder: (context, snapshot) {
            final products = snapshot.data ?? const <QuickSaleProduct>[];
            final byId = {for (final product in products) product.id: product};
            final total = _cart.entries.fold<double>(0, (sum, entry) => sum + (byId[entry.key]?.unitPrice ?? 0) * entry.value);
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hızlı Satış', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              const Text('Ürün fiyatları backend stok kaydından gelir.', style: TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 20),
              TextField(controller: _search, onSubmitted: (_) => _load(), decoration: InputDecoration(
                hintText: 'Ürün, SKU veya barkod ara', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: _load, icon: const Icon(Icons.arrow_forward)),
                filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              )),
              const SizedBox(height: 20),
              if (snapshot.connectionState == ConnectionState.waiting) const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError) Center(child: Text('Ürünler yüklenemedi: ${snapshot.error}'))
              else LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 650 ? 3 : 2;
                return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.45),
                  itemBuilder: (_, index) {
                    final product = products[index]; final quantity = _cart[product.id] ?? 0;
                    return Card(elevation: 0, color: Colors.white, child: InkWell(borderRadius: BorderRadius.circular(12),
                      onTap: quantity < product.quantityAvailable ? () => setState(() => _cart[product.id] = quantity + 1) : null,
                      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(product.sku, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))), const Spacer(),
                        Text('${product.unitPrice.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                        Row(children: [Text('Stok: ${product.quantityAvailable}'), const Spacer(), if (quantity > 0) Badge(label: Text('$quantity'))]),
                      ])),
                    ));
                  });
              }),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(children: [
                Text('${_cart.values.fold<int>(0, (a, b) => a + b)} ürün', style: const TextStyle(fontWeight: FontWeight.w600)), const Spacer(),
                Text('${total.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(width: 16),
                FilledButton.icon(onPressed: _cart.isEmpty || _submitting ? null : () => _sell(products), icon: _submitting ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.point_of_sale), label: const Text('Satışı Tamamla')),
              ])),
            ]);
          },
        ),
      );
