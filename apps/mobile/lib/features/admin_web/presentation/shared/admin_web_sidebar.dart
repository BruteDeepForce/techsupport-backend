import 'package:flutter/material.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../auth/data/token_storage.dart';
import 'admin_web_design.dart';
import 'admin_web_nav.dart';

/// Kenara yaslı sol navigasyon paneli. Kavisli köşelerin görünmesi için
/// çevresinde boşluk bırakır; tüm admin web sayfaları bu bileşeni kullanır.
class AdminWebSidebarPanel extends StatelessWidget {
  const AdminWebSidebarPanel({
    super.key,
    required this.active,
    this.width = 260,
    this.margin = const EdgeInsets.fromLTRB(7, 7, 0, 7),
    this.radius = 20,
  });

  final AdminNavKey active;
  final double width;
  final EdgeInsetsGeometry margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: SizedBox(
        width: width,
        child: AdminWebSidebar(active: active, radius: radius),
      ),
    );
  }
}

class AdminWebSidebar extends StatelessWidget {
  const AdminWebSidebar({
    super.key,
    required this.active,
    this.compact = false,
    this.radius = 20,
  });

  final AdminNavKey active;
  final bool compact;

  /// Panelin dört köşesine uygulanacak kavis yarıçapı. Tam ekran drawer
  /// içinde 0 kullanılır, kenara yaslanan panelde 20.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final items = adminNavItems();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1226), Color(0xFF060A16)],
          ),
        ),
        child: Stack(
          children: [
            // Üst köşede marka ışıması; panelin düz görünmesini kırar.
            Positioned(
              top: -120,
              left: -60,
              child: IgnorePointer(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AdminTechColors.indigo.withValues(alpha: 0.28),
                        AdminTechColors.indigo.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
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
                          gradient: AdminTechColors.accentGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AdminTechColors.cyan.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                      if (!compact) ...[
                        const Text(
                          'Lineer',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AdminTechColors.cyan.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color:
                                  AdminTechColors.cyan.withValues(alpha: 0.32),
                            ),
                          ),
                          child: Text(
                            'AI',
                            style: adminTechLabelStyle(
                              size: 9,
                              weight: FontWeight.w800,
                              color: AdminTechColors.cyan,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!compact)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'MODULLER',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: AdminTechColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
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
          ],
        ),
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
        child: InkWell(
          onTap: _logout,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x14FFFFFF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded,
                    size: 16, color: Color(0xFF9FB3C8)),
                const SizedBox(width: 8),
                Text(
                  'Oturumu Kapat',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9FB3C8).withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
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
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: highlight
              ? const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF22D3EE)],
                )
              : null,
          color: active && !highlight
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: active && !highlight
              ? Border.all(color: Colors.white.withValues(alpha: 0.10))
              : null,
          boxShadow: highlight
              ? const [
                  BoxShadow(
                    color: Color(0x594F46E5),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Aktif öğede sol kenar çubuğu; seçili kaydırma konumunu belirginleştirir.
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 3,
              height: 18,
              margin: const EdgeInsets.only(right: 9),
              decoration: BoxDecoration(
                color: (active || highlight)
                    ? (highlight ? Colors.white : AdminTechColors.cyan)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(icon,
                size: 17,
                color: highlight
                    ? Colors.white
                    : (active
                        ? AdminTechColors.cyan
                        : const Color(0xFF9FB3C8))),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: highlight
                      ? FontWeight.w700
                      : (active ? FontWeight.w600 : FontWeight.w500),
                  color: highlight
                      ? Colors.white
                      : (active ? Colors.white : const Color(0xFF9FB3C8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
