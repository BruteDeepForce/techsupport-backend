import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../operations/data/operation_service.dart';
import '../../operations/models/operation_models.dart';
import '../../stock/data/stock_service.dart';
import '../../stock/models/stock_models.dart';

class TechnicianStockPage extends StatefulWidget {
  const TechnicianStockPage({super.key, this.initialOperationId});

  final String? initialOperationId;

  @override
  State<TechnicianStockPage> createState() => _TechnicianStockPageState();
}

class _TechnicianStockPageState extends State<TechnicianStockPage> {
  final OperationService _operationService = OperationService();
  final StockService _stockService = StockService();

  late Future<List<OperationRecord>> _opsFuture;
  late Future<List<StockCategory>> _categoriesFuture;
  Future<List<StockItem>>? _itemsFuture;

  String? _selectedOperationId;
  String? _selectedCategoryId;
  final Map<String, int> _cart = {};
  final Map<String, StockItem> _itemById = {};
  bool _submitting = false;
  bool _reserved = false;

  @override
  void initState() {
    super.initState();
    _opsFuture = _operationService.listOperations();
    _categoriesFuture = _stockService.listCategories();
    _selectedOperationId = widget.initialOperationId;
  }

  void _selectCategory(String id) {
    setState(() {
      _selectedCategoryId = id;
      _itemsFuture = _stockService.listItemsByCategory(id);
    });
  }

  void _incItem(StockItem item) {
    setState(() {
      _reserved = false;
      _itemById[item.id] = item;
      _cart[item.id] = (_cart[item.id] ?? 0) + 1;
    });
  }

  void _decItem(StockItem item) {
    setState(() {
      _reserved = false;
      final current = _cart[item.id] ?? 0;
      if (current <= 1) {
        _cart.remove(item.id);
      } else {
        _cart[item.id] = current - 1;
      }
    });
  }

  Future<void> _reserveItems() async {
    if (_selectedOperationId == null || _cart.isEmpty) return;
    setState(() => _submitting = true);
    try {
      for (final entry in _cart.entries) {
        await _stockService.reserveStock(
          stockItemId: entry.key,
          operationId: _selectedOperationId!,
          quantity: entry.value,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parçalar rezerve edildi')),
      );
      setState(() => _reserved = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezerv işlemi başarısız')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitOffer() async {
    if (_selectedOperationId == null || !_reserved) return;
    setState(() => _submitting = true);
    try {
      await _stockService.publishOffer(_selectedOperationId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teklif admine gönderildi')),
      );
      setState(() {
        _cart.clear();
        _reserved = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teklif gönderilemedi')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Parça Talebi',
      subtitle: 'Stoktan parça seç ve teklif gönder',
      showBack: true,
      tabBar: const LinearTabBar(
        items: [
          LinearTabItem(
              icon: Icons.assignment_outlined, label: 'İş Emirleri'),
          LinearTabItem(
              icon: Icons.inventory_2_outlined,
              label: 'Stok',
              active: true),
          LinearTabItem(
              icon: Icons.devices_other_outlined, label: 'Cihazlar'),
          LinearTabItem(icon: Icons.logout_rounded, label: 'Çıkış'),
        ],
      ),
      children: [
        LinearCard(
          child: FutureBuilder<List<OperationRecord>>(
            future: _opsFuture,
            builder: (context, snapshot) {
              final ops = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('İş Emri Seç',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedOperationId,
                    items: ops
                        .map(
                          (o) => DropdownMenuItem(
                            value: o.id,
                            child: Text('${_shortId(o.id)} • ${o.title}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedOperationId = v),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<StockCategory>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            final categories = snapshot.data ?? [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (categories.isEmpty) {
              return const LinearCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Kategori bulunamadı'),
                ),
              );
            }
            return LinearCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categories)
                    _CategoryChip(
                      label: c.name,
                      selected: _selectedCategoryId == c.id,
                      onTap: () => _selectCategory(c.id),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        if (_selectedCategoryId == null)
          const LinearCard(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Önce kategori seçin'),
            ),
          )
        else
          FutureBuilder<List<StockItem>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const LinearCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Stok yüklenemedi'),
                  ),
                );
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const LinearCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Kategori içinde ürün yok'),
                  ),
                );
              }
              return LinearCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (final item in items) ...[
                      _StockItemRow(
                        item: item,
                        quantity: _cart[item.id] ?? 0,
                        onAdd: () => _incItem(item),
                        onRemove: () => _decItem(item),
                      ),
                      if (item != items.last)
                        const Divider(height: 16, color: AppColors.borderSubtle),
                    ],
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        if (_cart.isNotEmpty)
          LinearCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seçilen Parçalar',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                for (final entry in _cart.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _itemById[entry.key]?.name ?? entry.key,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('x${entry.value}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting ? null : _reserveItems,
                        child: _submitting && !_reserved
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Rezerve Et'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            _submitting || !_reserved ? null : _submitOffer,
                        child: _submitting && _reserved
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Teklifi Gönder'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentBg : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _StockItemRow extends StatelessWidget {
  const _StockItemRow({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final StockItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                'Stok: ${item.quantityAvailable} • Rezerve: ${item.quantityReserved}',
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: quantity > 0 ? onRemove : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$quantity',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}

String _shortId(String id) =>
    id.length > 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase();
