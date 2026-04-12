# Operation Module – Stock Reservation → Offer Flow

Bu döküman Operation modülünün Stock ile teklif oluşturma akışını özetler.

## Amaç
Teknisyen bir operasyon için parçaları **Stock modülü** üzerinden rezerve eder. Parçalar tamamlandığında, **tek bir event** ile tüm parça listesi ve toplam fiyat Operation modülüne gönderilir ve teklif oluşturulur.

## Akış Özeti
1. **Teknisyen parçaları rezerve eder**
   - `StockReserveService.ReserveStockAsync(...)`
   - Her rezervasyon `StockReservation` olarak kaydedilir.

2. **Operasyon için toplu teklif yayınlanır**
   - Tüm parçalar eklendikten sonra çağrılır:
     - `StockReserveService.PublishOperationOfferAsync(tenantId, operationId)`
   - Bu metod operasyonun tüm rezervasyonlarını toplar, aynı parçaları birleştirir ve toplam fiyatı hesaplar.

3. **Stock event’i Operation modülüne düşer**
   - Event: `StockOperationOfferRequested`
   - İçerik: `Items[]` + `TotalAmount`

4. **Operation tarafında teklif oluşturulur**
   - Consumer: `StockReservedConsumer`
   - İşlem: `_offerService.TechnicianCreateOfferAsync(...)`
   - Teklif `OfferRecord` + `OfferRecordItem` olarak kaydedilir.

## Event Sözleşmesi (Contracts)
- `TechSupport.Stock.Contracts.Events.StockOperationOfferRequested`
  - `Items`: `StockOperationOfferItem[]`
  - `TotalAmount`
  - `OperationId`, `TechnicianUserId`, `TenantId`, `BranchId`

## Notlar
- `PublishOperationOfferAsync` sadece **tüm parçalar hazır olduktan sonra** çağrılmalıdır.
- Eğer `OperationId` yoksa teklif oluşturulmaz.
- Para birimi şu an `TRY` olarak kabul ediliyor. (İleride event’e `Currency` eklenebilir.)
