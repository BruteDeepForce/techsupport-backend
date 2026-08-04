namespace TechSupport.Stock.Contracts.Events;

public sealed record StockReservationFinalized(
    Guid ReservationId,
    Guid TenantId,
    Guid FinalizedBy,
    int Quantity,
    DateTimeOffset OccurredAtUtc
);
