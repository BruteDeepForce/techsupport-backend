namespace TechSupport.Stock.Contracts.Events;

public sealed record StockReservationRejected(
    Guid ReservationId,
    Guid TenantId,
    Guid RejectedBy,
    string? Reason,
    DateTimeOffset OccurredAtUtc
);
