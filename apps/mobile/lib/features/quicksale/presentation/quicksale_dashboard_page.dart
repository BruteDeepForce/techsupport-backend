import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../data/quicksale_service.dart';
import '../models/quicksale_models.dart';

class QuickSaleDashboardPage extends StatefulWidget {
  const QuickSaleDashboardPage({super.key});

  @override
  State<QuickSaleDashboardPage> createState() => _QuickSaleDashboardPageState();
}

class _QuickSaleDashboardPageState extends State<QuickSaleDashboardPage> {
  final QuickSaleService _service = QuickSaleService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0');
  final TextEditingController _paidController = TextEditingController(text: '0');

  List<QuickSaleStockItem> _stockItems = [];
  List<QuickSaleSummary> _recentSales = [];
  List<QuickSaleCartLine> _cart = [];
  bool _loading = true;
  String _paymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final stockItems = await _service.getStockItems();
      final quickSales = await _service.getQuickSales();
      setState(() {
        _stockItems = stockItems;
        _recentSales = quickSales.take(8).toList();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _addToCart(QuickSaleStockItem item) {
    final index = _cart.indexWhere((line) => line.item.id == item.id);
    setState(() {
      if (index >= 0) {
        _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
      } else {
        _cart.add(QuickSaleCartLine(item: item, quantity: 1, unitPrice: 0));
      }
    });
  }

  double get _subtotal => _cart.fold(0, (sum, line) => sum + line.lineTotal);
  double get _discount => double.tryParse(_discountController.text) ?? 0;
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;
    final paidAmount = double.tryParse(_paidController.text) ?? _total;
    await _service.createQuickSale(
      lines: _cart,
      discountAmount: _discount,
      paidAmount: paidAmount <= 0 ? _total : paidAmount,
      paymentMethod: _paymentMethod,
    );
    _discountController.text = '0';
    _paidController.text = '0';
    setState(() => _cart = []);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hızlı satış tamamlandı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _stockItems.where((item) {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) return true;
      return item.name.toLowerCase().contains(query) || item.sku.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Quick Sale Dashboard'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Ürün ara',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.25,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return InkWell(
                                onTap: () => _addToCart(item),
                                child: LinearCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      Text(item.sku, style: const TextStyle(color: AppColors.textSecondary)),
                                      LinearBadge(
                                        label: 'Stok ${item.availableQuantity}',
                                        color: item.availableQuantity > 0 ? AppColors.statusGreen : AppColors.statusRed,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, color: AppColors.border),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sipariş', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _cart.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final line = _cart[index];
                              return LinearCard(
                                child: Row(
                                  children: [
                                    Expanded(child: Text(line.item.name)),
                                    Text('x${line.quantity}'),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        initialValue: line.unitPrice == 0 ? '' : line.unitPrice.toStringAsFixed(2),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(hintText: 'Fiyat'),
                                        onChanged: (value) {
                                          final parsed = double.tryParse(value) ?? 0;
                                          setState(() {
                                            _cart[index] = _cart[index].copyWith(unitPrice: parsed);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _discountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'İndirim'),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          items: const [
                            DropdownMenuItem(value: 'Cash', child: Text('Nakit')),
                            DropdownMenuItem(value: 'Card', child: Text('Kart')),
                          ],
                          onChanged: (value) => setState(() => _paymentMethod = value ?? 'Cash'),
                          decoration: const InputDecoration(labelText: 'Ödeme Tipi'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _paidController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: 'Ödenen Tutar', hintText: _total.toStringAsFixed(2)),
                        ),
                        const SizedBox(height: 16),
                        LinearCard(
                          child: Column(
                            children: [
                              _SummaryRow(label: 'Ara Toplam', value: _subtotal),
                              _SummaryRow(label: 'İndirim', value: _discount),
                              _SummaryRow(label: 'Toplam', value: _total, emphasize: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _cart.isEmpty ? null : _checkout,
                            icon: const Icon(Icons.point_of_sale_rounded),
                            label: const Text('Satışı Tamamla'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Son Satışlar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _recentSales.length,
                            itemBuilder: (context, index) {
                              final sale = _recentSales[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(sale.saleNumber),
                                subtitle: Text('${sale.paymentMethod} • ${sale.status}'),
                                trailing: Text(sale.totalAmount.toStringAsFixed(2)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: emphasize ? 18 : 14,
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value.toStringAsFixed(2), style: style),
        ],
      ),
    );
  }
}
