import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/app_design.dart';
import '../data/auth_service.dart';
import '../data/token_storage.dart';
import 'role_selection_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  late final TextEditingController _emailController;
  final _authService = AuthService();
  final _tokenStorage = TokenStorage();

  bool _codeRequested = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_codeRequested && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await _authService.requestPasswordResetCode(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _codeRequested = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'E-posta kayıtlıysa sıfırlama kodu gönderildi.',
          ),
        ),
      );
    } catch (_) {
      if (mounted) _showError('İstek gönderilemedi. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final token = await _authService.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );
      await _tokenStorage.saveToken(token);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const RoleSelectionPage()),
        (route) => false,
      );
    } on DioException catch (error) {
      if (!mounted) return;
      final data = error.response?.data;
      final errors = data is Map<String, dynamic> ? data['errors'] : null;
      final message = errors is List && errors.isNotEmpty
          ? errors.join('\n')
          : 'Kod geçersiz veya süresi dolmuş.';
      _showError(message);
    } catch (_) {
      if (mounted) _showError('Parola değiştirilemedi. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Şifremi unuttum'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _codeRequested ? 'Kodu doğrula' : 'Şifrenizi yenileyin',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _codeRequested
                ? 'E-postanıza gönderilen 6 haneli kodu ve yeni şifrenizi girin.'
                : 'Hesabınıza kayıtlı e-posta adresini girin.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            enabled: !_codeRequested && !_submitting,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'E-posta'),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty || !email.contains('@')) {
                return 'Geçerli bir e-posta adresi girin.';
              }
              return null;
            },
          ),
          if (_codeRequested) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '6 haneli kod',
                counterText: '',
              ),
              validator: (value) =>
                  value?.length == 6 ? null : '6 haneli kodu eksiksiz girin.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: const InputDecoration(labelText: 'Yeni şifre'),
              validator: (value) => (value?.length ?? 0) < 6
                  ? 'Şifre en az 6 karakter olmalı.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordConfirmationController,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: const InputDecoration(labelText: 'Yeni şifre tekrar'),
              validator: (value) => value == _passwordController.text
                  ? null
                  : 'Şifreler eşleşmiyor.',
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting
                ? null
                : (_codeRequested ? _resetPassword : _requestCode),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_codeRequested ? 'Şifreyi değiştir' : 'Kod gönder'),
          ),
          if (_codeRequested)
            TextButton(
              onPressed: _submitting ? null : _requestCode,
              child: const Text('Kodu yeniden gönder'),
            ),
        ],
      ),
    );
  }
}
