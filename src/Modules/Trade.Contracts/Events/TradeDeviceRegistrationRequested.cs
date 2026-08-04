namespace TechSupport.Trade.Contracts.Events;

public sealed record TradeDeviceRegistrationRequested(
    Guid TradeId,
    Guid TenantId,
    Guid? BranchId,
    Guid? CustomerId,
    Guid? AppUserId,
    string IdempotencyKey,
    string Brand,
    string Model,
    string SerialNumber,
    string? ProblemDescription,
    int? GuaranteePeriod,
    DateTimeOffset? WarrantyStartAtUtc,
    string? BarcodeNumber,
    string? CustomerName,
    string Status,
    DateTimeOffset OccurredAtUtc);
