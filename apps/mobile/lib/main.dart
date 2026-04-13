import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/landing/presentation/landing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TechSupportMobileApp());
}

class TechSupportMobileApp extends StatelessWidget {
  const TechSupportMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routes: {
        '/login': (_) => const LoginPage(),
        '/landing': (_) => const LandingPage(),
      },
      // On web show the marketing/landing homepage. On mobile keep the
      // existing login flow as the app entrypoint.
      home: kIsWeb ? const LandingPage() : const LoginPage(),
    );
  }
}
