import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';

import '../data/auth_service.dart';
import '../data/token_storage.dart';
import 'role_selection_page.dart';

Future<void> _showRegisterFailedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Kayıt başarısız'),
      content: const Text('Bilgileri kontrol edip tekrar deneyin.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tenantNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  String _selectedRole = 'customer';

  final _authService = AuthService();
  final _tokenStorage = TokenStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _tenantNameController.dispose();
    _branchNameController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final userName = _userNameController.text.trim();
    final password = _passwordController.text;
    final tenantName = _tenantNameController.text.trim();
    final branchName = _branchNameController.text.trim();

    if (email.isEmpty || userName.isEmpty || password.isEmpty || tenantName.isEmpty) {
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
        email,
        userName,
        password,
        _selectedRole,
        tenantName,
        branchName: branchName.isEmpty ? null : branchName,
      );
      await _tokenStorage.saveToken(token);

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const RoleSelectionPage()));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        await _showRegisterFailedDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebRegister(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hesap Oluştur')),
      body: SingleChildScrollView(
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
              controller: _branchNameController,
              decoration: const InputDecoration(
                labelText: 'Şube Adı',
                helperText: 'Boş bırakılırsa Merkez olarak oluşturulur',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
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

  Widget _buildWebRegister(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0B3B91), Color(0xFF0A6EEA)],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4BA8).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2C7BEF)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 40,
                        offset: Offset(0, 24),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hesap Oluştur',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Firma ve şube bilgilerinizi girerek çalışma alanınızı başlatın.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          height: 1.45,
                          color: const Color(0xFFB7D4FF),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _WebRegisterField(
                        label: 'Firma Adı',
                        controller: _tenantNameController,
                        hint: 'Firma adı',
                      ),
                      const SizedBox(height: 12),
                      _WebRegisterField(
                        label: 'Şube Adı',
                        controller: _branchNameController,
                        hint: 'Boş bırakılırsa Merkez',
                      ),
                      const SizedBox(height: 12),
                      _WebRegisterField(
                        label: 'E-posta',
                        controller: _emailController,
                        hint: 'ornek@firma.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _WebRegisterField(
                        label: 'Kullanıcı Adı',
                        controller: _userNameController,
                        hint: 'kullaniciadi',
                      ),
                      const SizedBox(height: 12),
                      _WebRegisterField(
                        label: 'Şifre',
                        controller: _passwordController,
                        hint: 'Şifre',
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        dropdownColor: Colors.white,
                        items: const [
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(
                              value: 'customer', child: Text('Müşteri')),
                          DropdownMenuItem(
                              value: 'technician', child: Text('Teknisyen')),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedRole = v ?? 'customer'),
                        decoration: _webInputDecoration('Rol'),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3F8C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Kayıt Ol'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Giriş ekranına dön',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebRegisterField extends StatelessWidget {
  const _WebRegisterField({
    required this.label,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: _webInputDecoration(label).copyWith(hintText: hint),
    );
  }
}

InputDecoration _webInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF334155)),
    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
