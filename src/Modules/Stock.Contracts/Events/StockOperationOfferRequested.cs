namespace TechSupport.Stock.Contracts.Events;

public sealed record StockOperationOfferRequested(
    Guid TenantId,
    Guid OperationId,
    Guid? BranchId,
    Guid TechnicianUserId,
    decimal TotalAmount,
    IReadOnlyCollection<StockOperationOfferItem> Items,
    DateTimeOffset OccurredAtUtc
);

public sealed record StockOperationOfferItem(
    Guid StockItemId,
    long Quantity,
    decimal UnitPriceSnapshot
);
