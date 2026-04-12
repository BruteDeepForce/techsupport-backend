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
  });

  final AdminNavKey active;
  final Widget body;
  final List<Widget> actions;

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
                child: AdminWebSidebar(compact: true, active: active),
              ),
        body: Row(
          children: [
            if (showSidebar)
              SizedBox(
                width: 260,
                child: AdminWebSidebar(active: active),
              ),
            Expanded(
              child: Column(
                children: [
                  AdminWebTopBar(showMenu: false, actions: actions),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                      child: body,
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

