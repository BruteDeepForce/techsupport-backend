# Lineer Destek - 2026-09-29 Çalışma Notları

## Genel Durum

Bugün uygulamanın release öncesi birçok kritik noktası ele alındı:

- Forgot password akışı toparlandı.
- Flutter web/mobile API base URL konusu çözüldü.
- Web release/deploy akışı netleştirildi.
- SEO için temel dosyalar eklendi.
- Login/register hata mesajları kullanıcı dostu hale getirildi.
- iOS build/run için `--dart-define` kullanımı netleşti.
- Mobil register layout ve admin async `setState` hatası düzeltildi.
- Stock sisteminde “mevcut ürüne stok girişi” mantığı backend + frontend olarak kuruldu.
- Dashboard’dan önce “Şubeler” modülü için fikir konuşuldu.

## Forgot Password Akışı

İstenen mantık:

```text
Forgot password tıklandığında:
1. Sistemde kayıtlı e-posta adresine kod gidecek.
2. Kullanıcı kodu yazacak.
3. Şifre resetlenecek.
4. Başarılı reset sonrası kullanıcıya direkt JWT token üretilecek.
5. Kullanıcı tekrar login olmadan içeri alınacak.
```

Önemli not:

- `GeneratePasswordResetTokenAsync` / `ResetPasswordAsync` gibi Identity reset token yapısına gerek olmadığı konuşuldu.
- JWT üretimi mevcut `CreateTokenForUserAsync(AppUser user, CancellationToken ct = default)` üzerinden yapılmalı.
- Password reset başarılıysa kullanıcıya yeni token dönülmeli.

## Flutter API Base URL Yapısı

Flutter tarafında ana URL’in şurada olduğu tespit edildi:

```dart
class AppConfig {
  static const appName = 'Lineer Destek';

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5001',
  );

  static String hubUrl(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$normalizedPath';
  }
}
```

Kullanan yer:

```dart
BaseOptions(
  baseUrl: AppConfig.baseUrl,
)
```

SignalR hub URL’leri de hardcoded localhost’tan çıkarılıp `AppConfig.hubUrl(...)` ile bağlandı:

```dart
AppConfig.hubUrl('/trade-status-hub')
AppConfig.hubUrl('/hr-notification-hub')
```

## Web Release Build Komutu

Prod web build için doğru komut:

```bash
cd apps/mobile
flutter build web --release --dart-define=API_BASE_URL=https://lineerdestek.cyber2tech.com
```

Önemli not:

Flutter web’de `API_BASE_URL` build anında `main.dart.js` içine gömülür. Server/Docker env ile sonradan değişmez.

Parametre verilmezse default çalışır:

```text
http://localhost:5001
```

Bu yüzden prod build parametresiz alınmamalı.

## Web Deploy / Dockerfile Mantığı

Mevcut deploy modeli:

```text
1. Flutter web build önceden alınır.
2. build/web klasörü Git/deploy tarafına gönderilir.
3. Docker sadece hazır build/web dosyalarını Nginx içine koyar.
4. Docker içinde tekrar Flutter build alınmaz.
```

Doğru Dockerfile:

```dockerfile
FROM nginx:stable-alpine

COPY build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

Yanlış olan model:

```text
Docker build sırasında Flutter build almak.
```

Bu model iptal edildi çünkü iki yerde build oluşmasına sebep oluyordu.

## Frontend Notlarına Eklenen Release Notu

`Frontend-Notlar.md` içine şu build komutu eklendi:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://lineerdestek.cyber2tech.com
git add -f build/web
git commit -m "add build"
git push
```

Eklenen uyarı:

```text
[PROD WEB BUILD ALIRKEN API_BASE_URL MUTLAKA VERİLECEK. VERİLMEZSE DEFAULT OLARAK LOCALHOST:5001'E GİDER.]
```

## SEO Çalışması

Flutter web içine temel SEO dosyaları eklendi.

Eklenen/güncellenen dosyalar:

```text
apps/mobile/web/index.html
apps/mobile/web/robots.txt
apps/mobile/web/sitemap.xml
```

`robots.txt`:

```txt
User-agent: *
Allow: /

Sitemap: https://www.lineerdestek.com/sitemap.xml
```

`sitemap.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://www.lineerdestek.com/</loc>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

Google için yapılacaklar:

```text
1. Google Search Console'a lineerdestek.com ekle.
2. DNS TXT doğrulamasını yap.
3. URL Inspection ile index request at.
4. robots.txt ve sitemap.xml canlıda erişilebilir olmalı.
```

## Login Navigator Hatası

Hata:

```text
Assertion failed:
navigator.dart
_history.isNotEmpty is not true
```

Sebep:

- Login 401 alınca global `AuthInterceptor` bunu “oturum düştü” gibi yorumluyordu.
- Login sayfasındayken redirect login stack’i bozabiliyordu.

Fix:

```dart
final path = err.requestOptions.path.toLowerCase();
final isAuthRequest = path.contains('/api/identity/account/');

if (statusCode == 401 && !isAuthRequest && !_isHandlingUnauthorized) {
  ...
}
```

Sonuç:

```text
Login yanlışsa sadece login ekranında hata gösterilecek.
Uygulama içindeyken token geçersizse login'e yönlendirme devam edecek.
```

## Login Hata Mesajı

Problem:

Login başarısız olduğunda kullanıcıya teknik hata çıkıyordu.

İstenen davranış:

```text
Popup çıksın.
Sadece "Giriş başarısız" desin.
```

Eklenen yapı:

```dart
Future<void> _showLoginFailedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Giriş başarısız'),
      content: const Text('E-posta veya şifre hatalı.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}
```

## Register Hata Mesajı

Problem:

Register başarısız olduğunda kullanıcıya teknik `DioException` gösteriliyordu.

Backend 400 response body olarak `IdentityError` listesi dönüyor.

Muhtemel sebepler:

```text
- Email zaten kayıtlı
- UserName zaten kayıtlı
- Şifre policy sağlamıyor
- Email/UserName formatı Identity tarafından reddediliyor
```

Frontend payload backend DTO ile uyumlu:

```json
{
  "Email": "...",
  "UserName": "...",
  "Password": "...",
  "Role": "...",
  "tenantName": "...",
  "BranchName": "..."
}
```

`AuthService.register` artık backend error body’sini parse ediyor:

```dart
throw AuthFailure(_errorMessage(error.response?.data));
```

Eklenen exception:

```dart
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
```

## iPhone / iOS Run Komutları

Mevcut komut:

```bash
flutter run -d 00008030-001924C636B9402E
```

Bu komut `API_BASE_URL` vermediği için default localhost’a gider:

```text
http://localhost:5001
```

Doğru debug run:

```bash
flutter run -d 00008030-001924C636B9402E --dart-define=API_BASE_URL=https://lineerdestek.cyber2tech.com
```

Release run:

```bash
flutter run --release -d 00008030-001924C636B9402E --dart-define=API_BASE_URL=https://lineerdestek.cyber2tech.com
```

Profile run:

```bash
flutter run --profile -d 00008030-001924C636B9402E --dart-define=API_BASE_URL=https://lineerdestek.cyber2tech.com
```

iOS build:

```bash
flutter build ios --release --dart-define=API_BASE_URL=https://lineerdestek.cyber2tech.com
```

IPA build:

```bash
flutter build ipa --release --dart-define=API_BASE_URL=https://lineerdestek.cyber2tech.com
```

## Mobil Register Layout Overflow

Hata:

```text
A RenderFlex overflowed by 32 pixels on the bottom.
Column
register_page.dart
```

Sebep:

Mobil register sayfasında body `Column` ile sabit yükseklikteydi. Küçük ekranda/klavye açıkken sığmıyordu.

Fix:

```dart
body: SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(...)
)
```

Dosya:

```text
apps/mobile/lib/features/auth/presentation/register_page.dart
```

## AdminHome setState After Dispose

Hata:

```text
setState() called after dispose(): _AdminHomePageState
```

Sebep:

`_loadReportsData()` async çalışırken kullanıcı sayfadan çıkıyordu. Response dönünce `setState` çağrılıyordu.

Fix:

```dart
if (!mounted) return;
```

## Stock Sistemi - Problem

Problem:

```text
Intel i9 11. nesil stokta 40 adet var.
40 adet satıldı, stok 0 oldu.
Sonra 40 adet daha alındı.
Sistem yeni satır açıyor.
```

İstenen mantık:

```text
Aynı ürün için yeni StockItem açılmamalı.
Var olan StockItem seçilmeli.
StockBalance artırılmalı.
StockTransaction ile hareket kaydı tutulmalı.
```

Konuşulan ürün kimliği mantığı:

```text
StockItem = ürün kartı
StockBalance = mevcut miktar
StockTransaction = stok hareketi
```

SKU/barkod mantığı:

```text
SKU ürünün şirket içi benzersiz kodudur.
Barkod ürünün okutulan/dış kodudur.
Mevcut ürüne stok girişi yapılırken SKU/barkod değiştirilmez.
Seçilen üründen read-only olarak gösterilir.
```

## Stock Backend - Mevcut Ürüne Stok Girişi

Eklenen endpoint:

```http
POST /api/stock/items/{id}/stock-in
```

Body:

```json
{
  "quantity": 40,
  "reference": "Yeni alım / fatura no vs opsiyonel"
}
```

Eklenen DTO:

```csharp
namespace TechSupport.Stock.DTO;

public sealed record StockInDTO(
    long Quantity,
    string? Reference = null
);
```

Backend işlem mantığı:

```text
1. Quantity <= 0 ise hata.
2. StockItem tenant içinde bulunur.
3. tenant + branch + stockItem için StockBalance aranır.
4. Balance varsa QuantityAvailable += quantity.
5. Balance yoksa yeni StockBalance oluşturulur.
6. StockTransaction yazılır.
7. item.UpdatedAtUtc güncellenir.
```

Değişen backend dosyaları:

```text
src/Modules/Stock/DTO/StockInDTO.cs
src/Modules/Stock/Services/IStockService.cs
src/Modules/Stock/Services/StockService.cs
src/Modules/Stock/Api/Controllers/StockItemsController.cs
```

## Stock Frontend - Admin Web Stok Girişi

Admin web stok sayfasında mevcut `Stok Ekle` dialog’u yeni ürün oluşturma olarak bırakıldı.

Dialog’un en üstüne yeni buton eklendi:

```text
Mevcut Ürüne Stok Girişi
```

Butona basınca yeni akış açılıyor:

```text
1. Kategori seç.
2. O kategorideki ürünleri getir.
3. Ürün seç.
4. Seçilen ürün için SKU / Barkod / Mevcut Stok / Rezerve miktarı göster.
5. Eklenecek miktarı gir.
6. Opsiyonel referans/açıklama gir.
7. Stok Girişi Yap.
```

Frontend endpoint çağrısı:

```dart
Future<void> stockIn({
  required String stockItemId,
  required int quantity,
  String? reference,
}) async {
  final res = await _dio.post('/api/stock/items/$stockItemId/stock-in', data: {
    'quantity': quantity,
    'reference': reference,
  });
  if (res.statusCode != 200) {
    throw Exception('Failed to update stock: ${res.statusCode}');
  }
}
```

Değişen frontend dosyaları:

```text
apps/mobile/lib/features/admin_web/presentation/admin_web_stock_page.dart
apps/mobile/lib/features/stock/data/stock_service.dart
```

## Dashboard Mock Data ve Planlama Fikri

Dashboard ana sayfasında mock datalar olduğu konuşuldu.

Dashboard’u gerçek yapmak için önce planlama/rezervasyon modülü fikri konuşuldu.

Önerilen domain:

```text
ServiceAppointment / WorkSchedule
```

Entity fikri:

```text
ServiceAppointment
- Id
- TenantId
- BranchId
- OperationId nullable
- TicketId nullable
- CustomerId nullable
- TechnicianId nullable
- Title
- Description
- StartAt
- EndAt
- Status
- Priority
- AppointmentType
- LocationType
- Address
- CreatedByUserId
- CreatedAt
- UpdatedAt
```

Status:

```text
Planned
Confirmed
InProgress
Completed
Cancelled
NoShow
```

AppointmentType:

```text
OnSiteService
RemoteSupport
Pickup
Delivery
Maintenance
Installation
Inspection
```

API fikri:

```http
GET    /api/scheduling/appointments?from=2026-09-29&to=2026-10-06
POST   /api/scheduling/appointments
PUT    /api/scheduling/appointments/{id}
PATCH  /api/scheduling/appointments/{id}/status
DELETE /api/scheduling/appointments/{id}
GET    /api/scheduling/dashboard
```

## Şubeler Modülü Fikri

Dashboard’dan önce “Şubeler” modülü düşünülüyor.

Mantık:

```text
Tenant = firma / şirket
Branch = firmaya bağlı lokasyon / servis noktası / depo / bayi
```

Önerilen ekran:

```text
Admin Web > Şubeler
```

İlk faz alanlar:

```text
- Şube adı
- Kod
- Adres
- Telefon
- E-posta
- Yetkili kişi
- Aktif / Pasif
- Oluşturulma tarihi
- Bağlı kullanıcı/teknisyen sayısı
- Stok kalemi sayısı
```

Backend API fikri:

```http
GET    /api/branches
GET    /api/branches/{id}
POST   /api/branches
PUT    /api/branches/{id}
PATCH  /api/branches/{id}/status
```

Not:

Mevcut sistemde `branch_id` JWT içinde kullanılıyor. Önce mevcut branch entity/service/controller yapısı incelenmeli.

## Son Durum

Bugün itibarıyla:

```text
- Web deploy tamam.
- API prod adrese gidiyor.
- Mobilde uygulama çalışıyor.
- Login/register teknik hata mesajları temizleniyor.
- Mobil register overflow çözüldü.
- AdminHome async setState hatası çözüldü.
- Stock duplicate item problemi için backend + frontend yeni akış kuruldu.
- SEO temel dosyaları eklendi.
- Dashboard öncesi planlama ve şube modülü fikirleri konuşuldu.
```

Kalan önerilen sıradaki işler:

```text
1. Branch/Şube modülünü incele ve admin web arayüzünü kur.
2. Dashboard mock dataları gerçek metriklere bağla.
3. Planlama/takvim modülünü backendde tasarla.
4. Stock-in akışını canlıda test et.
5. Search Console index request yap.
```
