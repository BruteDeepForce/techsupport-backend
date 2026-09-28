namespace TechSupport.Stock.Contracts.Services;

public interface IInventoryStockItemWriter
{
    Task<InventoryStockItemResult> CreateForDeviceAsync(InventoryStockItemCreateRequest request, CancellationToken cancellationToken = default);
}

public sealed record InventoryStockItemCreateRequest(
    Guid TenantId,
    Guid BranchId,
    Guid DeviceId,
    Guid CategoryId,
    string Sku,
    string ImeiOrSerial,
    string Barcode,
    string Name,
    string? Description,
    string Unit,
    decimal UnitPrice,
    long Quantity);

public sealed record InventoryStockItemResult(
    Guid StockItemId,
    Guid DeviceId,
    long QuantityAvailable);
