import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';

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
      home: const LoginPage(),
    );
  }
}
