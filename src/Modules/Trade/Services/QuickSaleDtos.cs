namespace TechSupport.Trade.Services;

public sealed record QuickSaleLineRequest(Guid StockItemId, int Quantity, decimal? UnitPriceOverride);

public sealed record CreateQuickSaleRequest(
    Guid TenantId,
    Guid? BranchId,
    IReadOnlyList<QuickSaleLineRequest> Lines,
    decimal DiscountAmount,
    decimal PaidAmount,
    string PaymentMethod,
    string Currency,
    string? Note);
