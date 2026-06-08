# Accounting Module README

Bu dokuman, Accounting modulunun amacini, teknik kapsamini ve gelistirme akislarini ozetler.

## 1. Amac

Accounting modulu; tenant bazli muhasebe operasyonlarini yonetir:

- hesap (account) yonetimi
- cari hareket takibi
- fatura olusturma ve yasam dongusu
- odeme olusturma ve durum yonetimi
- fatura PDF uretimi

Modul, `TechSupport.Web` host'u icinde calisan modular monolith yapisinin bir parcasi olarak kullanilir.

## 2. Modul Kapsami

### Domain varliklari

- `Account`
- `Invoice`
- `InvoiceLineItem`
- `Payment`
- `CariHesapHareketi`

### Temel servisler

- `IAccountService` / `AccountService`
- `ICariHesapService` / `CariHesapService`
- `IInvoiceService` / `InvoiceService`
- `IInvoicePdfService` / `InvoicePdfService`
- `IPaymentService` / `PaymentService`
- `IRedisCacheService` / `RedisCacheService`

### Controllerlar

- `api/accounting/accounts`
- `api/accounting/cari-hesaplar`
- `api/accounting/invoices`
- `api/accounting/payments`

Tum endpointler `[Authorize]` ile korunur.

## 3. Tenant ve Claim Kullanimi

Controllerlar istek kapsaminda su claim alanlarini bekler:

- `tenantId` veya `tenant_id` (zorunlu)
- `branchId` veya `branch_id` (bazi akislar icin opsiyonel)

`tenantId` yoksa endpointler `401 Unauthorized` doner.

## 4. API Ozeti

Asagidaki liste moduldeki ana endpointleri ozetler.

### Accounts

- `GET /api/accounting/accounts/{accountId}`
- `GET /api/accounting/accounts/by-number/{accountNumber}`
- `GET /api/accounting/accounts?page=1&pageSize=20&type=&status=`
- `POST /api/accounting/accounts`
- `PUT /api/accounting/accounts/{accountId}`
- `DELETE /api/accounting/accounts/{accountId}`
- `POST /api/accounting/accounts/{accountId}/suspend`
- `POST /api/accounting/accounts/{accountId}/activate`
- `POST /api/accounting/accounts/{accountId}/close`
- `GET /api/accounting/accounts/{accountId}/balance`

### Cari Hesap

- `GET /api/accounting/cari-hesaplar?page=1&pageSize=20`
- `GET /api/accounting/cari-hesaplar/hareketler?page=1&pageSize=50`
- `GET /api/accounting/cari-hesaplar/{accountId}/bakiye?customerId=`
- `POST /api/accounting/cari-hesaplar/{accountId}/ekstre`
- `POST /api/accounting/cari-hesaplar/hareketler/create`
- `GET /api/accounting/cari-hesaplar/hareketler/{hareketId}`

### Invoices

- `GET /api/accounting/invoices/{invoiceId}`
- `GET /api/accounting/invoices/{invoiceId}/pdf`
- `GET /api/accounting/invoices/by-number/{invoiceNumber}`
- `GET /api/accounting/invoices?accountId=&status=&page=1&pageSize=20`
- `POST /api/accounting/invoices`
- `PUT /api/accounting/invoices/{invoiceId}`
- `POST /api/accounting/invoices/{invoiceId}/line-items`
- `DELETE /api/accounting/invoices/{invoiceId}/line-items/{lineItemId}`
- `POST /api/accounting/invoices/{invoiceId}/issue`
- `POST /api/accounting/invoices/{invoiceId}/cancel?reason=`
- `GET /api/accounting/invoices/receivable/{accountId}`
- `GET /api/accounting/invoices/receivable`

### Payments

- `GET /api/accounting/payments/{paymentId}`
- `GET /api/accounting/payments/by-number/{paymentNumber}`
- `GET /api/accounting/payments?accountId=&invoiceId=&status=&page=1&pageSize=20`
- `POST /api/accounting/payments`
- `POST /api/accounting/payments/{paymentId}/process`
- `POST /api/accounting/payments/{paymentId}/fail?reason=`
- `POST /api/accounting/payments/{paymentId}/refund?reason=`

## 5. Veri Katmani

`AccountingDbContext` varsayilan olarak `accounting` Postgres schema'sini kullanir.

### One-to-many iliskiler

- `Account -> Invoices`
- `Account -> Payments`
- `Account -> CariHesapHareketleri`
- `Invoice -> InvoiceLineItems`
- `Invoice -> Payments` (opsiyonel)
- `Invoice -> CariHesapHareketleri` (opsiyonel)
- `Payment -> CariHesapHareketleri` (opsiyonel)

### Onemli notlar

- Soft delete icin global query filter kullanilir.
- Cok sayida `TenantId` tabanli index tanimlanmistir.
- `Account` icin `RowVersion` ile optimistic concurrency uygulanir.
- `Account` tarafinda `TenantId` icin unique index vardir; mevcut modelde bir tenant icin tek hesap varsayimi bulunur.

## 6. Cache (Redis)

Cari hesap listesi, hareket listesi ve ekstre endpointlerinde Redis cache kullanilir.

Konfigurasyon anahtari:

- `Redis:ConnectionString`

Ornek:

```json
{
  "Redis": {
    "ConnectionString": "localhost:6379"
  }
}
```

## 7. Mesajlasma ve Entegrasyon

Modul, MassTransit uzerinden su eventi dinler:

- `OfferAdminApprovedForInvoicing` (`OfferAdminApprovedForInvoicingConsumer`)

Bu event geldikten sonra:

- uygun hesap secilir
- deterministik bir fatura numarasi (`OFR-{offerId}`) uretilir
- idempotency kontrolu yapilir
- proforma invoice ve line item kayitlari olusturulur

## 8. Modul Kaydi

`Program.cs` icinde modul kaydi:

```csharp
builder.Services.AddAccountingModule(builder.Configuration);
```

`ModuleExtensions` icinde su bilesenler register edilir:

- `AccountingDbContext` (Npgsql)
- otomatik migration (`Database.Migrate()`)
- Redis connection multiplexer
- Accounting servisleri

## 9. Konfigurasyon

Gerekli anahtarlar:

- `ConnectionStrings:DefaultConnection`
- `Redis:ConnectionString`

Ornek:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=myappdb;Username=myappuser;Password=..."
  },
  "Redis": {
    "ConnectionString": "localhost:6379"
  }
}
```

## 10. Lokal Gelistirme

### Build

```bash
dotnet restore
dotnet build src/Modules/Accounting/Accounting.csproj
```

### EF migration olusturma

```bash
dotnet ef migrations add <MigrationName> \
  --project src/Modules/Accounting/Accounting.csproj \
  --startup-project src/TechSupport.Web/TechSupport.Web.csproj \
  --context TechSupport.Accounting.Data.AccountingDbContext
```

### Migration uygulama

```bash
dotnet ef database update \
  --project src/Modules/Accounting/Accounting.csproj \
  --startup-project src/TechSupport.Web/TechSupport.Web.csproj \
  --context TechSupport.Accounting.Data.AccountingDbContext
```

## 11. Klasor Yapisi (Ozet)

- `Api/Controllers`: HTTP endpointler
- `Services`: is kurallari
- `Domain/Entities`: domain modeller
- `Data`: EF DbContext ve migrationlar
- `DTO`: request/response modelleri
- `RedisService`: cache abstraction ve implementasyon
- `Consumers`: message bus consumerlari

## 12. Gelistirme Notlari

- Endpointlerde tenant izolasyonunu bozacak sorgulardan kacin.
- Fatura/odeme gecislerinde state degisim kurallarini servis katmaninda koruyun.
- Yeni endpoint eklerken claim validasyonunu mevcut pattern ile tutarli kullanin.
- Cache key isimlendirmesinde tenant scope zorunlu olmalidir.
