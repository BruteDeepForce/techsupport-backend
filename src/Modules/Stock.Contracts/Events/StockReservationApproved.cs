namespace TechSupport.Stock.Contracts.Events;

public sealed record StockReservationApproved(
    Guid ReservationId,
    Guid TenantId,
    Guid ApprovedBy,
    DateTimeOffset OccurredAtUtc
);
