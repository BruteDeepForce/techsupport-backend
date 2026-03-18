import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../auth/presentation/login_page.dart'; // typically for logout

import 'admin_home_page.dart';
import 'admin_tickets_page.dart';
import 'admin_devices_page.dart';
import 'admin_team_page.dart';
import 'admin_work_orders_page.dart';

class InventoryManagementPage extends StatefulWidget {
  const InventoryManagementPage({super.key});

  @override
  State<InventoryManagementPage> createState() => _InventoryManagementPageState();
}

class _InventoryManagementPageState extends State<InventoryManagementPage> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> _allInventory = [
    {'id': 'GPU-001', 'title': 'NVIDIA RTX 4090', 'category': 'Ekran Kartı', 'stock': 3, 'statusColor': AppColors.statusYellow, 'isCritical': true},
    {'id': 'GPU-002', 'title': 'AMD Radeon RX 7900 XTX', 'category': 'Ekran Kartı', 'stock': 5, 'statusColor': AppColors.statusGreen},
    {'id': 'GPU-003', 'title': 'RTX 3060 Ti', 'category': 'Ekran Kartı', 'stock': 12, 'statusColor': AppColors.statusGreen},
    
    {'id': 'LAP-001', 'title': 'MacBook Pro 16" M3 Max', 'category': 'Laptop', 'stock': 12, 'statusColor': AppColors.statusGreen},
    {'id': 'LAP-002', 'title': 'Dell XPS 15 9530', 'category': 'Laptop', 'stock': 0, 'statusColor': AppColors.statusGray, 'label': 'Sipariş Edildi', 'labelColor': AppColors.statusBlue},
    {'id': 'LAP-003', 'title': 'ASUS ROG Zephyrus G14', 'category': 'Laptop', 'stock': 4, 'statusColor': AppColors.statusYellow},

    {'id': 'CPU-001', 'title': 'Intel Core i9-14900K', 'category': 'İşlemci', 'stock': 8, 'statusColor': AppColors.statusGreen},
    {'id': 'CPU-002', 'title': 'AMD Ryzen 9 7950X3D', 'category': 'İşlemci', 'stock': 2, 'statusColor': AppColors.statusRed, 'isCritical': true},
    {'id': 'CPU-003', 'title': 'Intel Core i5-13600K', 'category': 'İşlemci', 'stock': 15, 'statusColor': AppColors.statusGreen},

    {'id': 'MISC-001', 'title': 'Logitech MX Master 3S', 'category': 'Diğer', 'stock': 25, 'statusColor': AppColors.statusGreen},
    {'id': 'MISC-002', 'title': 'Keychron Q1 Wireless', 'category': 'Diğer', 'stock': 6, 'statusColor': AppColors.statusGreen},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredItems = _selectedCategory == null 
      ? [] 
      : _allInventory.where((item) => item['category'] == _selectedCategory).toList();

    return LinearPageShell(
      title: _selectedCategory ?? 'Stok Yönetimi',
      subtitle: _selectedCategory == null ? 'Admin Portal' : 'Kategori Filtresi',
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 18),
      ),
      tabBar: LinearTabBar(
        items: [
          LinearTabItem(
              icon: Icons.grid_view_rounded,
              label: 'Bakış',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminHomePage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
          LinearTabItem(
              icon: Icons.confirmation_number_outlined,
              label: 'Talep',
              count: 6,
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminTicketsPage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
          LinearTabItem(
              icon: Icons.assignment_rounded, 
              label: 'İş Emri',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminWorkOrdersPage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
          LinearTabItem(
              icon: Icons.devices_other_outlined, 
              label: 'Cihaz',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminDevicesPage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
          const LinearTabItem(icon: Icons.inventory_2_rounded, label: 'Stok', active: true),
          LinearTabItem(
              icon: Icons.group_outlined, 
              label: 'Ekip',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminTeamPage(),
                  transitionDuration: Duration.zero,
                ),
              ),
          ),
        ],
      ),
      children: [
        if (_selectedCategory == null) ...[
          // ── Inventory Overview ────────────────────────────────────
          LinearCard(
            padding: EdgeInsets.zero,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _MetricCell(value: '${_allInventory.length}', label: 'Toplam Parça', color: AppColors.textPrimary),
                  const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                  _MetricCell(value: '3', label: 'Kritik Seviye', color: AppColors.statusRed),
                  const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                  _MetricCell(value: '12', label: 'Yolda', color: AppColors.statusBlue),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const LinearSection(title: 'KATEGORİLER'),
          const SizedBox(height: 12),
          
          // ── Category Grid ─────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _CategoryCard(
                title: 'Ekran Kartı',
                icon: Icons.memory_rounded,
                count: _allInventory.where((e) => e['category'] == 'Ekran Kartı').length,
                onTap: () => setState(() => _selectedCategory = 'Ekran Kartı'),
              ),
              _CategoryCard(
                title: 'Laptop',
                icon: Icons.laptop_mac_rounded,
                count: _allInventory.where((e) => e['category'] == 'Laptop').length,
                onTap: () => setState(() => _selectedCategory = 'Laptop'),
              ),
              _CategoryCard(
                title: 'İşlemci',
                icon: Icons.developer_board_rounded,
                count: _allInventory.where((e) => e['category'] == 'İşlemci').length,
                onTap: () => setState(() => _selectedCategory = 'İşlemci'),
              ),
              _CategoryCard(
                title: 'Diğer',
                icon: Icons.more_horiz_rounded,
                count: _allInventory.where((e) => e['category'] == 'Diğer').length,
                onTap: () => setState(() => _selectedCategory = 'Diğer'),
              ),
            ],
          ),
        ] else ...[
          // ── Drill-down View ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedCategory = null),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.accent),
                    SizedBox(width: 6),
                    Text('Tüm Kategoriler', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${filteredItems.length} Ürün',
                  style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // ── Search & Actions ──────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Pota içinde ara...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: 12),
                          ),
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          cursorColor: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Inventory List ────────────────────────────────────────
          LinearCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: filteredItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _InventoryRow(
                  id: item['id'],
                  title: item['title'],
                  category: item['category'],
                  stock: item['stock'],
                  statusColor: item['statusColor'],
                  isCritical: item['isCritical'] ?? false,
                  label: item['label'],
                  labelColor: item['labelColor'],
                  showDivider: index != filteredItems.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accent, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count Çeşit',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
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

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({
    required this.id,
    required this.title,
    required this.category,
    required this.stock,
    required this.statusColor,
    this.isCritical = false,
    this.label,
    this.labelColor,
    this.showDivider = true,
  });

  final String id;
  final String title;
  final String category;
  final int stock;
  final Color statusColor;
  final bool isCritical;
  final String? label;
  final Color? labelColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: AppColors.borderSubtle, width: 1))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        id,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  $category',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (label != null && labelColor != null) ...[
              const SizedBox(width: 8),
              LinearBadge(label: label!, color: labelColor!),
            ],
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$stock',
                  style: TextStyle(
                    color: isCritical ? AppColors.statusRed : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Adet',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
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

