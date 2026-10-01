import 'package:flutter/material.dart';

import '../../../../core/design/app_design.dart';
import '../../data/site_contact.dart';

/// Pazarlama sitesinde footer ve menüden açılan yasal metin sayfaları.
enum LegalDocument { kvkk, privacy, terms, cookies }

extension LegalDocumentX on LegalDocument {
  String get title => switch (this) {
        LegalDocument.kvkk => 'Kişisel Verilerin Korunması (KVKK)',
        LegalDocument.privacy => 'Gizlilik Politikası',
        LegalDocument.terms => 'Kullanım Şartları',
        LegalDocument.cookies => 'Çerez Politikası',
      };

  String get routePath => switch (this) {
        LegalDocument.kvkk => '/kvkk',
        LegalDocument.privacy => '/gizlilik',
        LegalDocument.terms => '/kullanim-sartlari',
        LegalDocument.cookies => '/cerez-politikasi',
      };

  static LegalDocument? fromPath(String path) {
    for (final document in LegalDocument.values) {
      if (document.routePath == path) return document;
    }
    return null;
  }
}

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        title: Text(
          document.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/landing');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 32 : 64,
          horizontal: isCompact ? 20 : 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bu metin örnek şablon niteliğindedir. Yayına almadan önce '
                          '${SiteContact.companyName} tarafından gerçek veri sorumlusu '
                          'bilgileri, işleme amaçları ve saklama süreleri ile '
                          'güncellenmelidir.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Son güncelleme: 1 Ocak 2026',
                  style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 24),
                ..._sectionsFor(document).map(
                  (section) => _LegalSection(
                    heading: section.$1,
                    paragraphs: section.$2,
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                Text(
                  'KVKK başvurularınız için: ${SiteContact.kvkkEmail}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<(String, List<String>)> _sectionsFor(LegalDocument document) {
    return switch (document) {
      LegalDocument.kvkk => const [
          (
            '1. Veri Sorumlusu',
            [
              'Lineer Destek, 6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında veri sorumlusu sıfatını haizdir.',
              'Veri sorumlusu iletişim bilgileri: Lineer Destek, Aydınlıkevler Mah. Sokak No:1, Çankaya / Ankara.',
              'Veri sorumlularına ulaşmak için kvkk@lineerdestek.com adresine yazabilirsiniz.',
            ],
          ),
          (
            '2. İşlenen Kişisel Veriler',
            [
              'Hesap ve kimlik bilgileri: ad, soyad, e-posta adresi, telefon numarası, kurum bilgileri.',
              'Sözleşme bilgileri: abonelik paketi, fatura adresi, ödeme kayıtları.',
              'Kullanım bilgileri: sisteme giriş kayıtları, iş emri hareketleri, cihaz ve konum bilgileri.',
              'Teknik bilgiler: IP adresi, tarayıcı ve cihaz bilgisi, çerez kayıtları.',
            ],
          ),
          (
            '3. İşleme Amaçları',
            [
              'Hesabın oluşturulması, kimlik doğrulama ve yetkilendirme işlemlerinin yürütülmesi.',
              'Teknik servis taleplerinin, iş emirlerinin ve saha operasyonlarının yönetilmesi.',
              'Faturalandırma, tahsilat ve muhasebe işlemlerinin gerçekleştirilmesi.',
              'Hizmet kalitesinin ölçülmesi, hata analizi ve sistem güvenliğinin sağlanması.',
              'Yasal yükümlülüklerin yerine getirilmesi ve mevzuatta öngörülen saklama yükümlülükleri.',
            ],
          ),
          (
            '4. Hukuki Sebep',
            [
              'Kişisel veriler; yürürlükteki mevzuatta yer alan kanuni yükümlülüklerin yerine getirilmesi, sözleşmenin kurulması veya ifasıyla doğrudan doğruya ilgili olması, meşru menfaat ve hukuki sebep dayanılarak işlenmektedir.',
            ],
          ),
          (
            '5. Aktarım',
            [
              'Veriler; bulut altyapısı, ödeme kuruluşları, elektronik posta ve mesajlaşma sağlayıcıları gibi hizmet aldığımız firmalarla yalnızca veri işleme amacıyla paylaşılabilir.',
              'Yasal olarak zorunlu hallerde yetkili kamu kurumlarıyla paylaşım yapılabilir.',
              'Verileriniz yurt dışına aktarılırken ilgili mevzuat hükümlerine uygun güvence mekanizmaları devreye alınır.',
            ],
          ),
          (
            '6. Saklama Süresi',
            [
              'Kişisel veriler, işleme amacının gerektirdiği süre boyunca ve ilgili mevzuatta öngörülen zamanaşımı süreleri sonuna kadar saklanır.',
              'Saklama süresi dolan veriler silinir, yok edilir veya anonim hale getirilir.',
            ],
          ),
          (
            '7. İlgili Kişinin Hakları',
            [
              'Kanunun 11. maddesi uyarınca; verilerinizin işlenip işlenmediğini öğrenme, bilgi talep etme, düzeltilmesini veya silinmesini isteme ve işlemenin sınırlandırılmasını talep etme haklarına sahipsiniz.',
              'Taleplerinizi ${SiteContact.kvkkEmail} adresine iletebilirsiniz. Başvurunuz en geç 30 gün içinde sonuçlandırılır.',
            ],
          ),
        ],
      LegalDocument.privacy => const [
          (
            '1. Toplanan Bilgiler',
            [
              'Kayıt olurken verdiğiniz ad, soyad, e-posta, telefon ve kurum bilgileri toplanır.',
              'Hizmet kullanımı sırasında oluşan iş emeri, cihaz, stok ve operasyon kayıtları işlenir.',
              'Hizmeti ölçmek ve güvenliği sağlamak için teknik loglar toplanır.',
            ],
          ),
          (
            '2. Bilgilerin Kullanımı',
            [
              'Bilgiler yalnızca hizmetin sunulması, destek verilmesi ve hizmetin iyileştirilmesi amacıyla kullanılır.',
              'Onayınız olmadan pazarlama amaçlı iletişim gönderilmez.',
            ],
          ),
          (
            '3. Üçüncü Taraflarla Paylaşım',
            [
              'Bilgileriniz, hizmetin sunulması için gerekli tedarikçiler dışında üçüncü taraflarla paylaşılmaz.',
              'Yasal zorunluluk hallerinde yetkili kurumlarla paylaşım yapılabilir.',
            ],
          ),
          (
            '4. Güvenlik',
            [
              'Veriler TLS şifreleme ile iletilir, veri tabanında yetkili erişimiyle saklanır.',
              'Yetki erişimi yalnızca görev gerektiren çalışanlara verilir ve tüm erişimler kayıt altına alınır.',
            ],
          ),
          (
            '5. Saklama ve Silme',
            [
              'Veriler, hizmet ilişkisi boyunca saklanır; ilişki sona erdiğinde yasal saklama süreleri boyunca tutulur ve ardından silinir.',
              'Hesabınızın silinmesini istediğinizde ${SiteContact.supportEmail} adresine yazabilirsiniz.',
            ],
          ),
        ],
      LegalDocument.terms => const [
          (
            '1. Hizmetin Kapsamı',
            [
              'Lineer Destek; teknik servis yönetimi, iş emeri takibi, stok, muhasebe ve saha operasyonu süreçlerini kapsayan bir yazılım platformudur.',
              'Platform, internet bağlantısı gerektiren bir çevrimiçi hizmet olarak sunulur.',
            ],
          ),
          (
            '2. Hesap ve Yetkilendirme',
            [
              'Hizmet kullanımı için tarafınızca yetkilendirilmiş kullanıcı hesapları oluşturulur.',
              'Hesap bilgilerinizin gizliliğinden ve yetkisiz erişim önlenmesinden siz sorumlusunuz.',
            ],
          ),
          (
            '3. Kullanıcı Yükümlülükleri',
            [
              'Hizmeti yasalara aykırı amaçlarla kullanmamak, verilere yetkisiz erişim sağlamamak yasaktır.',
              'Müşteri ve çalışan kişisel verilerinin yasal mevzuatta öngörüldüğü şekilde işlenmesinden tarafınız sorumludur.',
            ],
          ),
          (
            '4. Faturalandırma ve Ödeme',
            [
              'Ücretli paketlerde faturalandırma dönemsel olarak yapılır ve ödemeler banka kartı ile tahsil edilir.',
              'İptal ve iade koşulları, paket seçimi sırasında belirtilen koşullara tabidir.',
            ],
          ),
          (
            '5. Fikri Mülkiyet',
            [
              'Platformun yazılımı, arayüzü, markası ve içeriği Lineer Destek\'in mülkiyetindedir.',
              'Kullanıcı, platformda oluşturduğu verilerin kendisine ait olduğunu kabul eder.',
            ],
          ),
          (
            '6. Sorumluluğun Sınırlandırılması',
            [
              'Platform, kesinti veya yazılım hatalarından doğan dolaylı zararlardan sorumlu tutulamaz.',
              'Kesinti durumlarında verileriniz düzenli yedeklenir ve korunur.',
            ],
          ),
        ],
      LegalDocument.cookies => const [
          (
            '1. Çerez Nedir?',
            [
              'Çerezler, ziyaret ettiğiniz web sitelerinin tarayıcınıza kaydettiği küçük metin dosyalarıdır.',
              'Platformumuz, hizmetin çalışması için gerekli çerezleri ve analiz amaçlı çerezleri kullanır.',
            ],
          ),
          (
            '2. Kullanılan Çerez Türleri',
            [
              'Zorunlu çerezler: oturum açma, güvenlik ve dil tercihi gibi hizmetin çalışması için gereklidir.',
              'Analiz çerezleri: hizmetin kullanım istatistiklerini anlamak için kullanılır.',
              'Tercih çerezleri: arayüz ve raporlama tercihlerinizin hatırlanması için kullanılır.',
            ],
          ),
          (
            '3. Çerez Yönetimi',
            [
              'Tarayıcınızın ayarlarından çerezleri engelleyebilir veya silebilirsiniz.',
              'Zorunlu çerezlerin engellenmesi hizmetin kullanımını etkileyebilir.',
            ],
          ),
          (
            '4. Değişiklikler',
            [
              'Çerez politikasındaki değişiklikler bu sayfada yayımlanır ve yürürlüğe girdikten sonra geçerli olur.',
            ],
          ),
        ],
    };
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.heading, required this.paragraphs});

  final String heading;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final paragraph in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                paragraph,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
