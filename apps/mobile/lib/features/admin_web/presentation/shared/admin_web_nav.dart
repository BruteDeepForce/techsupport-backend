import 'package:flutter/material.dart';

import '../admin_web_customers_page.dart';
import '../admin_web_device_page.dart';
import '../admin_web_home_page.dart';
import '../HR/hr_pages/admin_web_hr_page.dart';
import '../admin_web_trade_page.dart';
import '../admin_web_offer_detail_page.dart';
import '../admin_web_offers_page.dart';
import '../admin_web_operation_detail_page.dart';
import '../admin_web_operations_page.dart';
import '../admin_web_stock_page.dart';
import '../admin_web_team_page.dart';
import '../admin_web_ticket_detail_page.dart';
import '../admin_web_tickets_page.dart';
import '../admin_web_route.dart';
import '../../../quick_sale/presentation/admin_web_quick_sale_page.dart';

enum AdminNavKey {
  home,
  tickets,
  operations,
  quickSales,
  trades,
  offers,
  team,
  hr,
  customers,
  devices,
  stock
}

class AdminNavItem {
  const AdminNavItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.pageBuilder,
  });

  final AdminNavKey key;
  final String label;
  final IconData icon;
  final WidgetBuilder pageBuilder;
}

List<AdminNavItem> adminNavItems() {
  return [
    AdminNavItem(
      key: AdminNavKey.home,
      label: 'Ana Menü',
      icon: Icons.grid_view_rounded,
      pageBuilder: (_) => const AdminWebHomePage(),
    ),
    AdminNavItem(
      key: AdminNavKey.tickets,
      label: 'Talepler',
      icon: Icons.confirmation_number_outlined,
      pageBuilder: (_) => const AdminWebTicketsPage(),
    ),
    AdminNavItem(
      key: AdminNavKey.operations,
      label: 'Operasyonlar',
      icon: Icons.receipt_long_outlined,
      pageBuilder: (_) => const AdminWebOperationsPage(),
    ),
    AdminNavItem(
      key: AdminNavKey.quickSales,
      label: 'Hızlı Satış',
      icon: Icons.point_of_sale,
      pageBuilder: (_) => const AdminWebQuickSalePage(),
    ),
    AdminNavItem(
      key: AdminNavKey.trades,
      label: 'Hızlı Alış/Satış',
      icon: Icons.swap_horiz_outlined,
      pageBuilder: (_) => const AdminWebTradePage(),
    ),
    AdminNavItem(
      key: AdminNavKey.offers,
      label: 'Teklifler',
      icon: Icons.local_offer_outlined,
      pageBuilder: (_) => const AdminWebOffersPage(),
    ),
    AdminNavItem(
      key: AdminNavKey.team,
      label: 'Ekip Yönetimi',
      icon: Icons.group_outlined,
      pageBuilder: (_) => const AdminWebTeamPage(),
    ),
    AdminNavItem(
      key: AdminNavKey.hr,
      label: 'İnsan Kaynakları',
      icon: Icons.badge_outlined,
      pageBuilder: (_) => const AdminWebHrPage(),
    ),
    AdminNavItem(
      key: AdminNavKey.customers,
      label: 'Müşteri Yönetimi',
      icon: Icons.person_outline_rounded,
      pageBuilder: (_) => const AdminWebCustomersPage(),
    ),
    AdminNavItem(
      key: AdminNavKey.devices,
      label: 'Cihaz Takibi',
      icon: Icons.devices_other_outlined,
      pageBuilder: (_) => const AdminWebDevicePage(),
    ),
    AdminNavItem(
      key: AdminNavKey.stock,
      label: 'Stok Yönetimi',
      icon: Icons.inventory_2_outlined,
      pageBuilder: (_) => const AdminWebStockPage(),
    ),
  ];
}

PageRouteBuilder<void> adminNavRoute(Widget page) => adminWebRoute(page);
