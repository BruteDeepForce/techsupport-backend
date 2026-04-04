import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../stock/data/stock_service.dart';
import '../../stock/models/stock_models.dart';
import 'admin_web_customers_page.dart';
import 'admin_web_home_page.dart';
import 'admin_web_operations_page.dart';
import 'admin_web_route.dart';
import 'admin_web_team_page.dart';
import 'admin_web_tickets_page.dart';

class AdminWebStockPage extends StatefulWidget {
  const AdminWebStockPage({super.key});

  @override
  State<AdminWebStockPage> createState() => _AdminWebStockPageState();
}

class _AdminWebStockPageState extends State<AdminWebStockPage> {
  final StockService _stockService = StockService();
  late Future<List<StockCategory>> _categoriesFuture;
  Future<List<StockItem>>? _itemsFuture;
  late Future<List<StockItem>> _allItemsFuture;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _stockService.listCategories();
    _allItemsFuture = _stockService.listItems();
  }

  void _refresh() {
    setState(() {
      _categoriesFuture = _stockService.listCategories();
      _allItemsFuture = _stockService.listItems();
      if (_selectedCategoryId != null) {
        _itemsFuture =
            _stockService.listItemsByCategory(_selectedCategoryId!);
      }
    });
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategori Ekle',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Kategori Adı',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
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
                      if (controller.text.trim().isEmpty) return;
                      Navigator.of(ctx).pop();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        await _stockService.createCategory(
                            name: controller.text.trim());
                        if (mounted) Navigator.of(context).pop();
                        if (mounted) {
                          _refresh();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kategori eklendi')),
                          );
                        }
                      } catch (_) {
                        if (mounted) Navigator.of(context).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Kategori eklenemedi')),
                          );
                        }
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
  }

  void _showAddItemDialog(List<StockCategory> categories) {
    final formKey = GlobalKey<FormState>();
    final skuController = TextEditingController();
    final barcodeController = TextEditingController();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final unitController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    String? selectedCategoryId;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stok Kalemi Ekle',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _DialogField(
                        label: 'SKU',
                        controller: skuController,
                        requiredField: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogField(
                        label: 'Barkod',
                        controller: barcodeController,
                        requiredField: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _DialogField(
                  label: 'Ürün Adı',
                  controller: nameController,
                  requiredField: true,
                ),
                const SizedBox(height: 10),
                _DialogField(
                  label: 'Açıklama',
                  controller: descController,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DialogField(
                        label: 'Birim',
                        controller: unitController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogField(
                        label: 'Başlangıç Adedi',
                        controller: qtyController,
                        requiredField: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  items: [
                    ...categories.map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => selectedCategoryId = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Kategori seçin' : null,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
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
                        final qty =
                            int.tryParse(qtyController.text.trim()) ?? 0;
                        if (qty <= 0) return;
                        Navigator.of(ctx).pop();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        if (selectedCategoryId == null ||
                            selectedCategoryId!.isEmpty) {
                          return;
                        }
                        try {
                          await _stockService.createItem(
                            categoryId: selectedCategoryId!,
                            sku: skuController.text.trim(),
                            barcode: barcodeController.text.trim(),
                            name: nameController.text.trim(),
                            description: descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim(),
                            unit: unitController.text.trim().isEmpty
                                ? null
                                : unitController.text.trim(),
                            initialQuantity: qty,
                          );
                          if (mounted) Navigator.of(context).pop();
                          if (mounted) {
                            _refresh();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ürün eklendi')),
                            );
                          }
                        } catch (_) {
                          if (mounted) Navigator.of(context).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Ürün eklenemedi')),
                            );
                          }
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
      ),
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
                child: _WebSidebar(compact: true, active: _NavKey.stock),
              ),
        body: Row(
          children: [
            if (showSidebar)
              const SizedBox(
                width: 260,
                child: _WebSidebar(active: _NavKey.stock),
              ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(showMenu: false, onRefresh: _refresh),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Breadcrumb(),
                          const SizedBox(height: 12),
                          FutureBuilder<List<StockCategory>>(
                            future: _categoriesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const _TableCard(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return const _TableCard(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('Kategoriler yüklenemedi'),
                                  ),
                                );
                              }
                              final categories = snapshot.data ?? [];
                              final selectedCategoryName = categories
                                  .firstWhere(
                                      (c) => c.id == _selectedCategoryId,
                                      orElse: () =>
                                          StockCategory(id: '', name: ''))
                                  .name;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Stok Yönetimi',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              'Stok kalemlerini yönetin ve izleyin',
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
                                            label: 'Kategori Ekle',
                                            icon: Icons.add_circle_outline,
                                            onPressed: _showAddCategoryDialog,
                                          ),
                                          const SizedBox(width: 10),
                                          _PrimaryActionButton(
                                            label: 'Stok Ekle',
                                            icon: Icons.add,
                                            onPressed: () =>
                                                _showAddItemDialog(categories),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _CategoryGrid(
                                    categories: categories,
                                    selectedCategoryId: _selectedCategoryId,
                                    onSelect: (id) {
                                      setState(() {
                                        _selectedCategoryId = id;
                                        _itemsFuture =
                                            _stockService.listItemsByCategory(
                                                id);
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  if (_selectedCategoryId == null)
                                    FutureBuilder<List<StockItem>>(
                                      future: _allItemsFuture,
                                      builder: (context, itemsSnap) {
                                        if (itemsSnap.connectionState ==
                                            ConnectionState.waiting) {
                                          return const _TableCard(
                                            child: Padding(
                                              padding: EdgeInsets.all(20),
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                          );
                                        }
                                        final allItems = itemsSnap.data ?? [];
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _CriticalPanel(
                                              items: allItems,
                                              title: 'Kritik Ürünler',
                                              onShowAll: () {},
                                            ),
                                            const SizedBox(height: 12),
                                            const _TableCard(
                                              child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Text(
                                                  'Ürünleri görmek için kategori seçin',
                                                  style: TextStyle(
                                                      color:
                                                          Color(0xFF94A3B8)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  else
                                    _CategoryItemsSection(
                                      itemsFuture: _itemsFuture!,
                                      onRefresh: _refresh,
                                      categoryName: selectedCategoryName,
                                    ),
                                ],
                              );
                            },
                          ),
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

enum _NavKey { home, tickets, operations, team, customers, stock, other }

class _WebSidebar extends StatelessWidget {
  const _WebSidebar({this.compact = false, required this.active});

  final bool compact;
  final _NavKey active;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1E33), Color(0xFF0A1728)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/branding/logo.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                if (!compact)
                  const Text(
                    'Lineer Destek',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Ana Menü',
                  active: active == _NavKey.home,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebHomePage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Talepler',
                  active: active == _NavKey.tickets,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebTicketsPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Operasyonlar',
                  active: active == _NavKey.operations,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebOperationsPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.group_outlined,
                  label: 'Ekip Yönetimi',
                  active: active == _NavKey.team,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebTeamPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Müşteri Yönetimi',
                  active: active == _NavKey.customers,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebCustomersPage()),
                  ),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Stok Yönetimi',
                  active: active == _NavKey.stock,
                  onTap: () => Navigator.of(context).pushReplacement(
                    adminWebRoute(const AdminWebStockPage()),
                  ),
                ),
                const _NavItem(icon: Icons.payments_outlined, label: 'Finans'),
                const _NavItem(
                    icon: Icons.query_stats_rounded,
                    label: 'Analiz & Raporlar'),
                const _NavItem(icon: Icons.settings_outlined, label: 'Ayarlar'),
              ],
            ),
          ),
          _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF14263F),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Depolama',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.55,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1D3554),
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF60A5FA)),
                ),
              ),
              const SizedBox(height: 6),
              const Text('4.88 GB / 8 GB',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9FB3C8))),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Depolama Ekle',
                      style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2C4469)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: const [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF1C2F4A),
                child: Text('ST',
                    style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Süleyman TÜY... \nTR',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9FB3C8)),
                ),
              ),
              Icon(Icons.logout, size: 18, color: Color(0xFF9FB3C8)),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1B3A5C) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF9FB3C8)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : const Color(0xFF9FB3C8),
                )),
            const Spacer(),
            if (!active)
              const Icon(Icons.expand_more,
                  size: 14, color: Color(0xFF7B8FA8)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showMenu, required this.onRefresh});

  final bool showMenu;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          const Spacer(),
          _SecondaryActionButton(
            label: 'Yenile',
            icon: Icons.refresh,
            onPressed: onRefresh,
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              children: const [
                Text('TR', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(width: 6),
                Icon(Icons.expand_more, size: 16),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.wb_sunny_outlined, color: Color(0xFF64748B)),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE2E8F0),
            child: Text('ST', style: TextStyle(fontSize: 11)),
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
        Text('Stok Yönetimi',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.items});

  final List<StockItem> items;

  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final available =
        items.fold<int>(0, (sum, e) => sum + e.quantityAvailable);
    final reserved =
        items.fold<int>(0, (sum, e) => sum + e.quantityReserved);
    final lowStock = items.where((e) => e.quantityAvailable < 5).length;

    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      padding: EdgeInsets.zero,
      children: [
        _MetricCard(
            title: 'Toplam Ürün',
            value: total.toString(),
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF3B82F6)),
        _MetricCard(
            title: 'Toplam Stok',
            value: available.toString(),
            icon: Icons.layers_outlined,
            color: const Color(0xFF22C55E)),
        _MetricCard(
            title: 'Rezerve',
            value: reserved.toString(),
            icon: Icons.bookmark_border,
            color: const Color(0xFFF59E0B)),
        _MetricCard(
            title: 'Kritik Seviye',
            value: lowStock.toString(),
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFEF4444)),
      ],
    );
  }
}

class _CriticalPanel extends StatelessWidget {
  const _CriticalPanel(
      {required this.items, required this.title, required this.onShowAll});

  final List<StockItem> items;
  final String title;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final criticalItems =
        items.where((e) => e.quantityAvailable < 5).toList();
    criticalItems.sort((a, b) =>
        a.quantityAvailable.compareTo(b.quantityAvailable));
    final top = criticalItems.take(5).toList();
    return _TableCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const Spacer(),
                TextButton(
                  onPressed: onShowAll,
                  child: const Text('Tümü'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (top.isEmpty)
              const Text('Kritik seviyede ürün yok',
                  style: TextStyle(color: Color(0xFF94A3B8)))
            else
              Column(
                children: [
                  for (final item in top)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.warning_amber_rounded,
                                size: 16, color: Color(0xFFEF4444)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(item.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ),
                          Text('${item.quantityAvailable}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
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

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                SizedBox(width: 8),
                Text('Ara', style: TextStyle(color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _DropdownPill(label: 'Durum'),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Yenile'),
        ),
      ],
    );
  }
}

class _DropdownPill extends StatelessWidget {
  const _DropdownPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF475569), fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          const Icon(Icons.expand_more, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  final List<StockCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const _TableCard(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Kategori bulunamadı',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategoriler',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.2,
          children: [
            for (final cat in categories)
              _CategoryCard(
                label: cat.name,
                selected: selectedCategoryId == cat.id,
                onTap: () => onSelect(cat.id),
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFDBEAFE)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.inventory_2_outlined,
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                  size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      selected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _CategoryItemsSection extends StatelessWidget {
  const _CategoryItemsSection(
      {required this.itemsFuture,
      required this.onRefresh,
      required this.categoryName});

  final Future<List<StockItem>> itemsFuture;
  final VoidCallback onRefresh;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StockItem>>(
      future: itemsFuture,
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
              child: Text('Stok yüklenemedi'),
            ),
          );
        }
        final items = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CriticalPanel(
              items: items,
              title: categoryName.isEmpty
                  ? 'Kritik Ürünler'
                  : 'Kritik Ürünler · $categoryName',
              onShowAll: () {},
            ),
            const SizedBox(height: 16),
            _MetricRow(items: items),
            const SizedBox(height: 16),
            _FilterRow(onRefresh: onRefresh),
            const SizedBox(height: 12),
            _StockTableCard(items: items),
          ],
        );
      },
    );
  }
}

class _StockTableCard extends StatelessWidget {
  const _StockTableCard({required this.items});

  final List<StockItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _TableCard(
        child: Padding(
          padding: EdgeInsets.all(20),
          child:
              Text('Kayıt bulunamadı', style: TextStyle(color: Color(0xFF94A3B8))),
        ),
      );
    }
    return _TableCard(
      child: Column(
        children: [
          const _TableHeader(),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          for (final item in items) _TableRow(item: item),
        ],
      ),
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
      'SKU',
      'Ürün',
      'Kategori',
      'Barkod',
      'Stok',
      'Rezerve',
      'Birim',
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
  const _TableRow({required this.item});

  final StockItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(item.sku)),
          Expanded(
            child: Text(item.name, overflow: TextOverflow.ellipsis),
          ),
          Expanded(child: Text(item.categoryName ?? '-')),
          Expanded(child: Text(item.barcode)),
          Expanded(child: Text(item.quantityAvailable.toString())),
          Expanded(child: Text(item.quantityReserved.toString())),
          Expanded(child: Text(item.unit ?? '-')),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.controller,
    this.requiredField = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool requiredField;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: requiredField
          ? (val) => (val == null || val.trim().isEmpty) ? 'Zorunlu' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
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
