namespace TechSupport.Account.Services;

public sealed record CreateQuickSaleAccountEntryRequest(
    Guid TenantId,
    Guid QuickSaleId,
    Guid? BranchId,
    decimal GrossAmount,
    decimal DiscountAmount,
    decimal NetAmount,
    string Currency,
    string PaymentMethod,
    string Description);
