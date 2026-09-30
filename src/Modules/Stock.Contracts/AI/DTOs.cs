namespace TechSupport.Stock.Contracts.AI;

/// <summary>
/// AI tarafına stok kartı bilgisi taşır.
/// </summary>
public sealed record StockItemInfoResponse(
    Guid StockItemId,
    string Sku,
    string Name,
    string? Description,
    string? CategoryName,
    string? Unit,
    decimal? UnitPrice,
    long QuantityAvailable,
    long QuantityReserved);

/// <summary>
/// AI tarafına stok rezervasyon bilgisi taşır.
/// </summary>
public sealed record StockReservationInfoResponse(
    Guid ReservationId,
    Guid StockItemId,
    string Sku,
    string StockItemName,
    long Quantity,
    string Status,
    Guid? OperationId,
    Guid? TechnicianUserId,
    DateTime CreatedAtUtc);

/// <summary>
/// AI tarafına stok hareketi (transaction) bilgisi taşır.
/// </summary>
public sealed record StockTransactionInfoResponse(
    Guid TransactionId,
    Guid StockItemId,
    string Sku,
    string StockItemName,
    long Quantity,
    string Type,
    Guid? OperationId,
    string? Reference,
    DateTime CreatedAtUtc);

/// <summary>
/// AI tarafına tenant/branch seviyesinde stok özeti taşır.
/// </summary>
public sealed record StockSummaryResponse(
    int TotalItemCount,
    int CriticalItemCount,
    long TotalAvailable,
    long TotalReserved,
    int PendingReservationCount);