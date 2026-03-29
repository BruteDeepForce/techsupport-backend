import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/auth_interceptor.dart';
import '../data/auth_service.dart';
import '../data/token_storage.dart';
import 'role_selection_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tenantNameController = TextEditingController();
  String _selectedRole = 'customer';

  final _authService = AuthService();
  final _tokenStorage = TokenStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tenantNameController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final tenantName = _tenantNameController.text.trim();

    if (email.isEmpty || password.isEmpty || tenantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }

    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final token = await _authService.register(
          email, password, _selectedRole, tenantName);
      await _tokenStorage.saveToken(token);
      ApiClient().dio.interceptors.add(AuthInterceptor(_tokenStorage.getToken));

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const RoleSelectionPage()));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kayıt başarısız: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hesap Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tenantNameController,
              decoration: const InputDecoration(labelText: 'Firma Adı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'customer', child: Text('Müşteri')),
                DropdownMenuItem(value: 'technician', child: Text('Teknisyen')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v ?? 'customer'),
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _createAccount, child: const Text('Kayıt Ol')),
          ],
        ),
      ),
    );
  }
}
