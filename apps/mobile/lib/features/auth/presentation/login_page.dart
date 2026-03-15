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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Dark green used for primary sign-in button (matches reference)
    const signInColor = Color(0xFF073B2E);

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
                      // centered emblem / logo
                      Container(
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
                      const SizedBox(height: 48),

                      // username field
                      SizedBox(
                        width: formWidth,
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Kullanıcı Adı',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: AppColors.brandDark),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // password field
                      SizedBox(
                        width: formWidth,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: 'Şifre',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: AppColors.brandDark),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Sign in button
                      SizedBox(
                        width: formWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                  builder: (_) => const RoleSelectionPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: signInColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 6,
                            shadowColor: Colors.black26,
                          ),
                          child: Text('Giriş Yap',
                              style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextButton(
                        onPressed: () {},
                        child: Text('Şifremi Unuttum?',
                            style: theme.textTheme.bodyLarge),
                      ),

                      const SizedBox(height: 8),

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
