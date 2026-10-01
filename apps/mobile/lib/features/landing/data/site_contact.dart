/// Landing (pazarlama) sitesinde kullanılan kurumsal iletişim bilgileri.
///
/// CTA butonlarında ve demo talep akışında tek kaynaktan okunur.
class SiteContact {
  const SiteContact._();

  static const String companyName = 'Lineer Destek';

  static const String salesEmail = 'info@cyber2tech.com';
  static const String supportEmail = 'destek@cyber2tech.com';
  static const String kvkkEmail = 'kvkk@cyber2tech.com';

  static String get salesMailto =>
      'mailto:$salesEmail?subject=${Uri.encodeComponent('Lineer Destek demo talebi')}';

  /// Demo talebi formu doldurulduğunda kullanılan, ön doldurulmuş e-posta.
  static String demoRequestMailto({
    required String fullName,
    required String company,
    required String email,
    required String phone,
    required String technicianCount,
    required String note,
  }) {
    final body = [
      'Merhaba,',
      '',
      'www.lineerdestek.com üzerinden demo talebi oluşturdum.',
      '',
      'Ad Soyad: $fullName',
      'Firma: $company',
      'E-posta: $email',
      'Telefon: $phone',
      'Teknisyen sayısı: $technicianCount',
      'Not: ${note.isEmpty ? '-' : note}',
    ].join('\n');

    return 'mailto:$salesEmail'
        '?subject=${Uri.encodeComponent('Demo talebi - $company')}'
        '&body=${Uri.encodeComponent(body)}';
  }
}
