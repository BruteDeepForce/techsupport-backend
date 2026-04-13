# TechSupport App Flow

Bu doküman, `device`, `stock`, `operation`, `customer` ve `technician` modüllerinin ürün içindeki doğru konumunu netleştirmek için hazırlanmıştır.

Amaç:

- modül sınırlarını sadeleştirmek
- domain çakışmalarını önlemek
- uygulamanın servis akışını anlaşılır hale getirmek

## Temel Domain Ayrımı

Sistemde en kritik ayrım `Device` ile `Stock` arasındadır.

- `Device` = müşteriye ait olan ve servis verilen varlık
- `Stock` = firmanın envanterinde duran ve operasyon sırasında kullanılan parça / ürün

Kısa tanım:

- `Device`: tamir ettiğin şey
- `StockItem`: tamirde kullandığın şey

Örnekler:

- laptop, klima, kombi, yazıcı -> `Device`
- ekran paneli, fan, toner, kablo, anakart, adaptör -> `StockItem`

Bu iki kavram aynı değildir ve aynı modülde eritilmemelidir.

## Modüllerin Sorumluluğu

### `Customer`

Müşteri sahipliğini ve müşteri kartını yönetir.

Sorumluluklar:

- müşteri oluşturma
- müşteri bilgileri
- müşteriye bağlı cihaz ilişkileri
- müşterinin sistemdeki sahiplik tarafı

### `Device`

Servis verilen müşteri cihazlarını yönetir.

Sorumluluklar:

- cihaz kaydı
- marka, model, seri numarası
- cihazın aktif/pasif durumu
- müşteri ile ilişkilendirme
- cihaz servis geçmişine referans olma

Bu modül şu soruya cevap verir:

`Hangi müşterinin hangi cihazına servis veriyoruz?`

### `Operation`

İş emri ve servis sürecinin ana merkezidir.

Sorumluluklar:

- ticket'tan operasyona dönüşüm
- doğrudan operasyon açma
- operasyon durumu
- operasyon tipi
- operasyon önceliği
- müşteri, cihaz ve teknisyen referansları
- bakım ve onarım iş akışı

Bu modül şu soruya cevap verir:

`Bu servis işi şu an hangi aşamada, kime atalı, hangi cihaz ve müşteriyle ilgili?`

### `Technician`

Teknisyen perspektifindeki iş emirlerini yönetir.

Sorumluluklar:
- teknisyen onboarding
- teknisyen aktif/pasif durumu
- teknisyene atanmış operasyonların görünümü
- teknisyenin kendi iş durumu güncellemeleri

Bu modül şu soruya cevap verir:

`Teknisyenin üstündeki işler neler ve bunlar hangi durumda?`

### `Stock`

Envanter ve parça kullanımını yönetir.

Sorumluluklar:

- stok kategorileri
- stok kartları
- branch bazlı bakiye
- rezervasyon
- tüketim
- iade
- stok hareket geçmişi

Bu modül şu soruya cevap verir:

`Operasyon sırasında hangi parçaları elimizde tutuyoruz ve hangilerini kullandık?`

## Doğru İlişki Modeli

Önerilen ilişki yapısı:

- `Customer 1 - N Device`
- `Customer 1 - N Ticket`
- `Device 1 - N Ticket`
- `Ticket 0..1 - 1 Operation`
- `Operation N - 1 Customer`
- `Operation N - 1 Device`
- `Operation N - 0..1 Technician`
- `Operation 1 - N OperationPartUsage`
- `OperationPartUsage N - 1 StockItem`

Bu yapı sayesinde:

- müşteri cihazı ile stok parçası karışmaz
- operasyonun hangi cihaz üzerinde yürüdüğü net olur
- hangi parça hangi işte kullanıldı takip edilebilir

## Önerilen Uygulama Akışı

### 1. Müşteri oluşturulur

Admin veya sistem, müşteri hesabını oluşturur.

### 2. Müşterinin cihazı kaydedilir

Müşteriye ait cihaz sisteme eklenir.

Bu kayıt şunları taşımalıdır:

- `CustomerId`
- `TenantId`
- `BranchId`
- `Brand`
- `Model`
- `SerialNumber`
- garanti bilgileri

### 3. Müşteri ticket açar

Müşteri cihazla ilgili destek talebi oluşturur.

Ticket mümkünse şu alanları taşımalıdır:

- `CustomerId`
- `DeviceId`
- `Title`
- `Description`
- `Priority`

### 4. Ticket operasyona dönüşür

Admin ticket'ı değerlendirir ve operasyona dönüştürür.

Operasyon şu alanları taşımalıdır:

- `CustomerId`
- `DeviceId`
- `AssignedTechnicianId`
- `Type`
- `Status`
- `Priority`

### 5. Teknisyen operasyona atanır

Atama sonrası teknisyen kendi iş listesinde bu operasyonu görür.

### 6. Teknisyen teşhis koyar

Teknisyen şu durumlara geçebilir:

- kabul etti
- teşhis ediyor
- onay bekliyor
- tamir ediyor
- test ediyor
- tamamladı
- teslim etti

### 7. Gerekirse stoktan parça ayrılır

Parça doğrudan müşteriye değil, operasyona bağlanmalıdır.

Doğru model:

- `Operation -> StockReservation`
- `Operation -> StockConsumption`

Bu sayede stok kullanımının bağlamı kaybolmaz.

### 8. Parça kullanılırsa stok düşer

Kullanılan parça operasyon bazlı işlenir.

Bu sayede şu sorular cevaplanabilir:

- hangi işte hangi parça kullanıldı
- hangi teknisyen hangi parçayı kullandı
- hangi operasyon ne kadar maliyet oluşturdu

### 9. Operasyon tamamlanır

Tamir veya bakım süreci bittiğinde operasyon kapanışa alınır.

### 10. Cihaz müşteriye teslim edilir

Teslim ile birlikte operasyon tamamlanmış olur ve raporlar güncellenir.

## Device ve Stock Neden Ayrı Kalmalı

`Device` ile `Stock` aynı tablo veya aynı domain içinde toplanmamalıdır.

Çünkü yaşam döngüleri farklıdır.

### `Device` yaşam döngüsü

- müşteriye kayıt edilir
- servis geçmişi oluşur
- garanti durumu tutulur
- bakım geçmişi tutulur
- aktif/pasif yapılabilir

### `Stock` yaşam döngüsü

- depoya giriş olur
- branch bazlı bakiye tutulur
- rezervasyon yapılır
- tüketim yapılır
- iade yapılır
- transfer yapılır
- sayım farkı işlenir

Bu iki lifecycle aynı modelde birleşirse domain kısa sürede dağılır.

## Önerilen Ek Kavramlar

Sistemi netleştirmek için `Operation` altında iki ek kavram çok faydalı olur.

### `OperationTimeline`

Operasyonda yaşanan adımları kronolojik tutar.

Örnek alanlar:

- `OperationId`
- `EventType`
- `Description`
- `CreatedByUserId`
- `CreatedAtUtc`

Faydası:

- operasyon geçmişi görünür hale gelir
- müşteri, admin ve teknisyen ekranları beslenir
- audit değeri sağlar

### `OperationPartUsage`

Bir operasyon içinde hangi stok kalemlerinin kullanıldığını tutar.

Örnek alanlar:

- `Id`
- `OperationId`
- `StockItemId`
- `Quantity`
- `UnitCost`
- `UsageType`
- `TechnicianUserId`
- `CreatedAtUtc`

Önerilen `UsageType` değerleri:

- `Reserved`
- `Consumed`
- `Returned`

Faydası:

- operasyon maliyeti hesaplanır
- stok hareketi ile servis işi bağlanır
- parça kullanımı şeffaflaşır

## Minimum Sağlam Tasarım

Ürünün bu aşamasında aşağıdaki sınırlar yeterince sağlamdır:

- `Customer` müşteri sahipliğini yönetir
- `Device` müşteri cihazlarını yönetir
- `Operation` iş emrini yönetir
- `Technician` teknisyen görünümünü ve durum güncellemelerini yönetir
- `Stock` envanter ve parça kullanımını yönetir

## Sonuç

En net kural şudur:

- `Device` müşteriye aittir
- `Stock` şirkete aittir
- `Operation` bu ikisini iş bağlamında bir araya getirir

Yani:

- müşteri bir `device` getirir
- sistem bir `operation` açar
- teknisyen işi yürütür
- gerekiyorsa `stock` kullanılır
- sonuç müşteri cihazı üzerinde oluşur

Bu ayrım korunursa backend ileride çok daha rahat büyür.
