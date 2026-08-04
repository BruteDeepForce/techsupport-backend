namespace TechSupport.Trade.Contracts.Events;

public sealed record TradeCustomerProvisionRequested(
    Guid TradeId,
    Guid TenantId,
    Guid? BranchId,
    string IdempotencyKey,
    string Name,
    string Email,
    string? PhoneNumber,
    string TemporaryPassword,
    DateTimeOffset OccurredAtUtc);
