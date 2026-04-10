import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design/app_design.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/data/token_storage.dart';
import 'role_selection_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebLogin(context);
    }

    final theme = Theme.of(context);
    final _authService = AuthService();
    final _tokenStorage = TokenStorage();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            // ── Background Glow ──────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.05),
                      AppColors.bg.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Logo Area ───────────────────────────────────
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          border:
                              Border.all(color: AppColors.border, width: 0.5),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const LinearLogo(size: 64),
                      ),
                      const SizedBox(height: 24),
                      Text('Lineer Destek',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.0,
                          )),
                      const SizedBox(height: 8),
                      Text('Servis Operasyonlarına Giriş Yap',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 0,
                          )),
                      const SizedBox(height: 48),

                      // ── SaaS Standard Card ──────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('E-posta Adresi',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            _SaaSInput(
                              focusNode: _usernameFocus,
                              controller: _usernameController,
                              hint: 'eposta@adresiniz.com',
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_passwordFocus),
                            ),
                            const SizedBox(height: 20),
                            Text('Şifre',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            _SaaSInput(
                              focusNode: _passwordFocus,
                              controller: _passwordController,
                              obscureText: _obscure,
                              hint: '••••••••',
                              textInputAction: TextInputAction.done,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textTertiary,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Primary button
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () async {
                                final email = _usernameController.text.trim();
                                final password = _passwordController.text;
                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Lütfen e-posta ve şifre girin')));
                                  return;
                                }

                                showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                      child: CircularProgressIndicator()),
                                );

                                try {
                                  final token =
                                      await _authService.login(email, password);
                                  await _tokenStorage.saveToken(token);

                                  // ApiClient already has a global auth interceptor.

                                  if (context.mounted) {
                                    Navigator.of(context)
                                        .pop(); // close loading
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const RoleSelectionPage()),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.of(context)
                                        .pop(); // close loading
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Giriş başarısız: ${e.toString()}')));
                                  }
                                }
                              },
                              child: const Text('Devam Et'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Şifrenizi mi unuttunuz?',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()),
                        ),
                        child: const Text('Hesap Oluştur'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLogin(BuildContext context) {
    final theme = Theme.of(context);
    final _authService = AuthService();
    final _tokenStorage = TokenStorage();

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
          Positioned(
            left: -120,
            bottom: -120,
            child: _GlowBlob(
              size: 320,
              colors: const [Color(0x66256CE8), Color(0x00000000)],
            ),
          ),
          Positioned(
            right: -160,
            top: -140,
            child: _GlowBlob(
              size: 360,
              colors: const [Color(0x6622D3EE), Color(0x00000000)],
            ),
          ),
          Positioned(
            right: 120,
            bottom: 80,
            child: _GlowBlob(
              size: 220,
              colors: const [Color(0x5538BDF8), Color(0x00000000)],
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isNarrow ? 520 : 980),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: isNarrow
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lineer Destek',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Uçtan Uca Operasyon Merkezi Giriş Sayfası.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: const Color(0xFF8FB6F3),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _LoginCard(
                                authService: _authService,
                                tokenStorage: _tokenStorage,
                                emailController: _usernameController,
                                passwordController: _passwordController,
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lineer Destek',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Uçtan Uca Operasyon Merkezi Giriş Sayfası.',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          height: 1.5,
                                          color: const Color(0xFF8FB6F3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 0),
                              Expanded(
                                flex: 5,
                                child: SizedBox(
                                  height: double.infinity,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: _LoginCard(
                                      authService: _authService,
                                      tokenStorage: _tokenStorage,
                                      emailController: _usernameController,
                                      passwordController: _passwordController,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.authService,
    required this.tokenStorage,
    required this.emailController,
    required this.passwordController,
  });

  final AuthService authService;
  final TokenStorage tokenStorage;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 460,
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0B4BA8).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C7BEF), width: 1),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WebField(
            label: 'E-posta',
            controller: emailController,
            hint: 'ornek@firma.com',
          ),
          const SizedBox(height: 12),
          _WebField(
            label: 'Şifre',
            controller: passwordController,
            hint: 'Şifre',
            obscureText: true,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F3F8C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text;
                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Lütfen e-posta ve şifre girin')));
                  return;
                }

                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  final token = await authService.login(email, password);
                  await tokenStorage.saveToken(token);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                          builder: (_) => const RoleSelectionPage()),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Giriş başarısız: ${e.toString()}'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Giriş Yap'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebField extends StatelessWidget {
  const _WebField({
    required this.label,
    required this.controller,
    required this.hint,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB7D4FF))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SaaSInput extends StatelessWidget {
  const _SaaSInput({
    required this.focusNode,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
        filled: true,
        fillColor: AppColors.bgSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
    );
  }
}
