namespace TechSupport.Trade.Contracts.Events;

public sealed record TradeAccountModuleInserted(
    Guid TradeId,
    Guid TenantId,
    Guid? BranchId,
    Guid CustomerId,
    string IdempotencyKey,
    DateTimeOffset OccurredAtUtc,
    int Quantity,
    decimal UnitPrice,
    decimal? CostPrice,
    decimal TotalAmount,
    decimal? PaidAmount,
    bool IsPurchase,
    PaymentMethod PaymentMethod);

public enum PaymentMethod
{
    Cash = 1,
    Card = 2,
    Transfer = 3
}