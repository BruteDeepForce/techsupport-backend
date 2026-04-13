# TechSupport Backend

Teknik servis startup uygulaması için geliştirilmiş, `.NET 9` tabanlı bir modular monolith backend.

Bu doküman mevcut backend kod tabanına göre hazırlanmıştır. Amaç, sistemin bugün hangi iş kabiliyetlerini desteklediğini, modüller arası akışları ve geliştirilmesi gereken alanları tek yerde toplamaktır.

## Ürün Özeti

Backend; teknik servis operasyonlarının uçtan uca yönetimi için kurgulanmıştır.

Bugünkü yapıya göre sistem şu ana iş alanlarını kapsar:

- tenant ve kullanıcı yönetimi
- müşteri ve teknisyen onboarding
- cihaz kayıt ve ilişkilendirme
- ticket açma ve operasyona dönüştürme
- operasyon ve teknisyen iş emri takibi
- bakım taksonomisi ve bakım şablonları
- stok kategori ve stok kartı oluşturma
- raporlama projeksiyonları
- AI destekli semantik operasyon sorgulama

## Monorepo Yapısı

- `src/` -> .NET backend kaynak kodları
- `apps/mobile/` -> Flutter mobil uygulaması

> Not: Backend halen `src/` altında tutulmaktadır. İleride istenirse farklı bir uygulama klasör yapısına taşınabilir.

## Mimari Yaklaşım

Uygulama tek bir host altında çalışan, modüllere ayrılmış bir monolith yapısındadır.

Temel özellikler:

- API host: `src/TechSupport.Web`
- kimlik doğrulama: JWT
- yetkilendirme: role ve claim bazlı
- veri erişimi: EF Core + PostgreSQL
- modüller arası iletişim: `MassTransit + RabbitMQ`
- veri ayrımı: tek veritabanı, modül bazlı PostgreSQL schema yaklaşımı

Her modül kendi `DbContext`'ine, migration setine, servis katmanına ve controller yüzeyine sahiptir.

## Aktif Backend Modülleri

### `Identity`

Kimlik doğrulama, rol yönetimi, tenant ana verisi ve JWT üretimi.

Sağladıkları:

- kullanıcı register
- kullanıcı login
- forgot password token üretimi
- role seed etme
- manuel role oluşturma
- tenant oluşturma

### `User`

Identity kullanıcısından ayrı olarak iş profili tutar.

Sağladıkları:

- kullanıcıyı tenant, branch ve role ile eşleme
- JWT token üretimi için tenant ve branch claim kaynağı sağlama

### `Customer`

Müşteri kayıtları ve müşteri-cihaz ilişkileri.

Sağladıkları:

- asenkron müşteri provisioning
- müşteri listeleme
- müşteri detay sorgulama
- provisioning durumu sorgulama
- müşteriye cihaz atama

### `Technician`

Teknisyen kayıtları ve teknisyene atanmış operasyonların ayrı bounded context içinde tutulması.

Sağladıkları:

- asenkron teknisyen provisioning
- teknisyen listeleme
- teknisyen detay sorgulama
- aktif/pasif yönetimi
- teknisyene atanmış işlerin lokal kopyasını tutma
- teknisyen tarafından iş durumu güncelleme

### `Device`

Cihaz kayıt sistemi.

Sağladıkları:

- tenant/branch bazlı cihaz kaydı
- cihaz detay sorgulama
- cihazı pasife alma

### `Operation`

Servis operasyonlarının çekirdek iş modülü.

Sağladıkları:

- doğrudan operasyon oluşturma
- ticket oluşturma
- ticket listeleme
- ticket reddetme
- ticket'ı operasyona dönüştürme
- operasyon detay sorgulama
- operasyon listeleme
- operasyon güncelleme
- operasyon durum güncelleme
- bakım taksonomisi yönetimi
- bakım şablonu yönetimi

### `Stock`

Stok kartı ve stok kategorisi yönetimi.

Sağladıkları:

- stok kategorisi oluşturma
- stok kategorilerini listeleme
- stok kartı oluşturma
- başlangıç stok bakiyesi oluşturma

### `Reports`

Operasyonel olaylardan beslenen rapor okuma modeli.

Sağladıkları:

- tenant rapor özetleri
- teknisyen özetleri
- metrik listeleme
- tekil metrik sorgulama
- event idempotency takibi

### `Ai`

Operasyon verilerini embedding olarak saklayan ve benzer içerikler üzerinden cevap üreten yardımcı modül.

Sağladıkları:

- operasyon oluşturulunca embedding üretimi
- operasyon durum değişince AI veri setini güncelleme
- tenant bazlı AI chat endpoint'i

## Rol Modeli

Backend şu rolleri kullanır:

- `admin`
- `customer`
- `technician`

Temel davranışlar:

- `admin`: yönetimsel işlemler, onboarding, operasyon dönüştürme, stok ve bakım yönetimi
- `customer`: ticket açma, kendi kayıtlarını ve kendi operasyonlarını görüntüleme
- `technician`: atanmış işlerin durumunu güncelleme

## Şu Anda Uygulamada Neler Yapılabiliyor

### 1. Tenant ve kullanıcı altyapısı kurulabiliyor

Sistemde tenant açılabiliyor, roller oluşturulabiliyor ve kullanıcı login/register akışı çalışıyor.

### 2. Müşteri hesabı asenkron provisioning ile açılabiliyor

Admin müşteri oluşturma isteği başlatıyor. Identity modülü hesabı açıyor, `customer` rolünü veriyor, ardından Customer modülü müşteri kaydını tamamlıyor.

### 3. Teknisyen hesabı asenkron provisioning ile açılabiliyor

Admin teknisyen oluşturma isteği başlatıyor. Identity tarafında kullanıcı ve rol oluşuyor, ardından Technician modülünde teknisyen kaydı tamamlanıyor.

### 4. Müşteriler listelenebiliyor ve detay görüntülenebiliyor

Tenant bazlı müşteri listesi ve tekil müşteri sorgusu mevcut.

### 5. Cihaz kaydı yapılabiliyor

Marka, model ve seri numarası ile cihaz sisteme alınabiliyor. Tenant içinde seri numarası unique tutuluyor.

### 6. Cihaz müşteriyle ilişkilendirilebiliyor

Bir müşteriye bir veya daha fazla cihaz bağlanabiliyor.

### 7. Müşteri ticket açabiliyor

Authenticated müşteri kullanıcıları destek talebi oluşturabiliyor.

### 8. Ticket havuzu yönetilebiliyor

Admin tüm ticket'ları görebiliyor. Müşteri sadece kendi ticket'larını görebiliyor.

### 9. Ticket operasyona dönüştürülebiliyor

Admin, bir ticket'ı operasyona çevirebiliyor. Dönüşüm sırasında operasyon tipi, öncelik ve teknisyen ataması verilebiliyor.

### 10. Ticket reddedilebiliyor

Operasyona dönüşmemiş bir ticket admin tarafından reddedilebiliyor.

### 11. Doğrudan operasyon açılabiliyor

Backend sadece ticket bazlı değil; doğrudan operasyon oluşturmayı da destekliyor.

### 12. Operasyonlar rol bazlı listelenebiliyor

- admin tüm tenant operasyonlarını görür
- customer kendi operasyonlarını görür
- technician kendisine atanmış operasyonları görür

### 13. Operasyon status yaşam döngüsü yönetilebiliyor

Desteklenen status'ler:

- `Created`
- `Diagnosing`
- `WaitingForApproval`
- `Repairing`
- `Testing`
- `Completed`
- `Delivered`

### 14. Teknisyen kendi iş emrinin durumunu güncelleyebiliyor

Teknisyen modülünde ayrı tutulan iş emri kaydı güncelleniyor. Bu değişiklik Operation, Reports ve AI modüllerine event olarak yayılıyor.

### 15. Bakım uzmanlık alanları tanımlanabiliyor

Tenant bazında şu taksonomiler tanımlanabiliyor:

- product type
- brand
- class

### 16. Bakım şablonları oluşturulabiliyor

Checklist tabanlı bakım template'leri oluşturulabiliyor, güncellenebiliyor ve filtrelenebiliyor.

### 17. Stok kategorileri ve stok kartları açılabiliyor

Kategori bazlı stok kartı oluşturulabiliyor. İlk miktar girilince balance kaydı otomatik oluşuyor.

### 18. Rapor verileri event'lerden üretilebiliyor

Tenant, teknisyen ve operasyon metrikleri event tüketimi ile beslenen read model üzerinden sorgulanabiliyor.

### 19. AI destekli operasyon geçmişi sorgulaması yapılabiliyor

Geçmiş operasyonlardan oluşturulan embedding verileri kullanılarak tenant bazlı teknik destek sohbeti yapılabiliyor.

## Ana Backend Akışları

### Müşteri onboarding akışı

1. Admin müşteri oluşturma isteği başlatır.
2. Customer modülü provisioning request açar.
3. Identity modülü kullanıcı hesabını oluşturur.
4. User modülü tenant ve role profilini kaydeder.
5. Customer modülü müşteri kaydını tamamlar.
6. Reports modülü müşteri oluşumunu rapor projeksiyonuna işler.

### Teknisyen onboarding akışı

1. Admin teknisyen oluşturma isteği başlatır.
2. Technician modülü provisioning request açar.
3. Identity modülü kullanıcı hesabını oluşturur.
4. User modülü tenant ve role profilini kaydeder.
5. Technician modülü teknisyen kaydını tamamlar.
6. Reports modülü teknisyen özet bilgisini günceller.

### Ticket'tan operasyona dönüşüm

1. Customer ticket açar.
2. Admin ticket'ı inceler.
3. Ticket operasyona dönüştürülür.
4. İsteğe bağlı teknisyen ataması yapılır.
5. Operation modülü event yayınlar.
6. Technician modülü kendi iş emri kaydını oluşturur.
7. Reports modülü sayaçları günceller.
8. AI modülü embedding üretir.

### Teknisyen durum güncelleme akışı

1. Teknisyen kendi operasyon durumunu günceller.
2. Technician modülü status değişimini publish eder.
3. Operation modülü ana operasyon kaydını günceller.
4. Reports modülü metrikleri günceller.
5. AI modülü operasyon durum içeriğini günceller.

## Veri Katmanı

Provider:

- `Npgsql.EntityFrameworkCore.PostgreSQL`

Schema yapısı:

- `identity`
- `users`
- `customers`
- `devices`
- `operations`
- `technicians`
- `stock`
- `reports`
- `ai`

Migration yaklaşımı:

- her modül migration'ını kendi proje içinde tutar
- `dotnet-ef` startup projesi host projedir
- hedef proje ilgili modül projesidir

Örnek:

```bash
dotnet ef migrations add Initial_Device \
  --project src/Modules/Device \
  --startup-project src/TechSupport.Web \
  --context TechSupport.Device.Data.DeviceDbContext \
  --output-dir Data/Migrations

dotnet ef database update \
  --startup-project src/TechSupport.Web \
  --context TechSupport.Device.Data.DeviceDbContext
```

## Build ve Çalıştırma

```bash
dotnet --version
dotnet build src/TechSupport.Web
cd src/TechSupport.Web
dotnet run
```

Development ortamında Swagger:

- `http://localhost:5000/swagger`

## Mobil Taraf ile Entegrasyon

Önerilen yaklaşım:

- Flutter native UI
- REST API iletişimi
- JWT authentication
- role bazlı ekran ayrımı

## Eksik veya Geliştirilmesi Gereken Backend Başlıkları

Bu bölüm mevcut kod tabanına göre öncelikli geliştirme alanlarını özetler.

### 1. Branch yönetimi eksik

`Branch` entity mevcut ancak branch CRUD ve branch bazlı yönetim API yüzeyi görünmüyor.

### 2. Stok işlemleri yarım

Domain'de reservation ve transaction yapıları var ancak şu akışlar API seviyesinde tamamlanmış değil:

- stok düşme
- stok rezervasyon
- stok tüketim
- stok iade
- stok transfer
- stok sayım ve düzeltme

### 3. Cihaz yönetimi sınırlı

Şu an create, get ve deactivate var. Şunlar eksik veya zayıf:

- cihaz listeleme
- cihaz güncelleme
- garanti bilgisi yönetimi
- cihaz servis geçmişi görünümü

### 4. Müşteri ve teknisyen profil alanları olgunlaşmalı

Teknisyen DTO'sunda `LastName` var ancak servis katmanında tam kullanılmıyor. Profil modeli daha net hale getirilmeli.

### 5. Operasyon durum akışı tek noktadan standardize edilmeli

Bazı status değişimleri event ile yan etkileri tetikliyor, bazıları doğrudan kayıt güncelliyor. Tüm status güncellemeleri için tek bir standart workflow daha sağlıklı olur.

### 6. Operasyon atama ve yeniden atama yönetimi güçlendirilmeli

Mevcut yapıda ilk atama var. Ancak aşağıdakiler açık değil:

- yeniden atama
- atama geçmişi
- teknisyen reddi sonrası yeniden yönlendirme
- atama audit trail

### 7. Ticket workflow genişletilmeli

Bugün temel akış var. Eksik görünen başlıklar:

- ticket yorumları
- ticket dosya yükleme akışı
- ticket durum geçmişi
- SLA takibi
- müşteri geri bildirim akışı

### 8. Raporlama katmanı genişletilmeli

Mevcut raporlar read model seviyesinde temel özet sunuyor. İş değeri açısından şu alanlar eklenebilir:

- branch bazlı dashboard
- tarih aralıklı filtreler
- operasyon tipi bazlı kırılımlar
- müşteri segment bazlı analiz
- teknisyen performans trendleri

### 9. AI modülü güvenlik ve ürünleştirme açısından sertleştirilmeli

Mevcut AI controller yüzeyinde yetkilendirme politikası ayrıca gözden geçirilmeli. Ayrıca:

- prompt güvenliği
- tenant veri izolasyonu testleri
- cevap kaynaklandırma
- kullanım kotası
- hata ve fallback stratejileri

### 10. Admin yönetim API'leri ayrıştırılmalı

Bazı yönetimsel işlemler farklı modüllere dağılmış durumda. Daha net bir admin backend yüzeyi gerekebilir.

### 11. Audit ve gözlemlenebilirlik artırılmalı

İşletimsel olgunluk için aşağıdakiler önemli:

- merkezi audit log
- kritik aksiyon geçmişi
- correlation id standardizasyonu
- structured logging
- health checks
- retry ve dead-letter izleme

### 12. Doğrulama ve hata sözleşmeleri standartlaştırılmalı

Validation, business rule ve API hata formatı modüller arasında tek tip hale getirilmeli.

### 13. Test katmanı eksik görünüyor

Kod tabanında belirgin bir backend test yüzeyi görünmüyor. En azından şu katmanlar eklenmeli:

- unit test
- integration test
- API contract test
- event consumer test

### 14. Güvenlik sertleştirmesi gerekli

Özellikle üretim öncesi şu alanlar gözden geçirilmeli:

- config içindeki secret yönetimi
- JWT ayarlarının production hardening'i
- role/policy bazlı authorize standardizasyonu
- rate limiting
- brute force koruması

### 15. Domain tutarlılığı ve isimlendirme temizliği yapılmalı

Kod içinde bazı alan adları, yorumlar ve null davranışları ürünleşme öncesi refactor gerektiriyor. Bu, özellikle bakım ve yeni ekip üyeleri için önemli olacaktır.
