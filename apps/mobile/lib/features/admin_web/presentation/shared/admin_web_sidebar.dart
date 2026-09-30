import 'package:flutter/material.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../auth/data/token_storage.dart';
import 'admin_web_nav.dart';

class AdminWebSidebar extends StatelessWidget {
  const AdminWebSidebar({
    super.key,
    required this.active,
    this.compact = false,
  });

  final AdminNavKey active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = adminNavItems();
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
            child: Scrollbar(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final item in items)
                    if (item.key == AdminNavKey.aiChat)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0x1A9FB3C8),
                        ),
                      ),
                  for (final item in items)
                    _NavItem(
                      icon: item.icon,
                      label: item.label,
                      active: active == item.key,
                      highlight: item.key == AdminNavKey.aiChat,
                      onTap: () => Navigator.of(context).pushReplacement(
                        adminNavRoute(item.pageBuilder(context)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  /// Oturumu kapatır: saklanan token silinir ve kullanıcı doğrudan
  /// giriş ekranına yönlendirilir (onay adımı yok).
  Future<void> _logout() async {
    await TokenStorage().clear();
    redirectToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: _logout,
          tooltip: 'Çıkış Yap',
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 38, height: 38),
          color: const Color(0xFF9FB3C8),
          icon: const Icon(Icons.logout_rounded),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.highlight = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool highlight;
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
          gradient: highlight
              ? const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6D5CE7)],
                )
              : null,
          color: active && !highlight
              ? const Color(0xFF1B3A5C)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: highlight
              ? const [
                  BoxShadow(
                    color: Color(0x594F46E5),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: highlight
                    ? Colors.white
                    : const Color(0xFF9FB3C8)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: highlight
                      ? FontWeight.w600
                      : (active ? FontWeight.w600 : FontWeight.w500),
                  color: highlight
                      ? Colors.white
                      : (active ? Colors.white : const Color(0xFF9FB3C8)),
                )),
          ],
        ),
      ),
    );
  }
}
