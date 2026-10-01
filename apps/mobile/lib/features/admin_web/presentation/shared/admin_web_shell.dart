import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_web_design.dart';
import 'admin_web_nav.dart';
import 'admin_web_sidebar.dart';
import 'admin_web_topbar.dart';

class AdminWebShell extends StatelessWidget {
  const AdminWebShell({
    super.key,
    required this.active,
    required this.body,
    this.actions = const [],
    this.scrollable = true,
    this.dark = false,
    this.padding = const EdgeInsets.fromLTRB(24, 18, 24, 32),
  });

  final AdminNavKey active;
  final Widget body;
  final List<Widget> actions;

  /// Chat gibi tam ekran uygulamalarda false yapılır; body kendi
  /// kaydırmasını yönetir.
  final bool scrollable;

  /// true ise koyu teknolojik zemin (yumuşak ışıma) kullanılır.
  final bool dark;

  /// İçerik boşluğu. Veri tabloları gibi sayfalar kendi dolgusunu
  /// yönetmek istediğinde [EdgeInsets.zero] verilebilir.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showSidebar = width >= 1100;
    final baseTextTheme =
        GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme);
    final textTheme = baseTextTheme;

    Widget content = Row(
      children: [
        if (showSidebar) AdminWebSidebarPanel(active: active),
        Expanded(
          child: Column(
            children: [
              AdminWebTopBar(showMenu: false, actions: actions, dark: dark),
              Expanded(
                child: scrollable
                    ? SingleChildScrollView(
                        padding: padding,
                        child: body,
                      )
                    : body,
              ),
            ],
          ),
        ),
      ],
    );

    if (dark) {
      content = AdminTechBackdrop(child: content);
    }

    return Theme(
      data: dark
          ? buildAdminDarkTheme(textTheme)
          : Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor:
            dark ? AdminTechColors.canvas : const Color(0xFFF7F8FB),
        drawer: showSidebar
            ? null
            : Drawer(
                child: AdminWebSidebar(
                  compact: true,
                  active: active,
                  radius: 0,
                ),
              ),
        body: content,
      ),
    );
  }
}
