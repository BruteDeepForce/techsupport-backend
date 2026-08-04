namespace TechSupport.Stock.DTO;

public sealed record StockItemListDto(
    Guid Id,
    Guid? CategoryId,
    string? CategoryName,
    string Sku,
    string Barcode,
    string Name,
    string? Description,
    string? Unit,
    decimal? UnitPrice,
    long QuantityAvailable,
    long QuantityReserved,
    DateTime CreatedAtUtc,
    Guid? DeviceId
);

