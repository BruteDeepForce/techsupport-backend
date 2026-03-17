import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import 'role_selection_page.dart';

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
  bool _hasFocus = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(_updateFocus);
    _passwordFocus.addListener(_updateFocus);
  }

  void _updateFocus() {
    final has = _usernameFocus.hasFocus || _passwordFocus.hasFocus;
    if (has != _hasFocus) setState(() => _hasFocus = has);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final formWidth = maxWidth > 420 ? 420.0 : maxWidth * 0.94;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),
                      // animated emblem / logo
                      AnimatedScale(
                        scale: _hasFocus ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.border, width: 1.2),
                            boxShadow: AppShadows.card,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'T',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900, fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // form card wrapper
                      AppSurfaceCard(
                        minHeight: null,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 22),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // username field
                            SizedBox(
                              width: formWidth - 40,
                              child: TextFormField(
                                focusNode: _usernameFocus,
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                    hintText: 'Kullanıcı Adı'),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_passwordFocus),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // password field
                            SizedBox(
                              width: formWidth - 40,
                              child: TextFormField(
                                focusNode: _passwordFocus,
                                controller: _passwordController,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  hintText: 'Şifre',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Sign in button (use FilledButton to pick up theme)
                            SizedBox(
                              width: formWidth - 40,
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const RoleSelectionPage()),
                                  );
                                },
                                child: Text('Giriş Yap',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),

                            const SizedBox(height: 12),

                            TextButton(
                              onPressed: () {},
                              child: Text('Şifremi Unuttum?',
                                  style: theme.textTheme.bodyLarge),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
