import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  });

  final AdminNavKey active;
  final Widget body;
  final List<Widget> actions;

  /// Chat gibi tam ekran uygulamalarda false yapılır; body kendi
  /// kaydırmasını yönetir.
  final bool scrollable;

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
            : Drawer(
                child: AdminWebSidebar(
                  compact: true,
                  active: active,
                  radius: 0,
                ),
              ),
        body: Row(
          children: [
            if (showSidebar) AdminWebSidebarPanel(active: active),
            Expanded(
              child: Column(
                children: [
                  AdminWebTopBar(showMenu: false, actions: actions),
                  Expanded(
                    child: scrollable
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                            child: body,
                          )
                        : body,
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
