namespace TechSupport.Stock.Contracts.Events;

public sealed record StockStatusReserved(
    Guid ReservationId,
    Guid TenantId,
    Guid StockItemId,
    Guid TechnicianUserId,
    Guid? OperationId,
    Guid? BranchId,
    long Quantity,
    decimal UnitPriceSnapshot,
    DateTimeOffset OccurredAtUtc
);
