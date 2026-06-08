namespace TechSupport.Accounting.Contracts.Events;

public sealed record TradeAccountingProcessResulted(
    Guid TradeId,
    Guid TenantId,
    Guid? BranchId,
    string IdempotencyKey,
    AccountingProcessStatus Status,
    Guid? InvoiceId,
    Guid? PaymentId,
    string? ErrorMessage,
    DateTimeOffset OccurredAtUtc);

public enum AccountingProcessStatus
{
    Success = 1,
    Failed = 2
}
