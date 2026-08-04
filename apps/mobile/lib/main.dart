import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/landing/presentation/landing_page.dart';
import 'features/quicksale/presentation/quicksale_dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TechSupportMobileApp());
}

class TechSupportMobileApp extends StatelessWidget {
  const TechSupportMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // On web show the marketing/landing homepage. On mobile keep the
      // existing login flow as the app entrypoint.
      home: kIsWeb ? const QuickSaleDashboardPage() : const LoginPage(),
    );
  }
}
