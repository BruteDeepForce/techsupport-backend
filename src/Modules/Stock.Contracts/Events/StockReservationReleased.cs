namespace TechSupport.Stock.Contracts.Events;

public sealed record StockReservationReleased(
    Guid ReservationId,
    Guid TenantId,
    Guid ReleasedBy,
    DateTimeOffset OccurredAtUtc
);
