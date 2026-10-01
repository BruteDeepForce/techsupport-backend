import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/design/app_design.dart';
import '../../data/site_contact.dart';

/// "Demo Talep Et" butonlarının açtığı form.
///
/// Bilgileri e-posta istemcisinde ön doldurulmuş bir talep olarak açar;
/// backend'de henüz bir demo-lead uç noktası yok, bu yüzden sunucuya
/// veri gönderilmez ve kullanıcı göndermeden önce içeriği görebilir.
class DemoRequestDialog extends StatefulWidget {
  const DemoRequestDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const DemoRequestDialog(),
    );
  }

  @override
  State<DemoRequestDialog> createState() => _DemoRequestDialogState();
}

class _DemoRequestDialogState extends State<DemoRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  String _technicianCount = '1-5';
  bool _sending = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final uri = Uri.parse(
      SiteContact.demoRequestMailto(
        fullName: _fullNameController.text.trim(),
        company: _companyController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        technicianCount: _technicianCount,
        note: _noteController.text.trim(),
      ),
    );

    setState(() => _sending = true);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted) return;
    setState(() => _sending = false);

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'E-posta uygulaması açılamadı. ${SiteContact.salesEmail} adresine yazabilirsiniz.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo talebiniz için e-posta hazırlandı.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ücretsiz Demo Talebi',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bilgilerinizi girin, talebiniz e-posta olarak hazırlansın. Ekibimiz en kısa sürede dönüş yapar.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _field(_fullNameController, 'Ad Soyad', Icons.person_outline_rounded,
                    requiredField: true),
                const SizedBox(height: 12),
                _field(_companyController, 'Firma Ünvanı', Icons.business_outlined,
                    requiredField: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                          _emailController, 'E-posta', Icons.alternate_email_rounded,
                          requiredField: true, keyboardType: TextInputType.emailAddress),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_phoneController, 'Telefon', Icons.phone_rounded,
                          keyboardType: TextInputType.phone),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _technicianCount,
                  decoration: _decoration('Teknisyen Sayısı'),
                  items: const [
                    '1-5',
                    '6-15',
                    '16-40',
                    '41-100',
                    '100+',
                  ]
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _technicianCount = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _field(_noteController, 'Eksik notunuz varsa yazın', Icons.notes_rounded,
                    maxLines: 3),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Bilgileriniz yalnızca talebinizin değerlendirilmesi için kullanılır.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _sending ? null : () => Navigator.of(context).pop(),
                      child: const Text('Vazgeç'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: Text(_sending ? 'Hazırlanıyor' : 'Talebi Gönder'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isCompact) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(SiteContact.salesMailto),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.mail_outline_rounded, size: 16),
                      label: Text('E-posta ile yaz: ${SiteContact.salesEmail}'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool requiredField = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _decoration(label),
      validator: requiredField
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label alanı zorunludur';
              }
              if (label == 'E-posta' && !value.contains('@')) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            }
          : null,
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
    );
  }
}

/// Hangi butona basıldığına göre demo formunu ya da doğrudan e-posta/telefon
/// uygulamasını açar.
class LandingActions {
  const LandingActions._();

  static Future<void> demoRequest(BuildContext context) async {
    await DemoRequestDialog.show(context);
  }

  static Future<void> talkToSales(BuildContext context) async {
    final uri = Uri.parse(SiteContact.salesMailto);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('E-posta uygulaması açılamadı: ${SiteContact.salesEmail}'),
      ),
    );
  }
}
